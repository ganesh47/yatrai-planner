import { describe, expect, it } from "vitest";
import { MemoryKV } from "./helpers/memoryKv.js";
import { consumeItineraryQuota } from "../src/limits/quotas.js";

describe("quota enforcement", () => {
  it("allows two free requests per day", async () => {
    const kv = new MemoryKV();
    const date = new Date("2026-01-23T00:00:00Z");

    const first = await consumeItineraryQuota(kv, "user-1", "free", date, 2);
    const second = await consumeItineraryQuota(kv, "user-1", "free", date, 2);
    const third = await consumeItineraryQuota(kv, "user-1", "free", date, 2);

    expect(first.allowed).toBe(true);
    expect(second.allowed).toBe(true);
    expect(third.allowed).toBe(false);
  });

  it("allows unlimited for pro", async () => {
    const kv = new MemoryKV();
    const date = new Date("2026-01-23T00:00:00Z");
    const status = await consumeItineraryQuota(kv, "user-1", "pro", date, 2);
    expect(status.allowed).toBe(true);
    expect(status.remaining).toBeNull();
  });
});
