import type { KVNamespaceLike } from "../../src/types.js";

export class MemoryKV implements KVNamespaceLike {
  private storage = new Map<string, string>();

  async get(key: string): Promise<string | null> {
    return this.storage.get(key) ?? null;
  }

  async put(key: string, value: string): Promise<void> {
    this.storage.set(key, value);
  }
}
