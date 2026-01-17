# Release Readiness Checklist

## Product
- Trip input flow complete and validated
- Deterministic itinerary works offline
- AI draft flow is editable and clearly labeled
- Costs and checklists visible and editable

## Security & Privacy
- Apple token verified on every backend request
- No OpenAI keys in app binary
- Logging avoids PII and full payloads

## Data & Sync
- CloudKit schema documented and versioned
- Offline-first behavior tested
- Conflict handling strategy documented

## Quality
- Unit tests for planner, validation, costs, auth
- UI smoke tests for Trip inputs and Itinerary view
- Worker tests for auth, RBAC, quotas, validation

## CI/CD
- iOS CI green on main
- Worker CI green on main
- Worker CD deploys with secrets configured

## App Store
- Privacy policy draft ready
- App metadata drafted (description, keywords)
