# Project Overview

## Mission
YatraiPlanner helps travelers build reliable itineraries quickly. It blends deterministic planning with AI-drafted suggestions while keeping the itinerary fully editable and usable offline.

## Core Capabilities
- Trip inputs (dates, places, preferences) are validated and normalized.
- Deterministic planner produces a reliable baseline itinerary.
- AI draft flow provides optional enhancements without blocking the offline flow.
- Itinerary edits are always possible and are treated as first-class data.
- CloudKit keeps trip data in sync across devices.

## Product Principles
- Offline-first: core planning works without network access.
- Transparent AI: AI drafts are clearly labeled and can be edited.
- Safety by default: inputs are validated and quotas enforced server-side.
- Privacy-aware: no API keys are shipped in the app binary.

## Data and Sync
- Trips and itineraries are modeled as structured entities.
- CloudKit handles sync and conflict resolution across devices.
- Schema changes are additive and backwards compatible.

## Release Approach
- Semantic versioning is used for app releases.
- Changelog entries are generated and stored in `CHANGELOG.md`.
- Releases publish tags and notes only (no binaries in GitHub).
