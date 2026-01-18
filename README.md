# YatraiPlanner

[![CI](https://github.com/ganesh47/yatrai-planner/actions/workflows/ci.yml/badge.svg)](https://github.com/ganesh47/yatrai-planner/actions/workflows/ci.yml)
[![Worker CI](https://github.com/ganesh47/yatrai-planner/actions/workflows/worker-ci.yml/badge.svg)](https://github.com/ganesh47/yatrai-planner/actions/workflows/worker-ci.yml)
[![Worker CD](https://github.com/ganesh47/yatrai-planner/actions/workflows/worker-cd.yml/badge.svg)](https://github.com/ganesh47/yatrai-planner/actions/workflows/worker-cd.yml)
[![Security Scans](https://github.com/ganesh47/yatrai-planner/actions/workflows/security.yml/badge.svg)](https://github.com/ganesh47/yatrai-planner/actions/workflows/security.yml)

YatraiPlanner is an iOS travel planning app backed by a Cloudflare Worker API. The app supports deterministic planning, editable AI drafts, offline-first usage, and CloudKit sync.

## Highlights
- Deterministic itinerary planner that works offline.
- AI-generated draft itineraries that remain editable.
- Server-side validation, RBAC, and quota enforcement via the worker.
- CloudKit-backed data model for trips and itineraries.

## Repository Layout
- `YatraiPlanner/`: SwiftUI app sources.
- `worker/`: Cloudflare Worker API (TypeScript).
- `Docs/`: Architecture, CI/CD, and release notes.

## Docs
- Project overview: `Docs/Overview.md`
- Architecture: `Docs/Architecture.md`
- Development guide: `Docs/Development.md`
- CI/CD: `Docs/CI_CD.md`
- Release checklist: `Docs/ReleaseChecklist.md`
- CloudKit schema notes: `Docs/CloudKitSchema.md`
- Security policy: `SECURITY.md`

## Getting Started
### Prerequisites
- Xcode (latest stable).
- Node.js 22 (see `.nvmrc`).
- npm 9+.
- Cloudflare Wrangler (only for Worker dev/deploy).

### iOS App
1. Open `YatraiPlanner.xcodeproj` in Xcode.
2. Select the `YatraiPlanner` scheme.
3. Run on an iOS Simulator or device.

### Worker API
```bash
cd worker
npm install
npm run lint
npm run typecheck
npm test
```

To run the worker locally:
```bash
cd worker
npx wrangler dev
```

### Required Secrets (Worker)
Set these as Wrangler secrets for local/dev and in CI/CD for deploys:
- `OPENAI_API_KEY`
- `APPLE_AUDIENCE`

## CI/CD
- iOS CI: `.github/workflows/ci.yml`
- Worker CI: `.github/workflows/worker-ci.yml`
- Worker CD: `.github/workflows/worker-cd.yml`
- Security scans (Gitleaks, CodeQL): `.github/workflows/security.yml`

## Releases (SemVer + Changelog)
Releases are driven by the `App Release` workflow in `.github/workflows/release.yml`.
- Uses semantic versioning (major/minor/patch).
- Updates `CHANGELOG.md`.
- Updates Xcode `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`.
- Creates an annotated tag (e.g. `v1.2.3`) and a GitHub Release with notes only.
- No binaries are uploaded to GitHub.

## Security
Please review `SECURITY.md` for reporting guidelines and supported versions.

## License
MIT. See `LICENSE`.
