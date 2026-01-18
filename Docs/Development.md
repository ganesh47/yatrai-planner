# Development Guide

## Prerequisites
- Xcode (latest stable).
- Node.js 22 (use `.nvmrc`).
- npm 9+.
- Cloudflare Wrangler for worker development.

## iOS App
1. Open `YatraiPlanner.xcodeproj` in Xcode.
2. Select the `YatraiPlanner` scheme.
3. Run on a simulator or device.

## Worker API
Install dependencies and run checks:
```bash
cd worker
npm install
npm run lint
npm run typecheck
npm test
```

Run locally with Wrangler:
```bash
cd worker
npx wrangler dev
```

## Secrets and Environment
Set these secrets for the worker (locally and in CI/CD):
- `OPENAI_API_KEY`
- `APPLE_AUDIENCE`

Add them locally with:
```bash
cd worker
npx wrangler secret put OPENAI_API_KEY
npx wrangler secret put APPLE_AUDIENCE
```

## Troubleshooting
- If worker tests fail, run `npm test` to isolate failures.
- If Xcode build fails, ensure the correct simulator runtime is installed.
