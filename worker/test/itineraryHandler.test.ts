import { describe, expect, it } from "vitest";
import { handleItineraryRequest } from "../src/handlers/itinerary.js";
import { MemoryKV } from "./helpers/memoryKv.js";

const validBody = {
  startCity: "Chennai",
  endCity: "Mumbai",
  startDate: "2026-01-23T04:30:00Z",
  endDate: "2026-01-26T10:00:00Z"
};

function makeRequest(body: unknown, token = "token") {
  return new Request("https://example.com/itinerary", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify(body)
  });
}

describe("handleItineraryRequest", () => {
  it("returns 401 on missing token", async () => {
    const kv = new MemoryKV();
    const request = new Request("https://example.com/itinerary", { method: "POST" });
    const response = await handleItineraryRequest(request, {
      kv,
      verifyToken: async () => ({ sub: "user-1" }),
      openaiClient: { createItinerary: async () => ({}) }
    });

    expect(response.status).toBe(401);
  });

  it("rejects invalid payload", async () => {
    const kv = new MemoryKV();
    const response = await handleItineraryRequest(makeRequest({ startCity: "" }), {
      kv,
      verifyToken: async () => ({ sub: "user-1" }),
      openaiClient: { createItinerary: async () => ({}) }
    });

    expect(response.status).toBe(422);
  });

  it("enforces free quota", async () => {
    const kv = new MemoryKV();
    const deps = {
      kv,
      verifyToken: async () => ({ sub: "user-1" }),
      openaiClient: { createItinerary: async () => ({ ok: true }) }
    };

    await handleItineraryRequest(makeRequest(validBody), deps);
    await handleItineraryRequest(makeRequest(validBody), deps);
    const third = await handleItineraryRequest(makeRequest(validBody), deps);

    expect(third.status).toBe(429);
  });

  it("returns draft on success", async () => {
    const kv = new MemoryKV();
    const response = await handleItineraryRequest(makeRequest(validBody), {
      kv,
      verifyToken: async () => ({ sub: "user-1" }),
      openaiClient: { createItinerary: async () => ({ draft: true }) }
    });

    expect(response.status).toBe(200);
    const payload = await response.json();
    expect(payload.draft).toBeTruthy();
  });
});
