# AGENTS.md — Songdle engineering instructions

## Project objective
Build an accessible responsive web game to identify Thai/T-Pop songs and artists from **exactly 10 seconds of permitted audio**. MVP: guest-first random rounds, two game modes, autocomplete selections, five valid attempts, server-authoritative scoring.

## Source of truth / reading order
1. `docs/09-DECISIONS.md` — confirmed decisions and explicitly unresolved matters.
2. `docs/02-GAME_RULES.md` — behavioral invariants, state transitions and scoring.
3. `docs/05-API_CONTRACT.md` — external contract; proposed and subject to acceptance.
4. `docs/04-DATABASE.md` — relational model and integrity requirements.
5. `docs/01-PRD.md`, `docs/06-UX_FLOW.md`, `docs/07-TEST_PLAN.md`, `docs/08-IMPLEMENTATION_PLAN.md`.

If there is a contradiction: respect **confirmed product choices** first, then game invariants, then technical proposals. Document any resolution before changing behavior.

## Constraints agents must preserve
- Two modes: `SONG` (answer is `song_id`) and `ARTIST` (answer is `artist_id`).
- Select answers via autocomplete; never compare raw input text to determine correctness.
- Song may have multiple artists; acceptable artist IDs come **only** from `song_artists.is_accepted_answer = true` for the selected song.
- Fixed 10,000 ms usable audio; unlimited replay; no time limit and no hint system in MVP.
- Five **valid distinct** guesses maximum. Duplicate guesses, invalid IDs, wrong-type IDs, replayed HTTP requests must not consume another attempt.
- Score on winning attempt `n`: `120 - 20*n` for `n in 1..5`; on loss score `0`.
- Server owns game status, answer, attempts and score; never expose `song_id`, artist answers, source filenames, audio metadata or other spoiler-bearing data before the round finishes.
- Atomic answer submission: transaction + session-level locking (or an equivalent concurrency-safe mechanism) + idempotency key, with authoritative attempts stored in PostgreSQL.
- Repeated requests must be idempotent; a single wrong answer cannot consume two attempts.
- Audio rights are a **release blocker**. Do not scrape, copy, host or include commercial tracks without appropriate rights. Development/test fixtures use permitted or synthetic audio; public deployment only with verified use rights. Avoid leaking identifying media URLs/tags.
- Mobile-first accessible keyboard navigation for autocomplete; handle audio failure and disconnected network.
- Redis is optional performance infrastructure; never require it for correctness in MVP.

## Engineering quality gates
- Prefer small, reviewable changes and tests before large refactors.
- Never silently introduce login, daily mode, multiplayer, leaderboard, payment or production music files into MVP.
- Do not assume a song or artist list supplied in sample docs is licensed; placeholder content is synthetic.
- API errors must be stable machine-readable codes. No spoiler fields in pre-finish JSON or HTTP headers.
- No hard-coded secrets or personally identifying visitor data in Git. Document required environment variables with safe examples.
- Do not claim functionality is implemented because it appears in these docs.
- Run formatter, static analysis, unit tests, integration tests and E2E smoke tests as appropriate; report commands and any failures honestly.
- Add/modify ADR entries when a proposed decision becomes locked, and update docs and tests together.

## Suggested working loop
1. Read target milestone (`docs/08-IMPLEMENTATION_PLAN.md`).
2. Write a 5-10 line plan, acceptance criteria, and files expected to change.
3. Implement a thin vertical slice; avoid making speculative features.
4. Add or update tests for success, invalid input, duplicates, concurrency and spoilers.
5. Run checks; update API/schema docs for any actual changes.
6. Report changed files, testing evidence and unresolved risks.

## Definition of Done for MVP
A guest can choose either mode, start a round, listen to 10 s licensed/test audio, search and select an answer, receive safe feedback, reach `WON`/`LOST` within five valid attempts, refresh and recover a round securely, and start another round. Backend enforces all gameplay invariants under concurrent submissions, and all acceptance tests in `docs/07-TEST_PLAN.md` pass.
