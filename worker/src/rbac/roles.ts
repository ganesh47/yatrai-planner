import type { KVNamespaceLike, Role } from "../types.js";

const ROLE_PREFIX = "role";

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
