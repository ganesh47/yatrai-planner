import { describe, expect, it } from "vitest";
import { MemoryKV } from "./helpers/memoryKv.js";
import { getRole, isAllowlisted, setAllowlistEntry, setRole } from "../src/rbac/roles.js";


describe("RBAC role store", () => {
  it("defaults to free", async () => {
    const kv = new MemoryKV();
    const role = await getRole(kv, "user-1");
    expect(role).toBe("free");
  });

  it("stores and retrieves roles", async () => {
    const kv = new MemoryKV();
    await setRole(kv, "user-1", "pro");
    const role = await getRole(kv, "user-1");
    expect(role).toBe("pro");
  });

  it("defaults to not allowlisted", async () => {
    const kv = new MemoryKV();
    const allowed = await isAllowlisted(kv, "user-1");
    expect(allowed).toBe(false);
  });

  it("stores allowlist entries", async () => {
    const kv = new MemoryKV();
    await setAllowlistEntry(kv, "user-1", true);
    const allowed = await isAllowlisted(kv, "user-1");
    expect(allowed).toBe(true);
  });
});
