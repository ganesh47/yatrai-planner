import { verifyAppleIdentityToken } from "./auth/appleJwt.js";

export interface Env {
  APPLE_AUDIENCE?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return new Response(JSON.stringify({ ok: true }), {
        status: 200,
        headers: { "content-type": "application/json" }
      });
    }

    if (url.pathname === "/auth/verify" && request.method === "POST") {
      const authHeader = request.headers.get("authorization") ?? "";
      const token = authHeader.replace(/^Bearer\s+/i, "");
      if (!token) {
        return new Response(JSON.stringify({ error: "missing_token" }), {
          status: 401,
          headers: { "content-type": "application/json" }
        });
      }

      const audience = env.APPLE_AUDIENCE ?? "";
      const issuer = "https://appleid.apple.com";
      try {
        const payload = await verifyAppleIdentityToken(token, { audience, issuer });
        return new Response(JSON.stringify({ sub: payload.sub, email: payload.email ?? null }), {
          status: 200,
          headers: { "content-type": "application/json" }
        });
      } catch (error) {
        return new Response(JSON.stringify({ error: "invalid_token" }), {
          status: 401,
          headers: { "content-type": "application/json" }
        });
      }
    }

    return new Response(JSON.stringify({ error: "not_found" }), {
      status: 404,
      headers: { "content-type": "application/json" }
    });
  }
};
