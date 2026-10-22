# Testing and acceptance plan

Test layer meanings: **Unit** tests deterministic business rules; **Integration** tests Go + PostgreSQL transactions/migrations; **API** tests HTTP responses/security; **E2E** tests browser experience; **Manual** rights/media/a11y checks.

## Acceptance matrix
| ID | Scenario | Expected | Layer |
|---|---|---|---|
| T-001 | Start SONG and ARTIST session | PLAYING, 5 remaining, no spoiler | API/E2E |
| T-002 | Winning on guess #1 | WON, score 100 | Unit/Integration |
| T-003 | Winning on guess #2..#5 | 80/60/40/20 respectively | Unit |
| T-004 | Five valid wrong guesses | LOST, score 0, no more guesses | Unit/Integration |
| T-005 | Duplicate candidate | No new attempt | Integration/API |
| T-006 | Unknown candidate UUID | No new attempt | API |
| T-007 | ARTIST answer submitted in SONG | Validation error, no attempt | API |
| T-008 | Incorrectly marked featured artist | Wrong unless accepted flag true | Unit/Integration |
| T-009 | Multiple accepted primary artists | Any accepted listed artist wins | Unit/Integration |
| T-010 | Retry same request ID + payload | No double increment, same outcome | Integration |
| T-011 | Reuse request ID with different candidate | `IDEMPOTENCY_CONFLICT` | Integration/API |
| T-012 | Parallel submits for same session | Attempts serialized, never >5, no double score | Integration |
| T-013 | Submit after game finished | No state change, `GAME_FINISHED` | API |
| T-014 | Guest A reads/guesses Guest B's game | No access / spoiler | API |
| T-015 | Active game JSON/audio headers | No song/artist/accepted answer leaking | API/Manual |
| T-016 | Browser refresh | Same state recovered securely | E2E |
| T-017 | Playback/replay | Replay never modifies attempts | E2E |
| T-018 | Audio fetch failure | Recoverable error, no guess spent | E2E |
| T-019 | Search 0/many/multilingual matches | Correct suggestions, bounded response | API/E2E |
| T-020 | Mobile and keyboard search | Accessible and usable | E2E/Manual |
| T-021 | Disabled/rights-unapproved song/clip | Not eligible for new game | Integration |
| T-022 | Database constraints/migration | Up/down or migration replay works as designed | Integration |
| T-023 | Score cannot be client overridden | Server ignores client-supplied points | API |
| T-024 | CSRF and abuse limits | Appropriate rejection | API/Security |

## Test data
Use a synthetic fixture catalog:
- Song A credits Artist X (primary, accepted) and Artist Y (featured, not accepted).
- Song B credits Artist Y (primary, accepted).
- Song C credits two accepted primary artists.
- Include duplicate titles, inactive songs/artists, missing clips, unapproved rights and exactly 10,000 ms synthetic media.

**Do not** include third-party commercial sound recordings until rights are documented.

## Quality commands (planned, not claimed existing)
```bash
# Examples only; adjust to actual repo after bootstrap
cd backend && go test ./...
cd frontend && npm run lint && npm test
# integration: spin up Postgres test container and execute migrations + race/transaction cases
# e2e: npm run test:e2e
```

## Launch review
1. Can both games be completed end-to-end from an anonymous browser?
2. Is every pre-terminal response spoiler-free (including headers, media, logs, search hints)?
3. Are all clips licensed for the deployed usage and attribution requirements satisfied?
4. Do concurrency + replay tests pass in a real PostgreSQL instance?
5. Are rate limiting, session expiry, cookie properties, backup/retention documented?
6. Are README local setup and CI commands reproducible by another person?
