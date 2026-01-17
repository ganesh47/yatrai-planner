import type { JWTPayload } from "jose";
import type { KVNamespaceLike, Role } from "../types.js";
import { getRole, setRole } from "../rbac/roles.js";

export interface AdminHandlerDeps {
  kv: KVNamespaceLike;
  verifyToken: (token: string) => Promise<JWTPayload>;
}

export async function handleAdminSetRole(request: Request, deps: AdminHandlerDeps): Promise<Response> {
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

  const requesterRole: Role = await getRole(deps.kv, userId);
  if (requesterRole !== "admin") {
    return json({ error: "forbidden" }, 403);
  }

  let body: { user_id?: string; role?: Role } = {};
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  if (!body.user_id || !body.role) {
    return json({ error: "invalid_request" }, 422);
  }

  await setRole(deps.kv, body.user_id, body.role);
  return json({ ok: true }, 200);
}

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "content-type": "application/json" }
  });
}
