export interface OpenAIClient {
  createItinerary(prompt: unknown): Promise<unknown>;
}

export function createOpenAIClient(apiKey: string): OpenAIClient {
  return {
    async createItinerary(prompt: unknown): Promise<unknown> {
      const response = await fetch("https://api.openai.com/v1/responses", {
        method: "POST",
        headers: {
          "content-type": "application/json",
          authorization: `Bearer ${apiKey}`
        },
        body: JSON.stringify({
          model: "gpt-5-mini",
          input: prompt,
          response_format: { type: "json_object" }
        })
      });

      if (!response.ok) {
        throw new Error("openai_error");
      }

      return response.json();
    }
  };
}
