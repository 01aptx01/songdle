# Songdle — Product Requirements Document

**PRD version:** 0.3 (consolidated from previous draft)  
**Game Rules:** v1.0  
**Status:** baseline for MVP; technical implementation details remain proposed.

## 1. Product overview
Songdle is a Thai/T-Pop-focused browser music guessing game. A player listens to a short audio clue and guesses **a song title** or **an artist**. The site is responsive and guest-first, and the repository is intended as a real Full-stack portfolio project.

### Product goals
- Make one short round easy to start without registration.
- Demonstrate reliable game logic, data modeling, testing, APIs and deployment.
- Support both song and artist modes without separate incompatible databases.
- Provide a foundation for future daily challenges, accounts and rankings without building them prematurely.

### Target audience
People who listen to Thai pop music, especially T-Pop, and casual players who prefer short browser games on mobile or desktop.

## 2. Locked core product choices
| Item | Choice |
|---|---|
| Catalog focus | Thai songs; **T-Pop as primary catalog** |
| Modes | `SONG` / `ARTIST` |
| Media clue | A **fixed 10-second** clip |
| Answer interaction | Search / autocomplete then select an item by ID |

### Baseline MVP rules retained from earlier plan
| Item | Default for v1.0 |
|---|---|
| Round | Single-player random song |
| Guesses | Max five valid distinct guesses |
| Score | 100, 80, 60, 40, 20 points for first through fifth correct guess; otherwise 0 |
| Audio replay | Unlimited; no score penalty |
| Timer | None |
| Authentication | Anonymous guest session; no account creation |

## 3. In-scope MVP functionality
| ID | Requirement | Acceptance summary |
|---|---|---|
| FR-01 | Select game mode | User chooses Song or Artist before start |
| FR-02 | Start round | Backend creates randomized playable session |
| FR-03 | Play audio | Fixed 10 s clue available, replay allowed |
| FR-04 | Search choices | Mode-specific autocomplete using IDs |
| FR-05 | Submit guess | Server validates and returns progress |
| FR-06 | Limit attempts | At most 5 valid distinct guesses |
| FR-07 | Score result | Calculated server-side by attempt count |
| FR-08 | End game | Correct answer => WON, fifth wrong => LOST |
| FR-09 | Reveal result | Show song, artist(s), score, guesses after finish |
| FR-10 | Play again | Start a new session independently |
| FR-11 | Responsive | Useful on mobile and desktop |
| FR-12 | Refresh recoverability | Session recoverable by same guest token |
| FR-13 | Failure feedback | Safe, clear errors for offline/audio/search/API |

## 4. User stories
- **US-01** As a guest, I can start either game mode without logging in.
- **US-02** As a player, I can listen to the same 10 s audio clue repeatedly.
- **US-03** As a player, I can find selectable song or artist results using autocomplete.
- **US-04** As a player, I see how many valid attempts remain.
- **US-05** As a player, I get win/loss feedback, reveal and server-scored points.
- **US-06** As a player, refreshing does not reset my existing round accidentally.
- **US-07** As a keyboard or screen-reader user, I can navigate search suggestions and game controls.

## 5. Out of scope for MVP
Accounts/login, Daily Challenge, leaderboard, multiplayer, friend system, streaks, achievements, admin dashboard, hint tokens, incremental audio lengths, user-submitted music and public uploads.

## 6. Non-functional requirements
- **Security:** no spoilers before completion; validate ownership, mode and candidate; rate-limit misuse; use secure random guest tokens and safe cookies.
- **Consistency:** correctness, attempts, state and score are server-authoritative and transactionally updated.
- **Reliability:** playback issues or server failures cannot silently spend attempts; idempotent guess requests.
- **Maintainability:** Go business logic separated from handlers; PostgreSQL migrations; documented API and tests.
- **Usability/accessibility:** responsive design; keyboard autocomplete; loading/empty/error states; visible audio controls.
- **Observability:** structured errors and minimal privacy-conscious request/session metrics.
- **Rights:** only licensed/permitted audio and metadata; do not use unverified song files as seeded assets.

## 7. Success criteria
1. Both modes are playable end-to-end as a guest.
2. A round concludes only on correct guess or five valid wrong guesses.
3. Wrong/duplicate/retried/parallel requests never violate attempt limits.
4. Pre-finish API responses and media URLs do not reveal target song/artist.
5. The build runs locally and the test suite covers core rules.
6. A public deployment uses audio permitted for the relevant use; otherwise use safe demo audio only.

## 8. Open product questions
Catalog selection/curation, exactly what constitutes T-Pop, approved audio provider and rights, specific artist credit/featuring acceptance per song, rate limits, persistence/expiry of anonymous sessions and accessibility targets are tracked in `09-DECISIONS.md`.
