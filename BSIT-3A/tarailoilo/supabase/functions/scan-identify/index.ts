// supabase/functions/scan-identify/index.ts
//
// Identifies a dish or landmark from a photo with Gemini vision.
// Request:  { mode: "dish" | "landmark", image: <base64 JPEG>, lat?, lng?, heading? }
// Response: { guesses: [{ id | null, name, confidence, type }] }   (top 3, best first)
//
// Gemini identifies the photo, and `id` is set only when it matches an entry in
// your database. id = null means "identified, but we have no details for it".

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// TODO: change these if your table / column names differ.
const TABLES: Record<string, { table: string; id: string; name: string }> = {
  dish: { table: "dishes", id: "id", name: "name" },
  landmark: { table: "landmarks", id: "id", name: "name" },
};

const MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.6-flash";
const MAX_IMAGE_CHARS = 8_000_000; // ~6 MB of base64

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const { mode, image, lat, lng, heading } = await req.json();

    if (mode !== "dish" && mode !== "landmark") {
      return json({ error: "mode must be 'dish' or 'landmark'" }, 400);
    }
    if (typeof image !== "string" || image.length === 0 || image.length > MAX_IMAGE_CHARS) {
      return json({ error: "image missing or too large" }, 400);
    }

    const apiKey = Deno.env.get("SCAN_GEMINI_API_KEY");
    if (!apiKey) return json({ error: "server not configured" }, 500);

    // Candidate list from the database (runs as the calling user, so RLS applies).
    const cfg = TABLES[mode];
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } },
    );
    const { data: rows, error: dbError } = await supabase
      .from(cfg.table)
      .select(`${cfg.id}, ${cfg.name}`)
      .limit(500);
    if (dbError) {
      console.error("catalog error", dbError);
      return json({ error: "could not load catalog", detail: dbError.message }, 500);
    }

    const names = new Map<string, string>();
    for (const r of rows ?? []) names.set(String(r[cfg.id]), String(r[cfg.name]));
    const list = [...names].map(([id, name]) => `${id}: ${name}`).join("\n");
    const where = lat != null && lng != null
      ? `The photo was taken near latitude ${lat}, longitude ${lng}` +
        (heading != null ? `, facing compass heading ${Math.round(heading)} degrees.` : ".")
      : "";

    const prompt =
      `You identify a ${mode === "dish" ? "Filipino dish" : "landmark in Iloilo, Philippines"} ` +
      `from a photo. Return up to 3 most likely identifications, best first, each with ` +
      `an honest confidence from 0 to 1. The app has the entries listed below ` +
      `(format "id: name"). If an identification matches an entry, set id to that ` +
      `entry's id exactly; otherwise set id to an empty string and give the common name. ` +
      `If the photo is not a ${mode === "dish" ? "dish" : "landmark"} at all, return an ` +
      `empty guesses array. ${where}\n\nList:\n${list}`;

    const gemini = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
        body: JSON.stringify({
          contents: [{
            parts: [
              { text: prompt },
              { inline_data: { mime_type: "image/jpeg", data: image } },
            ],
          }],
          generationConfig: {
            temperature: 0.2,
            responseMimeType: "application/json",
            responseSchema: {
              type: "OBJECT",
              properties: {
                guesses: {
                  type: "ARRAY",
                  items: {
                    type: "OBJECT",
                    properties: {
                      id: { type: "STRING" },
                      name: { type: "STRING" },
                      confidence: { type: "NUMBER" },
                    },
                    required: ["id", "name", "confidence"],
                  },
                },
              },
              required: ["guesses"],
            },
          },
        }),
      },
    );

    if (!gemini.ok) {
      const detail = (await gemini.text()).slice(0, 400);
      console.error("gemini error", gemini.status, detail);
      return json({ error: "vision service unavailable", detail: `${gemini.status}: ${detail}` }, 502);
    }

    const result = await gemini.json();
    const text = result?.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}";
    const parsed = JSON.parse(text);

    const guesses = (parsed.guesses ?? [])
      .map((g: { id: string; name: string; confidence: number }) => {
        const id = names.has(String(g.id)) ? String(g.id) : null;
        return {
          id,
          name: id ? names.get(id)! : String(g.name ?? "").trim(),
          confidence: Math.min(1, Math.max(0, Number(g.confidence) || 0)),
          type: mode,
        };
      })
      .filter((g: { name: string }) => g.name.length > 0)
      .sort((a: { confidence: number }, b: { confidence: number }) => b.confidence - a.confidence)
      .slice(0, 3);

    return json({ guesses });
  } catch (e) {
    console.error(e);
    return json({ error: "scan failed" }, 500);
  }
});