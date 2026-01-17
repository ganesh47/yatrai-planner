export interface ItineraryRequest {
  startCity: string;
  endCity: string;
  startDate: string;
  endDate: string;
}

export interface ValidationResult {
  ok: boolean;
  errors: string[];
}

export function validateItineraryRequest(payload: Partial<ItineraryRequest>): ValidationResult {
  const errors: string[] = [];

  if (!payload.startCity || payload.startCity.trim().length === 0) {
    errors.push("startCity is required");
  }
  if (!payload.endCity || payload.endCity.trim().length === 0) {
    errors.push("endCity is required");
  }
  if (!payload.startDate) {
    errors.push("startDate is required");
  }
  if (!payload.endDate) {
    errors.push("endDate is required");
  }

  return {
    ok: errors.length === 0,
    errors
  };
}
