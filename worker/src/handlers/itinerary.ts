import type { JWTPayload } from "jose";
import type { KVNamespaceLike, Role } from "../types.js";
import { validateItineraryRequest } from "../validation/itinerary.js";
import type { OpenAIClient } from "../openai/client.js";
import { consumeItineraryQuota } from "../limits/quotas.js";
import { getRole } from "../rbac/roles.js";

export interface ItineraryHandlerDeps {
  kv: KVNamespaceLike;
  verifyToken: (token: string) => Promise<JWTPayload>;
  openaiClient: OpenAIClient;
}

export async function handleItineraryRequest(request: Request, deps: ItineraryHandlerDeps): Promise<Response> {
  const authHeader = request.headers.get("authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) {
    return json({ error: "missing_token" }, 401);
  }

  let payload: JWTPayload;
  try {
    payload = await deps.verifyToken(token);
  } catch {
    return json({ error: "invalid_token" }, 401);
  }

  const userId = payload.sub;
  if (!userId) {
    return json({ error: "invalid_token" }, 401);
  }

  const role: Role = await getRole(deps.kv, userId);
  const quota = await consumeItineraryQuota(deps.kv, userId, role);
  if (!quota.allowed) {
    return json({ error: "quota_exceeded" }, 429);
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const validation = validateItineraryRequest(body as Record<string, unknown>);
  if (!validation.ok) {
    return json({ error: "invalid_request", details: validation.errors }, 422);
  }

  try {
    const draft = await deps.openaiClient.createItinerary(body);
    return json({ draft, remaining: quota.remaining }, 200);
  } catch {
    return json({ error: "openai_unavailable" }, 502);
  }
}

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "content-type": "application/json" }
  });
}
