-- =====================================================================
-- Daily schedule for the events-ingest Edge Function (pg_cron + pg_net).
-- Run AFTER the events-ingest function is deployed and the
-- events_ingest_cron_secret exists in Vault (see
-- supabase/functions/events-ingest/README.md, steps 1-4).
-- Safe to re-run.
--
-- Jobs (times are UTC; Manila = UTC+8):
--   22:00 UTC = 6:00 AM Manila -> step=start   (starts the Apify scraper)
--   22:30 UTC = 6:30 AM Manila -> step=process (Gemini extraction + queue)
--   22:50 UTC = 6:50 AM Manila -> step=process (handles any posts left over;
--                                  each run processes at most 16 new posts)
-- =====================================================================

create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Remove old versions of the jobs so re-running this file is safe.
select cron.unschedule(jobname)
from cron.job
where jobname in ('events-ingest-start', 'events-ingest-process', 'events-ingest-process-2');

select cron.schedule(
  'events-ingest-start',
  '0 22 * * *',
  $$
  select net.http_post(
    url     := 'https://uroohjoblcmrsanufkqs.supabase.co/functions/v1/events-ingest?step=start',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets
                        where name = 'events_ingest_cron_secret')
    ),
    body    := '{}'::jsonb,
    timeout_milliseconds := 30000
  );
  $$
);

select cron.schedule(
  'events-ingest-process',
  '30 22 * * *',
  $$
  select net.http_post(
    url     := 'https://uroohjoblcmrsanufkqs.supabase.co/functions/v1/events-ingest?step=process',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets
                        where name = 'events_ingest_cron_secret')
    ),
    body    := '{}'::jsonb,
    timeout_milliseconds := 30000
  );
  $$
);

select cron.schedule(
  'events-ingest-process-2',
  '50 22 * * *',
  $$
  select net.http_post(
    url     := 'https://uroohjoblcmrsanufkqs.supabase.co/functions/v1/events-ingest?step=process',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets
                        where name = 'events_ingest_cron_secret')
    ),
    body    := '{}'::jsonb,
    timeout_milliseconds := 30000
  );
  $$
);
