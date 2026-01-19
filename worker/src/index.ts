import { verifyAppleIdentityToken } from "./auth/appleJwt.js";
import { handleAdminSetRole } from "./handlers/admin.js";
import { handleItineraryRequest } from "./handlers/itinerary.js";
import { createOpenAIClient } from "./openai/client.js";
import { ensureProRole } from "./rbac/roles.js";
import type { KVNamespaceLike } from "./types.js";

export interface Env {
  APPLE_AUDIENCE?: string;
  OPENAI_API_KEY?: string;
  RBAC_KV: KVNamespaceLike;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return json({ ok: true }, 200);
    }

    if (url.pathname === "/auth/verify" && request.method === "POST") {
      return handleAuthVerify(request, env);
    }

    if (url.pathname === "/itinerary" && request.method === "POST") {
      const openaiClient = createOpenAIClient(env.OPENAI_API_KEY ?? "");
      return handleItineraryRequest(request, {
        kv: env.RBAC_KV,
        verifyToken: (token) =>
          verifyAppleIdentityToken(token, {
            audience: env.APPLE_AUDIENCE ?? "",
            issuer: "https://appleid.apple.com"
          }),
        openaiClient
      });
    }

    if (url.pathname === "/admin/set-role" && request.method === "POST") {
      return handleAdminSetRole(request, {
        kv: env.RBAC_KV,
        verifyToken: (token) =>
          verifyAppleIdentityToken(token, {
            audience: env.APPLE_AUDIENCE ?? "",
            issuer: "https://appleid.apple.com"
          })
      });
    }

    return json({ error: "not_found" }, 404);
  }
};

async function handleAuthVerify(request: Request, env: Env): Promise<Response> {
  const authHeader = request.headers.get("authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) {
    return json({ error: "missing_token" }, 401);
  }

  const audience = env.APPLE_AUDIENCE ?? "";
  const issuer = "https://appleid.apple.com";
  try {
    const payload = await verifyAppleIdentityToken(token, { audience, issuer });
    if (!payload.sub) {
      return json({ error: "missing_sub" }, 401);
    }
    const role = await ensureProRole(env.RBAC_KV, payload.sub);
    return json({ sub: payload.sub, email: payload.email ?? null, role }, 200);
  } catch {
    return json({ error: "invalid_token" }, 401);
  }
}

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "content-type": "application/json" }
  });
}
