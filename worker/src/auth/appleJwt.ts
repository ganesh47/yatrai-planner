import { createRemoteJWKSet, jwtVerify, type JWTPayload, type JWTVerifyOptions } from "jose";

export interface AppleJwtConfig {
  audience: string;
  issuer: string;
  jwksUrl?: string;
  jwksOverride?: ReturnType<typeof createRemoteJWKSet>;
}

export async function verifyAppleIdentityToken(
  token: string,
  config: AppleJwtConfig
): Promise<JWTPayload> {
  const jwksUrl = config.jwksUrl ?? "https://appleid.apple.com/auth/keys";
  const jwks = config.jwksOverride ?? createRemoteJWKSet(new URL(jwksUrl));

  const options: JWTVerifyOptions = {
    audience: config.audience,
    issuer: config.issuer
  };

  const { payload } = await jwtVerify(token, jwks, options);
  return payload;
}
