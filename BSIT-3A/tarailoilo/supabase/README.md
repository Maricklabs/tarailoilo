# Supabase

- `migrations/` — SQL schema, RLS policies and pg_cron jobs (PROJECT_PROMPT.md section 6).
- `functions/` — Deno/TypeScript Edge Functions (section 7):
  `gemini-chat`, `scan-identify`, `auth-guard`, `events-ingest`, `admin-users`.

Secrets (Gemini, Apify, webhook secret) are set with
`supabase secrets set NAME=value` and are **never** committed.
The phrasebook reads published entries directly from Contentful's Delivery API.
