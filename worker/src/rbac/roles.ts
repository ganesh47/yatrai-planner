import type { KVNamespaceLike, Role } from "../types.js";

const ROLE_PREFIX = "role";
const ALLOWLIST_PREFIX = "allowlist";

export async function getRole(kv: KVNamespaceLike, userId: string): Promise<Role> {
  const value = await kv.get(`${ROLE_PREFIX}:${userId}`);
  if (value === "pro" || value === "admin") {
    return value;
  }
  return "free";
}

export async function setRole(kv: KVNamespaceLike, userId: string, role: Role): Promise<void> {
  await kv.put(`${ROLE_PREFIX}:${userId}`, role);
}

export async function ensureProRole(kv: KVNamespaceLike, userId: string): Promise<Role> {
  const key = `${ROLE_PREFIX}:${userId}`;
  const current = await kv.get(key);
  if (current === "admin" || current === "pro") {
    return current;
  }
  await kv.put(key, "pro");
  return "pro";
}

export async function isAllowlisted(kv: KVNamespaceLike, userId: string): Promise<boolean> {
  const value = await kv.get(`${ALLOWLIST_PREFIX}:${userId}`);
  if (!value) {
    return false;
  }
  return value === "1" || value === "true" || value === "allowed" || value === "yes";
}

export async function setAllowlistEntry(
  kv: KVNamespaceLike,
  userId: string,
  allowed = true
): Promise<void> {
  await kv.put(`${ALLOWLIST_PREFIX}:${userId}`, allowed ? "1" : "0");
}
