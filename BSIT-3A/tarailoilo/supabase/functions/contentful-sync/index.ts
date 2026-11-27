// supabase/functions/contentful-sync/index.ts
//
// Copies PUBLISHED Contentful entries (content types `dish` and `landmark`)
// into the Supabase tables `dishes` and `landmarks`.
// Contentful is the source of truth: each sync overwrites the synced columns.
//
// Call it with:  POST /functions/v1/contentful-sync        header: x-sync-secret
//                POST /functions/v1/contentful-sync?prune=true   (also delete rows
//                that no longer exist in Contentful)
//
// Secrets: CONTENTFUL_SPACE_ID, CONTENTFUL_DELIVERY_TOKEN, SYNC_SECRET
// Optional: CONTENTFUL_ENVIRONMENT (default "master")
// Deploy with --no-verify-jwt (Contentful's webhook has no Supabase login):
//   npx supabase functions deploy contentful-sync --no-verify-jwt

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Entry = { sys: { id: string }; fields: Record<string, any> };

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

async function fetchEntries(type: string) {
  const space = Deno.env.get("CONTENTFUL_SPACE_ID");
  const token = Deno.env.get("CONTENTFUL_DELIVERY_TOKEN");
  const env = Deno.env.get("CONTENTFUL_ENVIRONMENT") ?? "master";
  if (!space || !token) throw new Error("Contentful secrets are not set");

  const url =
    `https://cdn.contentful.com/spaces/${space}/environments/${env}/entries` +
    `?content_type=${type}&include=2&limit=1000`;
  const res = await fetch(url, { headers: { Authorization: `Bearer ${token}` } });
  if (!res.ok) throw new Error(`contentful ${res.status}: ${(await res.text()).slice(0, 300)}`);
  const body = await res.json();

  const assets = new Map<string, string>();
  for (const a of body.includes?.Asset ?? []) {
    const u: string | undefined = a.fields?.file?.url;
    if (u) assets.set(a.sys.id, u.startsWith("//") ? `https:${u}` : u);
  }
  return { items: (body.items ?? []) as Entry[], assets };
}

const imageOf = (e: Entry, assets: Map<string, string>) => {
  const id = e.fields.image?.sys?.id;
  return id ? assets.get(id) ?? null : null;
};

const text = (v: unknown) => (typeof v === "string" ? v : "");

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const expected = Deno.env.get("SYNC_SECRET");
  if (!expected || req.headers.get("x-sync-secret") !== expected) {
    return json({ error: "unauthorized" }, 401);
  }
  const prune = new URL(req.url).searchParams.get("prune") === "true";

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const [dishSrc, landmarkSrc] = await Promise.all([
      fetchEntries("dish"),
      fetchEntries("landmark"),
    ]);

    const skipped: string[] = [];

    const dishRows = dishSrc.items.flatMap((e) => {
      const f = e.fields;
      if (!f.slug || !f.name) { skipped.push(`dish ${e.sys.id}`); return []; }
      return [{
        id: String(f.slug),
        name: text(f.name),
        tagline: text(f.tagline),
        description: text(f.description),
        origin: text(f.origin),
        ingredients: Array.isArray(f.ingredients) ? f.ingredients.map(String) : [],
        image_url: imageOf(e, dishSrc.assets),
        is_iloilo_favorite: f.isIloiloFavorite === true,
      }];
    });

    const landmarkRows = landmarkSrc.items.flatMap((e) => {
      const f = e.fields;
      if (!f.slug || !f.name) { skipped.push(`landmark ${e.sys.id}`); return []; }
      return [{
        id: String(f.slug),
        name: text(f.name),
        description: text(f.description),
        history: text(f.history),
        image_url: imageOf(e, landmarkSrc.assets),
        latitude: f.location?.lat ?? null,
        longitude: f.location?.lon ?? null,
      }];
    });

    if (dishRows.length) {
      const { error } = await supabase.from("dishes").upsert(dishRows, { onConflict: "id" });
      if (error) throw new Error(`dishes: ${error.message}`);
    }
    if (landmarkRows.length) {
      const { error } = await supabase.from("landmarks").upsert(landmarkRows, { onConflict: "id" });
      if (error) throw new Error(`landmarks: ${error.message}`);
    }

    // Optional: remove rows that are no longer published in Contentful.
    // Never runs when Contentful returned nothing, to protect against a bad fetch.
    let pruned = 0;
    if (prune) {
      for (const [table, rows] of [["dishes", dishRows], ["landmarks", landmarkRows]] as const) {
        if (rows.length === 0) continue;
        const keep = rows.map((r) => `"${r.id}"`).join(",");
        const { data, error } = await supabase
          .from(table).delete().not("id", "in", `(${keep})`).select("id");
        if (error) throw new Error(`prune ${table}: ${error.message}`);
        pruned += data?.length ?? 0;
      }
    }

    return json({
      dishes: dishRows.length,
      landmarks: landmarkRows.length,
      pruned,
      skipped,
    });
  } catch (e) {
    console.error(e);
    return json({ error: String(e instanceof Error ? e.message : e) }, 500);
  }
});