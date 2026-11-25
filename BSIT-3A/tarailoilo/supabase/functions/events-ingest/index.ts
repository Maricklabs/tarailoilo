// =====================================================================
// events-ingest — daily AI event discovery for the TaraIlo Events tab.
//
// Flow (PROJECT_PROMPT.md section 8):
//   step=start   : start the Apify Facebook posts scraper for our page list.
//   step=process : read the finished scrape, ask Gemini (JSON schema) which
//                  posts announce Iloilo events, drop events outside this
//                  month/next month, skip duplicates, and save everything in
//                  `events_pending`. An admin approves rows in the Supabase
//                  Table Editor; a database trigger then copies them into
//                  `events`. Nothing reaches users without that approval.
//
// Called by pg_cron (see migrations/20261124000100_events_ingest_cron.sql)
// with the header `x-cron-secret`.
//
// Secrets (Dashboard -> Edge Functions -> Secrets), never in git:
//   APIFY_TOKEN, GEMINI_API_KEY, CRON_SECRET
//   optional: GEMINI_MODEL, GEMINI_FALLBACK_MODEL, APIFY_RESULTS_PER_PAGE
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided automatically.
//
// The file has no imports so it can be pasted into the dashboard editor
// as-is and also be tested locally with Node (see test-extract.mjs).
// =====================================================================

/** Facebook pages to watch. Keep this list short (cost + Meta's terms). */
export const FACEBOOK_PAGES = [
  "https://www.facebook.com/iloilocitygov",
  "https://www.facebook.com/aksyonradyoiloilo720",
  "https://www.facebook.com/IBPofficial",
  "https://www.facebook.com/smcityiloilo",
  "https://www.facebook.com/FestiveWalkIloilo",
  "https://www.facebook.com/GMARegionalTV",
  "https://www.facebook.com/iloilomusicscenes",
];

const APIFY_ACTOR = "apify~facebook-posts-scraper";
// The app-facing AI features use ~15 s. This is a background job and Gemini's
// free tier is slow under load, so each batch call gets 30 s.
const AI_TIMEOUT_MS = 30_000;
const POSTS_PER_GEMINI_CALL = 8;
// Keeps one run under the free-plan Edge Function limit (150 s). Posts not
// processed in this run are picked up by the second cron run (or tomorrow).
const MAX_POSTS_PER_RUN = 16;
const CATEGORIES = ["concert", "festival", "food", "culture", "holiday", "other"];

// ---------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------

/** Reads a secret/env var in Deno (Supabase) or Node (local test). */
export function env(name: string, fallback = ""): string {
  // deno-lint-ignore no-explicit-any
  const g = globalThis as any;
  const value = g.Deno?.env?.get(name) ?? g.process?.env?.[name];
  return value ?? fallback;
}

/** fetch() that gives up after `ms` milliseconds. */
async function fetchWithTimeout(url: string, init: RequestInit, ms: number): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), ms);
  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
}

/** Today's date in Iloilo as YYYY-MM-DD. */
export function manilaToday(now = new Date()): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Manila" }).format(now);
}

/** First day of this month and last day of next month (YYYY-MM-DD). */
export function allowedWindow(today: string): { from: string; to: string } {
  const [y, m] = today.split("-").map(Number);
  const from = `${y}-${String(m).padStart(2, "0")}-01`;
  const lastOfNext = new Date(Date.UTC(y, m + 1, 0)); // day 0 of month m+2 = last day of m+1
  return { from, to: lastOfNext.toISOString().slice(0, 10) };
}

/** SHA-256 of title + date + venue, used to spot exact duplicates. */
export async function dedupeHash(title: string, date: string, venue: string | null): Promise<string> {
  const text = `${title}|${date}|${venue ?? ""}`.toLowerCase().replace(/\s+/g, " ").trim();
  const bytes = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(bytes)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

// ---------------------------------------------------------------------
// Apify (Facebook posts)
// ---------------------------------------------------------------------

export type Post = { text: string; url: string; source: string; postedAt: string | null };

/** Starts the scraper run. Apify keeps it as the actor's "last run". */
export async function startScrape(): Promise<unknown> {
  const since = new Date(Date.now() - 2 * 24 * 3600 * 1000).toISOString().slice(0, 10);
  const input = {
    startUrls: FACEBOOK_PAGES.map((url) => ({ url })),
    resultsLimit: Number(env("APIFY_RESULTS_PER_PAGE", "3")),
    onlyPostsNewerThan: since, // daily run + 1 day overlap
  };
  const res = await fetch(`https://api.apify.com/v2/acts/${APIFY_ACTOR}/runs`, {
    method: "POST",
    headers: { Authorization: `Bearer ${env("APIFY_TOKEN")}`, "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
  if (!res.ok) throw new Error(`Apify start failed: ${res.status} ${await res.text()}`);
  const json = await res.json();
  return { runId: json.data?.id, status: json.data?.status };
}

/** Reads the posts from the last successful scraper run. */
export async function fetchLastRunPosts(): Promise<Post[]> {
  const url = `https://api.apify.com/v2/acts/${APIFY_ACTOR}/runs/last/dataset/items?status=SUCCEEDED&clean=true&format=json`;
  const res = await fetch(url, { headers: { Authorization: `Bearer ${env("APIFY_TOKEN")}` } });
  if (!res.ok) throw new Error(`Apify dataset failed: ${res.status} ${await res.text()}`);
  const items = (await res.json()) as Record<string, unknown>[];
  return items.map(normalizePost).filter((p): p is Post => p !== null);
}

/** Converts one Apify item into our Post shape (field names vary a bit). */
export function normalizePost(item: Record<string, unknown>): Post | null {
  const text = String(item.text ?? item.postText ?? "").trim();
  const url = String(item.url ?? item.postUrl ?? item.topLevelUrl ?? "").trim();
  if (text.length < 30 || !url) return null; // too short to describe an event
  // deno-lint-ignore no-explicit-any
  const user = item.user as any;
  const source = String(item.pageName ?? user?.name ?? item.facebookUrl ?? "Facebook");
  const postedAt = item.time ? String(item.time) : null;
  return { text: text.slice(0, 2500), url, source, postedAt };
}

// ---------------------------------------------------------------------
// Gemini extraction (JSON structured output)
// ---------------------------------------------------------------------

export type Extraction = {
  post_index: number;
  is_event: boolean;
  is_iloilo: boolean;
  title: string | null;
  description: string | null;
  artist: string | null;
  category: string;
  date: string | null; // YYYY-MM-DD (Asia/Manila)
  time: string | null; // HH:MM 24h
  end_date: string | null;
  end_time: string | null;
  venue: string | null;
  organizer: string | null;
  price: string | null;
  ticket_link: string | null;
  confidence: number;
};

const nullableString = { type: "STRING", nullable: true };

/** The exact JSON shape Gemini must return (one object per post). */
const RESPONSE_SCHEMA = {
  type: "ARRAY",
  items: {
    type: "OBJECT",
    properties: {
      post_index: { type: "INTEGER" },
      is_event: { type: "BOOLEAN" },
      is_iloilo: { type: "BOOLEAN" },
      title: nullableString,
      description: nullableString,
      artist: nullableString,
      category: { type: "STRING", enum: CATEGORIES },
      date: nullableString,
      time: nullableString,
      end_date: nullableString,
      end_time: nullableString,
      venue: nullableString,
      organizer: nullableString,
      price: nullableString,
      ticket_link: nullableString,
      confidence: { type: "NUMBER" },
    },
    required: ["post_index", "is_event", "is_iloilo", "category", "confidence"],
  },
};

function systemPrompt(today: string): string {
  return [
    "You extract public event announcements from Facebook posts by pages in Iloilo, Philippines.",
    `Today is ${today} (Asia/Manila). Posts may be in English, Filipino, or Hiligaynon.`,
    "Return exactly one object per post, using its post_index.",
    "is_event = true only if the post announces a specific upcoming public event people can attend",
    "(concert, band or celebrity visit, festival, fair, food event, cultural show, exhibit, parade).",
    "News reports, store sales and promos, ads without a date, past-event recaps, job posts,",
    "and weather/traffic updates are not events.",
    "is_iloilo = true only if the event happens in Iloilo City or Iloilo Province.",
    "Resolve relative dates (\"this Saturday\", \"bukas\") using the post date. Use YYYY-MM-DD and 24h HH:MM.",
    "Use null for anything the post does not say. Never invent venues, prices, or links.",
    "title: short English event name. description: 1-2 sentence English summary.",
    "confidence: 0 to 1, how sure you are that the extracted event details are correct.",
  ].join("\n");
}

/** Calls one Gemini model once. Throws on timeout or HTTP error. */
async function callGemini(model: string, today: string, posts: Post[]): Promise<Extraction[]> {
  const userText = JSON.stringify(
    posts.map((p, i) => ({ post_index: i, page: p.source, posted_at: p.postedAt, text: p.text })),
  );
  const res = await fetchWithTimeout(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: { "x-goog-api-key": env("GEMINI_API_KEY"), "Content-Type": "application/json" },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: systemPrompt(today) }] },
        contents: [{ role: "user", parts: [{ text: userText }] }],
        generationConfig: {
          temperature: 0.1,
          responseMimeType: "application/json",
          responseSchema: RESPONSE_SCHEMA,
        },
      }),
    },
    AI_TIMEOUT_MS,
  );
  if (!res.ok) throw new Error(`Gemini ${model} ${res.status}: ${(await res.text()).slice(0, 200)}`);
  const json = await res.json();
  const text = json.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("") ?? "[]";
  return JSON.parse(text) as Extraction[];
}

/**
 * Sends posts to Gemini in small batches. Each batch tries the main model,
 * then the fallback model, then the main model again after a short pause
 * (the free tier often answers "503 high demand"). A batch that still fails
 * is skipped; its posts were not saved, so the next daily run retries them.
 */
export async function extractEvents(posts: Post[], today: string): Promise<{ post: Post; result: Extraction }[]> {
  const main = env("GEMINI_MODEL", "gemini-3.5-flash");
  const fallback = env("GEMINI_FALLBACK_MODEL", "gemini-3.5-flash-lite");
  const attempts = [main, fallback, main];
  const out: { post: Post; result: Extraction }[] = [];

  for (let i = 0; i < posts.length; i += POSTS_PER_GEMINI_CALL) {
    const batch = posts.slice(i, i + POSTS_PER_GEMINI_CALL);
    let results: Extraction[] | null = null;
    for (let a = 0; a < attempts.length && !results; a++) {
      if (a > 0) await new Promise((r) => setTimeout(r, 3000 * a)); // back off
      try {
        results = await callGemini(attempts[a], today, batch);
      } catch (err) {
        console.warn(`Batch ${i / POSTS_PER_GEMINI_CALL}, try ${a + 1}: ${String(err).slice(0, 120)}`);
      }
    }
    if (!results) continue;
    for (const r of results) {
      const post = batch[r.post_index];
      if (post) out.push({ post, result: r });
    }
  }
  return out;
}

/** Decides the events_pending status for one AI result (no database). */
export function classify(r: Extraction, window: { from: string; to: string }): "pending" | "not_event" | "out_of_range" {
  if (!r.is_event || !r.is_iloilo || !r.title || !r.date || !/^\d{4}-\d{2}-\d{2}$/.test(r.date)) {
    return "not_event";
  }
  if (r.date < window.from || r.date > window.to) return "out_of_range";
  return "pending";
}

// ---------------------------------------------------------------------
// Supabase (PostgREST over fetch, service role)
// ---------------------------------------------------------------------

function dbHeaders(extra: Record<string, string> = {}): Record<string, string> {
  const key = env("SUPABASE_SERVICE_ROLE_KEY");
  const headers: Record<string, string> = { apikey: key, "Content-Type": "application/json", ...extra };
  if (key.startsWith("eyJ")) headers.Authorization = `Bearer ${key}`; // legacy JWT key
  return headers;
}

async function db(path: string, init: RequestInit = {}): Promise<Response> {
  return await fetch(`${env("SUPABASE_URL")}/rest/v1/${path}`, {
    ...init,
    headers: { ...dbHeaders(), ...(init.headers as Record<string, string> ?? {}) },
  });
}

/** Post URLs we already processed, so Gemini never sees a post twice. */
async function alreadySeen(urls: string[]): Promise<Set<string>> {
  if (urls.length === 0) return new Set();
  const list = urls.map((u) => `"${u.replace(/"/g, "")}"`).join(",");
  const res = await db(`events_pending?select=post_url&post_url=in.(${encodeURIComponent(list)})`);
  if (!res.ok) throw new Error(`Read events_pending failed: ${res.status} ${await res.text()}`);
  const rows = (await res.json()) as { post_url: string }[];
  return new Set(rows.map((r) => r.post_url));
}

async function similarExists(title: string, date: string): Promise<boolean> {
  const res = await db("rpc/event_exists_similar", {
    method: "POST",
    body: JSON.stringify({ p_title: title, p_date: date }),
  });
  if (!res.ok) throw new Error(`Similarity check failed: ${res.status} ${await res.text()}`);
  return (await res.json()) === true;
}

async function insertPending(row: Record<string, unknown>): Promise<boolean> {
  const res = await db("events_pending?on_conflict=post_url", {
    method: "POST",
    headers: { Prefer: "resolution=ignore-duplicates,return=minimal" },
    body: JSON.stringify(row),
  });
  if (res.status === 409) return false; // same dedupe_hash already pending
  if (!res.ok) throw new Error(`Insert failed: ${res.status} ${await res.text()}`);
  return true;
}

// ---------------------------------------------------------------------
// The two steps
// ---------------------------------------------------------------------

export async function processLatestScrape(): Promise<Record<string, number>> {
  const today = manilaToday();
  const window = allowedWindow(today);
  const counts: Record<string, number> = { scraped: 0, new: 0, pending: 0, not_event: 0, out_of_range: 0, duplicate: 0 };

  const posts = await fetchLastRunPosts();
  counts.scraped = posts.length;
  const seen = await alreadySeen(posts.map((p) => p.url));
  const fresh = posts.filter((p) => !seen.has(p.url)).slice(0, MAX_POSTS_PER_RUN);
  counts.new = fresh.length;

  const hashesThisRun = new Set<string>();
  for (const { post, result } of await extractEvents(fresh, today)) {
    let status: string = classify(result, window);
    let hash: string | null = null;

    if (status === "pending") {
      hash = await dedupeHash(result.title!, result.date!, result.venue);
      if (hashesThisRun.has(hash) || (await similarExists(result.title!, result.date!))) {
        status = "duplicate";
        hash = null;
      }
    }

    const row = {
      raw_text: post.text,
      post_url: post.url,
      source: post.source,
      posted_at: post.postedAt,
      extracted: result,
      confidence: result.confidence,
      dedupe_hash: hash,
      status,
    };
    let saved = await insertPending(row);
    if (!saved) {
      // Exact duplicate of an event already pending/approved.
      status = "duplicate";
      saved = await insertPending({ ...row, dedupe_hash: null, status });
    }
    if (hash) hashesThisRun.add(hash);
    counts[status] = (counts[status] ?? 0) + 1;
  }
  console.log("events-ingest process:", JSON.stringify(counts));
  return counts;
}

/** HTTP entry point used by pg_cron (and the dashboard "Test" button). */
export async function handler(req: Request): Promise<Response> {
  const secret = env("CRON_SECRET");
  if (!secret || req.headers.get("x-cron-secret") !== secret) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401 });
  }
  const step = new URL(req.url).searchParams.get("step") ?? "process";
  try {
    if (step === "start") {
      return Response.json({ ok: true, step, apify: await startScrape() });
    }
    if (step === "process") {
      const job = processLatestScrape().catch((err) => console.error("process failed:", err));
      // Answer pg_cron right away and keep working in the background.
      // deno-lint-ignore no-explicit-any
      const runtime = (globalThis as any).EdgeRuntime;
      if (runtime?.waitUntil) {
        runtime.waitUntil(job);
        return Response.json({ ok: true, step, status: "processing in background" }, { status: 202 });
      }
      await job;
      return Response.json({ ok: true, step });
    }
    return Response.json({ error: `unknown step '${step}'` }, { status: 400 });
  } catch (err) {
    console.error(err);
    return Response.json({ ok: false, error: String(err) }, { status: 500 });
  }
}

// Only start the HTTP server on Supabase (Deno), not in local Node tests.
// deno-lint-ignore no-explicit-any
const deno = (globalThis as any).Deno;
if (deno?.serve) deno.serve(handler);
