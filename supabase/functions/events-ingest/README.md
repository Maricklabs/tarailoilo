# events-ingest — setup with the Supabase Dashboard only

Finds Iloilo events in Facebook posts every morning, has Gemini extract the
details, and queues them in `events_pending` for admin approval.

```
6:00 AM  pg_cron -> events-ingest?step=start    -> Apify scrapes 7 Facebook pages
6:30 AM  pg_cron -> events-ingest?step=process  -> Gemini extracts -> events_pending
6:50 AM  pg_cron -> events-ingest?step=process  -> leftovers (max 16 posts per run)
You      Table Editor: events_pending.status = 'approved' -> trigger copies it to events
App      Events tab shows it with the "AI-found, admin-verified" badge
```

## 1. Create the tables

SQL Editor -> New query -> paste `supabase/migrations/20261124000000_events.sql` -> **Run**.

## 2. Add the function secrets

Edge Functions -> **Secrets** -> add each name/value, then Save:

| Name | Value |
|---|---|
| `APIFY_TOKEN` | your Apify API token |
| `GEMINI_API_KEY` | your Gemini API key |
| `CRON_SECRET` | the value from step 3 |
| `GEMINI_MODEL` (optional) | default `gemini-3.5-flash` |
| `GEMINI_FALLBACK_MODEL` (optional) | default `gemini-3.5-flash-lite` |
| `APIFY_RESULTS_PER_PAGE` (optional) | default `3` |

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` already exist; do not add them.
Never put these values in the Flutter app, `.env`, or git.

## 3. Create the cron secret in Vault

SQL Editor -> run:

```sql
select vault.create_secret(encode(extensions.gen_random_bytes(24), 'hex'), 'events_ingest_cron_secret');
select decrypted_secret from vault.decrypted_secrets where name = 'events_ingest_cron_secret';
```

Copy the value shown by the second query into the `CRON_SECRET` function
secret (step 2).

## 4. Deploy the function

1. Edge Functions -> **Deploy a new function** -> **Via Editor**.
2. Name it exactly `events-ingest`.
3. Replace the sample code with the whole `index.ts` from this folder.
4. **Deploy function**.
5. Open the function -> **Details** -> turn **OFF** "Verify JWT with legacy
   secret" (also called "Enforce JWT verification"). The function checks
   `x-cron-secret` itself, so pg_cron does not need a JWT.

## 5. Test it once by hand

Open the function -> **Test** (or use any HTTP client):

- Method `POST`, URL query `step=start`, header `x-cron-secret: <your CRON_SECRET>`
  -> returns `{ ok: true, apify: { runId, status } }`.
- Wait 3-5 minutes for Apify to finish (check apify.com -> Runs).
- Same request with `step=process` -> returns `202`. Open **Logs** and look
  for `events-ingest process: {...counts...}`.
- Table Editor -> `events_pending` now has rows.

## 6. Schedule it daily

SQL Editor -> paste `supabase/migrations/20261124000100_events_ingest_cron.sql` -> **Run**.
Check: Integrations -> Cron -> Jobs shows the three `events-ingest` jobs.

## 7. Approving events (admin)

Table Editor -> `events_pending` -> filter `status = pending`.

- Read `raw_text` and open `post_url`.
- If needed, fix the `extracted` JSON (title, date `YYYY-MM-DD`, time `HH:MM`,
  venue, category: concert | festival | food | culture | holiday | other).
- Set `status` to `approved` -> a new row appears in `events`, and
  `event_id` is filled in. Or set `rejected`.

Approved events show in the app after a pull-to-refresh on the Events tab.

## Costs and limits

- Apify free plan: $5/month credit. A test run of 2 posts x 7 pages cost
  about $0.09 (11 posts returned), so the default 3 posts/page daily may use
  most of the credit. Watch apify.com -> Usage the first week; lower
  `APIFY_RESULTS_PER_PAGE` or remove pages if needed.
- Gemini free tier often answers "503 high demand"; the function retries
  with a fallback model, and unprocessed posts are retried on the next run.
- Meta's terms restrict automated scraping. We keep volume low, store only
  the post text and link (no images), credit the source, and always require
  admin approval. Note this in Known Limitations.

## Local test (no database)

```powershell
$env:GEMINI_API_KEY="<key>"; node supabase/functions/events-ingest/test-extract.mjs
$env:APIFY_TOKEN="<token>"; node supabase/functions/events-ingest/test-extract.mjs --live
```
