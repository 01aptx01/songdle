# Agentic implementation plan — milestone backlog

**Rule:** implement only the next explicitly selected milestone; do not add future-mode features unless needed for testing. Each milestone ends with a working slice, tests and documented changes.

## M0 — Bootstrap and decisions
- [ ] Initialize monorepo layout; add Next.js + TypeScript and Go API skeleton.
- [ ] Set up `.editorconfig`, formatting/linting, `.env.example` (no secrets), Docker Compose for PostgreSQL (Redis optional).
- [ ] Choose validated Go router, SQL library/migrations, Node package manager, target Postgres version, test framework (record ADR).
- [ ] Decide development-safe audio fixture strategy and public rights plan; public T-Pop audio is blocked until verified.
- [ ] CI jobs for lint/unit checks; documented `make dev` or equivalent.

**DoD:** a new developer can follow README to run both services, DB and checks locally; no real licensed-content assumptions.

## M1 — Catalog and DB migrations
- [ ] Convert `db/reference/001_initial_schema.sql` into versioned up/down migration files; apply/rollback against test PostgreSQL.
- [ ] Seed synthetic songs, artists, relationships and 10 s permitted synthetic audio; include edge cases.
- [ ] Add catalog read and mode-specific autocomplete search endpoints.
- [ ] Add correctness of accepted-artists relation and rights eligibility tests.

**DoD:** one command loads test dataset; API returns catalog search results without answers.

## M2 — Game engine backend
- [ ] Create guest cookie/token middleware and session ownership checks.
- [ ] Implement `POST /games` eligible selection and `GET /games/{id}` safe serialization.
- [ ] Implement atomic `POST /games/{id}/guesses`, idempotency, uniqueness handling, terminal reveals.
- [ ] Implement audio endpoint with safe 10 s synthetic clips, no source-metadata leaks.
- [ ] Unit and integration tests covering T-001 through T-015, T-021 to T-024 where relevant.

**DoD:** both game modes can be played via API with strict five-guess behavior and deterministic scoring.

## M3 — Next.js playable experience
- [ ] Home mode selection and route creation.
- [ ] Game screen with audio play/replay, remaining attempts and error states.
- [ ] Accessible autocomplete for SONG/ARTIST modes; clear stale selections.
- [ ] Result UI, Play Again, refresh/resume recovery, responsive layouts.
- [ ] E2E flows T-016..T-020.

**DoD:** browser end-to-end playability on mobile and desktop, keyboard operation and no spoiler UI.

## M4 — Harden and demonstrate
- [ ] Rate limiting, secure cookies/CSRF handling, error telemetry, practical session cleanup.
- [ ] Integration tests under concurrent submissions and network retry.
- [ ] Documentation: screenshots, setup, decisions, demo fixtures, README and API docs aligned with code.
- [ ] Rights audit of chosen live audio provider; if permissions remain unconfirmed, deploy demo with synthetic/permitted clips only.
- [ ] Deploy and complete launch checklist.

**DoD:** verifiable portfolio demonstration, reproducible setup, tests, documented legal/content posture.

## Optional post-MVP
Accounts, Daily Challenge, global leaderboard, Redis caching, hints, statistics, artist/song subcategories, multiplayer. Require separate planning and data-model changes.

## Suggested coding agent tasks
**Task 1:** "Read AGENTS.md. Implement M0 only. Record architecture choices in docs/09-DECISIONS.md. Do not implement game logic yet."

**Task 2:** "Implement M1 with versioned PostgreSQL migrations derived from db/reference and synthetic seeds. Add migration and query tests. Avoid copyrighted tracks."

**Task 3:** "Implement M2 with PostgreSQL row-level transaction locking and idempotency. Prove no double spend under concurrent guesses. No revealing target while PLAYING."

**Task 4:** "Implement M3 with accessible Thai autocomplete and E2E coverage on mobile."

## Pull-request checklist
- [ ] Linked milestone and acceptance IDs in PR description.
- [ ] No unauthorized product/feature decisions slipped into code.
- [ ] No secrets, real commercial audio or spoiler-bearing preview metadata.
- [ ] Unit/integration/E2E verification run, actual outputs recorded.
- [ ] Docs and decision log updated for behavior/API/schema changes.
