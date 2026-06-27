// Supabase Edge Function: delete-account
//
// Permanently deletes the calling user's auth record using the service-role key
// (server-side only — the key must NEVER ship in the app). The iOS client first
// deletes the user's own `progress` rows via the anon client, then invokes this
// function, then signs out.
//
// Deploy (Supabase CLI):
//   supabase functions deploy delete-account
// The SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided automatically in
// the Edge Function runtime environment.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  // Identify the caller from their bearer token (the anon-key session JWT).
  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "");
  if (!jwt) {
    return new Response(JSON.stringify({ error: "Missing Authorization bearer token" }), { status: 401 });
  }

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Resolve the user from their JWT so a caller can only delete *themselves*.
  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData?.user) {
    return new Response(JSON.stringify({ error: "Invalid session" }), { status: 401 });
  }

  const userId = userData.user.id;

  // Best-effort: remove the user's progress rows server-side too (defensive;
  // the client also deletes them before calling this).
  await admin.from("progress").delete().eq("user_id", userId);

  const { error: delErr } = await admin.auth.admin.deleteUser(userId);
  if (delErr) {
    return new Response(JSON.stringify({ error: delErr.message }), { status: 400 });
  }

  return new Response(JSON.stringify({ success: true }), { status: 200 });
});
