import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY");

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const authHeader = req.headers.get("Authorization");
  const expectedSecret = `Bearer ${Deno.env.get("FCM_PUSH_SECRET")}`;
  if (authHeader !== expectedSecret) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { user_id, title, body, meal_id, type } = await req.json();

  // Fetch all device tokens for the user
  const { data: tokens, error } = await supabase
    .from("device_tokens")
    .select("token, platform")
    .eq("user_id", user_id);

  if (error || !tokens || tokens.length === 0) {
    return new Response(JSON.stringify({ sent: 0 }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const results = await Promise.all(
    tokens.map(async ({ token, platform }) => {
      const message: Record<string, unknown> = {
        notification: { title, body },
        data: { meal_id: meal_id ?? "", type: type ?? "" },
        token,
      };

      if (platform === "ios") {
        message.apns = {
          payload: {
            aps: {
              badge: 1,
              sound: "default",
            },
          },
        };
      }

      const res = await fetch(
        `https://fcm.googleapis.com/fcm/send`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `key=${FCM_SERVER_KEY}`,
          },
          body: JSON.stringify(message),
        },
      );

      return { token, ok: res.ok };
    }),
  );

  // Delete invalid tokens
  const invalidTokens = results
    .filter((r) => !r.ok)
    .map((r) => r.token);

  if (invalidTokens.length > 0) {
    await supabase
      .from("device_tokens")
      .delete()
      .in("token", invalidTokens);
  }

  return new Response(
    JSON.stringify({ sent: results.filter((r) => r.ok).length }),
    { headers: { "Content-Type": "application/json" } },
  );
});
