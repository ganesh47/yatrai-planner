import { describe, expect, it } from "vitest";
import { SignJWT, createLocalJWKSet, exportJWK, generateKeyPair } from "jose";
import { verifyAppleIdentityToken } from "../src/auth/appleJwt.js";

async function buildToken(aud: string, iss: string, kid: string) {
  const { publicKey, privateKey } = await generateKeyPair("RS256");
  const jwk = await exportJWK(publicKey);
  jwk.kid = kid;
  const jwks = createLocalJWKSet({ keys: [jwk] });

  const token = await new SignJWT({ email: "user@example.com" })
    .setProtectedHeader({ alg: "RS256", kid })
    .setIssuedAt()
    .setIssuer(iss)
    .setAudience(aud)
    .setExpirationTime("2h")
    .setSubject("user-123")
    .sign(privateKey);

  return { token, jwks };
}

describe("verifyAppleIdentityToken", () => {
  it("accepts a valid token", async () => {
    const { token, jwks } = await buildToken("app.client.id", "https://appleid.apple.com", "key-1");
    const payload = await verifyAppleIdentityToken(token, {
      audience: "app.client.id",
      issuer: "https://appleid.apple.com",
      jwksOverride: jwks
    });
    expect(payload.sub).toBe("user-123");
  });

  it("rejects a token with wrong audience", async () => {
    const { token, jwks } = await buildToken("app.client.id", "https://appleid.apple.com", "key-2");
    await expect(
      verifyAppleIdentityToken(token, {
        audience: "other.client.id",
        issuer: "https://appleid.apple.com",
        jwksOverride: jwks
      })
    ).rejects.toThrow();
  });

  it("rejects an expired token", async () => {
    const { publicKey, privateKey } = await generateKeyPair("RS256");
    const jwk = await exportJWK(publicKey);
    jwk.kid = "key-3";
    const jwks = createLocalJWKSet({ keys: [jwk] });

    const token = await new SignJWT({})
      .setProtectedHeader({ alg: "RS256", kid: "key-3" })
      .setIssuedAt()
      .setIssuer("https://appleid.apple.com")
      .setAudience("app.client.id")
      .setExpirationTime(0)
      .setSubject("user-123")
      .sign(privateKey);

    await expect(
      verifyAppleIdentityToken(token, {
        audience: "app.client.id",
        issuer: "https://appleid.apple.com",
        jwksOverride: jwks
      })
    ).rejects.toThrow();
  });
});
