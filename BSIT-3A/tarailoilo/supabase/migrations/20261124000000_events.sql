-- =====================================================================
-- Events (S20/S21) + AI event discovery queue (events_pending)
-- Run in: Supabase Dashboard -> SQL Editor -> New query -> Run.
-- Safe to re-run.
-- =====================================================================

-- Fuzzy text matching, used to skip duplicate events.
create extension if not exists pg_trgm with schema extensions;

-- Keeps updated_at current so the app's delta sync can pull changes.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- events: what users see in the Events tab (only approved rows).
-- Staple yearly events/holidays are hardcoded in the app, not stored here.
-- ---------------------------------------------------------------------
create table if not exists public.events (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  description  text,
  category     text not null default 'other'
               check (category in ('concert', 'festival', 'food', 'culture', 'holiday', 'other')),
  starts_at    timestamptz not null,
  ends_at      timestamptz,
  venue        text,
  lat          double precision,
  lng          double precision,
  organizer    text,
  source_url   text,
  price        text,
  ticket_link  text,
  ai_found     boolean not null default false,
  verified_by  text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  is_deleted   boolean not null default false
);

create index if not exists events_starts_at_idx on public.events (starts_at);
create index if not exists events_updated_at_idx on public.events (updated_at);

drop trigger if exists events_set_updated_at on public.events;
create trigger events_set_updated_at
  before update on public.events
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- events_pending: every post the events-ingest function looked at.
-- status:
--   pending      -> AI thinks it is an Iloilo event; waiting for admin
--   approved     -> admin approved; trigger below copies it into events
--   rejected     -> admin rejected
--   not_event    -> AI said it is not an Iloilo event (kept so the same
--                   post is not sent to Gemini again)
--   duplicate    -> same event already exists
--   out_of_range -> event is not in this month or next month
-- ---------------------------------------------------------------------
create table if not exists public.events_pending (
  id           uuid primary key default gen_random_uuid(),
  raw_text     text not null,
  post_url     text not null unique,
  source       text,                 -- Facebook page name/URL
  posted_at    timestamptz,
  extracted    jsonb,                -- Gemini JSON output (admin may edit)
  confidence   real,
  dedupe_hash  text,
  status       text not null default 'pending'
               check (status in ('pending', 'approved', 'rejected', 'not_event', 'duplicate', 'out_of_range')),
  event_id     uuid references public.events (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists events_pending_status_idx on public.events_pending (status);
create unique index if not exists events_pending_dedupe_idx
  on public.events_pending (dedupe_hash)
  where dedupe_hash is not null and status in ('pending', 'approved');

drop trigger if exists events_pending_set_updated_at on public.events_pending;
create trigger events_pending_set_updated_at
  before update on public.events_pending
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Approval: when an admin changes status to 'approved' in the Table
-- Editor, copy the (possibly edited) extracted JSON into events.
-- ---------------------------------------------------------------------
create or replace function public.approve_pending_event()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  e         jsonb := coalesce(new.extracted, '{}'::jsonb);
  v_start   timestamptz;
  v_end     timestamptz;
  v_new_id  uuid;
begin
  if new.status = 'approved'
     and old.status is distinct from 'approved'
     and new.event_id is null then

    if coalesce(e->>'date', '') = '' then
      raise exception 'Cannot approve: extracted.date is empty. Edit the extracted JSON first.';
    end if;

    -- Dates/times from Gemini are local Iloilo time (Asia/Manila).
    v_start := ((e->>'date') || ' ' || coalesce(nullif(e->>'time', ''), '00:00'))::timestamp
               at time zone 'Asia/Manila';

    if coalesce(e->>'end_date', '') <> '' or coalesce(e->>'end_time', '') <> '' then
      v_end := (coalesce(nullif(e->>'end_date', ''), e->>'date') || ' ' ||
                coalesce(nullif(e->>'end_time', ''), '23:59'))::timestamp
               at time zone 'Asia/Manila';
    elsif coalesce(e->>'time', '') <> '' then
      v_end := v_start + interval '3 hours';
    else
      v_end := v_start + interval '1 day' - interval '1 minute';
    end if;

    insert into public.events (
      title, description, category, starts_at, ends_at, venue, organizer,
      source_url, price, ticket_link, ai_found, verified_by
    ) values (
      coalesce(nullif(e->>'title', ''), 'Untitled event'),
      e->>'description',
      case when e->>'category' in ('concert', 'festival', 'food', 'culture', 'holiday', 'other')
           then e->>'category' else 'other' end,
      v_start,
      v_end,
      e->>'venue',
      coalesce(nullif(e->>'organizer', ''), new.source),
      new.post_url,
      e->>'price',
      e->>'ticket_link',
      true,
      'admin (dashboard)'
    )
    returning id into v_new_id;

    new.event_id := v_new_id;
  end if;
  return new;
end;
$$;

drop trigger if exists events_pending_approve on public.events_pending;
create trigger events_pending_approve
  before update of status on public.events_pending
  for each row execute function public.approve_pending_event();

-- ---------------------------------------------------------------------
-- Duplicate check used by events-ingest: is there already an event with
-- a similar title on the same day (in events or the pending queue)?
-- ---------------------------------------------------------------------
create or replace function public.event_exists_similar(p_title text, p_date date)
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
  select exists (
           select 1 from public.events
           where not is_deleted
             and (starts_at at time zone 'Asia/Manila')::date = p_date
             and similarity(lower(title), lower(p_title)) > 0.5)
      or exists (
           select 1 from public.events_pending
           where status in ('pending', 'approved')
             and extracted->>'date' = p_date::text
             and similarity(lower(extracted->>'title'), lower(p_title)) > 0.5);
$$;

revoke execute on function public.event_exists_similar(text, date) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Row Level Security
-- * Everyone (guests included) can read events that are not deleted.
-- * No client can write events or see events_pending. Writes come from
--   the Edge Function (service role) and the dashboard.
-- TODO(admin): add admin write policies once `profiles.role` exists.
-- ---------------------------------------------------------------------
alter table public.events enable row level security;
alter table public.events_pending enable row level security;

drop policy if exists "Anyone can read published events" on public.events;
create policy "Anyone can read published events"
  on public.events for select
  to anon, authenticated
  using (not is_deleted);
