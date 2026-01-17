import { describe, expect, it } from "vitest";
import { validateItineraryRequest } from "../src/validation/itinerary.js";

describe("validateItineraryRequest", () => {
  it("accepts a valid payload", () => {
    const result = validateItineraryRequest({
      startCity: "Chennai",
      endCity: "Mumbai",
      startDate: "2026-01-23T04:30:00Z",
      endDate: "2026-01-26T10:00:00Z"
    });

    expect(result.ok).toBe(true);
    expect(result.errors.length).toBe(0);
  });

  it("rejects missing fields", () => {
    const result = validateItineraryRequest({
      startCity: "",
      endCity: "Mumbai",
      startDate: ""
    });

    expect(result.ok).toBe(false);
    expect(result.errors.length).toBeGreaterThan(0);
  });
});
