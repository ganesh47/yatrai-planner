import { describe, expect, it } from "vitest";
import { MemoryKV } from "./helpers/memoryKv.js";
import { getRole, setRole } from "../src/rbac/roles.js";


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
});
