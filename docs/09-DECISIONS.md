# Decisions and open questions

**Legend:** CONFIRMED = explicitly chosen by user; BASELINE = previously proposed in discussion and carried into Game Rules v1.0; PROPOSED = engineering suggestion, adjust via ADR; OPEN/BLOCKED = requires new decision or verification.

| ID | Topic | Status | Decision / note |
|---|---|---|---|
| D-001 | Music category | CONFIRMED | Thai, primarily T-Pop |
| D-002 | Modes | CONFIRMED | Guess the Song + Guess the Artist |
| D-003 | Clip duration | CONFIRMED | Fixed 10 seconds |
| D-004 | Guess input | CONFIRMED | Autocomplete choose item |
| D-005 | Attempts | BASELINE | Five valid distinct guesses |
| D-006 | Scoring | BASELINE | Correct on attempts 1-5: 100/80/60/40/20; loss 0 |
| D-007 | Replay/timer | BASELINE | Unlimited replay; no timer |
| D-008 | Guest access | BASELINE | No login required in MVP |
| D-009 | Session mode | BASELINE | Random single-song round; play again |
| D-010 | Backend stack | BASELINE | Next.js + Go + PostgreSQL; Redis optional |
| D-011 | Multiple artists | PROPOSED | Per song/artist explicit acceptable-answer flag |
| D-012 | ID storage | PROPOSED | UUID primary keys; submitted IDs authoritative |
| D-013 | Guest ownership | PROPOSED | HttpOnly cookie + hash in DB; enforce ownership |
| D-014 | API | PROPOSED | REST `/api/v1` interface in API_CONTRACT |
| D-015 | Consistency | PROPOSED | PG row locks + idempotency key + unique constraints |
| D-016 | Audio rights/source | OPEN/BLOCKED | Select licensable preview/provider or permitted demo files, verify permission; do not ship actual commercial audio by default |
| D-017 | Artist policy | OPEN | For each featuring/duet, curate accepted artist IDs; no global automatic acceptance |
| D-018 | Catalog scope | OPEN | Initial verified track set and T-Pop genre policy |
| D-019 | Guest expiry | OPEN | Choose session retention + purge policy |
| D-020 | Hosting/storage | OPEN | Select target deployment and licensed audio delivery method |
| D-021 | Search matching | PROPOSED | Case/spacing-normalized PostgreSQL query with indexes; aliases can be added later |
| D-022 | Accessibility | PROPOSED | Keyboard navigable combobox, visible focus, captions/ARIA, WCAG-informed evaluation |
| D-023 | Redis | BASELINE | Do not make Redis a correctness requirement for MVP |

## Unresolved risks and release gates
1. **Audio usage rights** must be verified for publishing, caching, transcoding, clipping and hosting. Default dev clips must be synthetic/permitted.
2. Audio must not contain identifiers in public filenames, response headers, tags or predictable URLs; visually and technically inspect media delivery.
3. Formal session lifetime, cleanup, and rate limits require explicit implementation choices before public deployment.
4. Design artifacts and SQL are **specifications**, not evidence of a live system.

## ADR policy
When locking a proposal, append an ADR in `docs/adr/` or add date, rationale, alternatives, and consequences here; update PRD/rules/schema/API/tests in same change.
