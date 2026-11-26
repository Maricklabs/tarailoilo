// Local check of the Gemini extraction step (no database, no Apify).
//
// Run from the repo root (Node 22.18+ / 24):
//   PowerShell:  $env:GEMINI_API_KEY="<your key>"; node supabase/functions/events-ingest/test-extract.mjs
// Add --live to also read the last real Apify scrape (needs $env:APIFY_TOKEN).
//
// Never commit your keys. This script reads them only from the environment.
import {
  allowedWindow,
  classify,
  extractEvents,
  fetchLastRunPosts,
  manilaToday,
} from "./index.ts";

const today = manilaToday();
const window = allowedWindow(today);

/** Hand-written sample posts covering the main cases. */
const samplePosts = [
  {
    source: "Festive Walk Iloilo",
    url: "https://facebook.com/sample/1",
    postedAt: `${today}T09:00:00+08:00`,
    text: "GOOD VIBES THIS SATURDAY! 🎸 Join us for an acoustic night with local band Kuyaw Band at the Festive Walk Parade, 7PM onwards. Free admission! See you, Ilonggos!",
  },
  {
    source: "Iloilo City Government",
    url: "https://facebook.com/sample/2",
    postedAt: `${today}T08:00:00+08:00`,
    text: "ADVISORY: Mayor's office reminds residents to clean their drainage canals ahead of the rainy days. Salamat sa inyo kooperasyon!",
  },
  {
    source: "SM City Iloilo",
    url: "https://facebook.com/sample/3",
    postedAt: `${today}T10:00:00+08:00`,
    text: "Food lovers! The Ilonggo Food Fair is happening at SM City Iloilo Event Center, next Friday to Sunday, 10AM to 9PM. Taste batchoy, pancit molo and KBL from 30 local stalls.",
  },
  {
    source: "GMA Regional TV",
    url: "https://facebook.com/sample/4",
    postedAt: `${today}T07:00:00+08:00`,
    text: "Concert sa Cebu City ang Ben&Ben sa sunod nga bulan sa Waterfront Hotel. Tickets available sa SM Tickets.",
  },
];

const posts = process.argv.includes("--live") ? await fetchLastRunPosts() : samplePosts;
console.log(`Today ${today}, allowed window ${window.from}..${window.to}, ${posts.length} posts\n`);

const started = Date.now();
const results = await extractEvents(posts, today);
for (const { post, result } of results) {
  console.log(`[${classify(result, window)}] ${post.source}: ${result.title ?? "-"} | ${result.date ?? "-"} ${result.time ?? ""} | ${result.venue ?? "-"} | ${result.category} | conf ${result.confidence}`);
}
console.log(`\n${results.length}/${posts.length} posts extracted in ${((Date.now() - started) / 1000).toFixed(1)} s`);
