import type { KVNamespaceLike, Role } from "../types.js";

const QUOTA_PREFIX = "quota";

export interface QuotaStatus {
  allowed: boolean;
  remaining: number | null;
}

export async function consumeItineraryQuota(
  kv: KVNamespaceLike,
  userId: string,
  role: Role,
  date: Date = new Date(),
  freeLimit: number = 2
): Promise<QuotaStatus> {
  if (role === "pro" || role === "admin") {
    return { allowed: true, remaining: null };
  }

  const key = `${QUOTA_PREFIX}:${userId}:${dateKey(date)}`;
  const currentRaw = await kv.get(key);
  const current = currentRaw ? Number(currentRaw) : 0;
  if (current >= freeLimit) {
    return { allowed: false, remaining: 0 };
  }

  const next = current + 1;
  await kv.put(key, String(next));
  return { allowed: true, remaining: Math.max(0, freeLimit - next) };
}

function dateKey(date: Date): string {
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, "0");
  const day = String(date.getUTCDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}
