# Architecture

## Components
- iOS App (SwiftUI): UI, local state, offline planning, and CloudKit sync.
- Worker API (Cloudflare Worker, TypeScript): Auth verification, validation, quotas, and itinerary generation.
- CloudKit: Primary datastore for trips and itineraries.
- External services: Apple identity verification and optional AI generation.

## Data Flow
1. The app collects trip details and validates locally.
2. The app calls the worker API for auth verification and optional AI drafting.
3. The worker validates inputs, applies RBAC and quotas, and returns responses.
4. The app persists the itinerary and metadata to CloudKit for sync.

## Authentication and Authorization
- Each backend request includes an Apple identity token.
- The worker verifies tokens and enforces role-based access.
- Quotas limit abuse and protect API usage.

## Validation and Safety
- Inputs are validated on both client and server.
- The worker returns structured errors for invalid payloads.
- AI drafts are never authoritative; edits remain client-owned.

## Observability
- The worker emits request-level logs and avoids PII.
- CI enforces linting, tests, and type checks.

## Related Docs
- CI/CD overview: `Docs/CI_CD.md`
- CloudKit schema notes: `Docs/CloudKitSchema.md`
