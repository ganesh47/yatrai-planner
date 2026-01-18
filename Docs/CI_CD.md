# CI/CD Overview

## iOS CI
- Workflow: .github/workflows/ci.yml
- Runs on push/PR to main and workflow_dispatch
- Builds and tests with iOS Simulator
- Code coverage enabled in xcodebuild

## Worker CI
- Workflow: .github/workflows/worker-ci.yml
- Runs on push/PR to main and workflow_dispatch
- Steps: npm install, lint, typecheck, test
- OpenAI calls are mocked in tests

## Worker CD
- Workflow: .github/workflows/worker-cd.yml
- Deploys on main when secrets are present
- PR preview deploys to env.preview when secrets are present

## Required GitHub Secrets
- CLOUDFLARE_API_TOKEN: Worker deploy token
- CLOUDFLARE_ACCOUNT_ID: Cloudflare account ID
- OPENAI_API_KEY: Used only in Worker runtime (set via Wrangler secret)
- APPLE_AUDIENCE: Apple client ID (set via Wrangler secret)

## Wrangler setup
- Update worker/wrangler.toml with real KV IDs
- Set Worker secrets locally or in CI:
  - wrangler secret put OPENAI_API_KEY
  - wrangler secret put APPLE_AUDIENCE

## Base URLs
- Dev: `https://yatrai-planner-worker-preview.raman-ganesh.workers.dev`
- Prod: `https://yatrai-planner-worker.raman-ganesh.workers.dev`
  - Custom domains pending TLS issuance.
## Local environment
- Copy `.env.local.template` to `.env.local` and fill values.
- `.env.local` is ignored by git.
