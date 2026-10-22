# Songdle — Game Rules v1.0

**Core rule set:** stable MVP baseline. All authoritative decisions happen on the server.

## GR-01 Modes
- `SONG`: choose the ID of the correct song from the catalog. Title is only a display/search property.
- `ARTIST`: choose the ID of any artist explicitly designated as accepted for the current song (`song_artists.is_accepted_answer = true`). A featured collaborator is **not** automatically accepted.
- Both modes use a single randomly selected eligible song and one authorized 10 s audio clip per round.

## GR-02 Round initialization
1. Guest chooses mode.
2. Server validates mode, identifies guest, chooses an active song with valid artist mapping and active approved 10 s clip. In `ARTIST` mode at least one artist must be marked accepted.
3. Server persists `game_sessions`: `status=PLAYING`, `attempts_used=0`, `score=0`.
4. Client receives opaque game ID, mode, `attempts_remaining=5`, status and opaque playable audio endpoint, **not answer IDs or song/artist metadata**.
5. Randomization policy can avoid immediate repeats later; no strict no-repeat guarantee for MVP.

## GR-03 Audio
- Clip is fixed **10,000 ms**. Replay unlimited and free. No timer or progressive reveal.
- A broken/missing clip produces a recoverable error; UI offers retry or new game without registering a guess.
- Ensure source file names, URLs, MIME metadata, tags and response fields cannot easily disclose song or artist. For actual commercial music, use only approved rights/embedding terms.

## GR-04 Answer selection
- Text query powers `GET /songs/search` or `GET /artists/search`; the player must choose a result item.
- Client submits a `song_id` or `artist_id`, **never** determines correctness locally.
- Check that the ID exists and is active and type matches mode; malformed, missing, inactive, wrong-mode or duplicate selection does not spend an attempt.
- Duplicate means the same song/artist ID was already submitted successfully to this session. Return a stable `DUPLICATE_GUESS` error, not a second attempt.

## GR-05 Attempt transitions
- A valid, previously unguessed answer counts as one attempt.
- If right: persist guess as correct and set game `WON` in same transaction.
- If wrong and attempts_used < 5: remain `PLAYING`.
- If fifth valid guess wrong: set `LOST` and score 0.
- Terminal games reject new guesses as `GAME_FINISHED`; idempotency replay of an already applied request returns the original result without mutation.
- Refresh/status read must not spend an attempt.

## GR-06 Scoring
When a correct answer arrives on numbered valid guess `n` (1..5), award `score=120-20*n`:

| Winning guess | Points |
|---|---:|
| #1 | 100 |
| #2 | 80 |
| #3 | 60 |
| #4 | 40 |
| #5 | 20 |
| All 5 wrong | 0 |

Only server calculates or persists score. Optional UI estimator is not authoritative.

## GR-07 End-of-round reveal
On `WON` or `LOST`, server may return: target `song_id` and title, credited artist names/IDs, accepted artist IDs, guesses, points, attempt count and `finished_at`. Do not expose a reveal to other guests; session ownership is checked on every request.

## GR-08 Session lifecycle / consistency
- Status enum: `PLAYING | WON | LOST` (CREATED may be an internal ephemeral event, not persisted).
- Cookie/session identifier is generated server-side from cryptographically secure randomness. DB stores a hash; HTTP cookie should be HttpOnly/Secure/SameSite appropriate to deployment.
- Under parallel guesses, transaction locks the session (`SELECT ... FOR UPDATE`) before reading attempts/guesses and updating results.
- Client supplies an idempotency UUID with each new submission; server enforces uniqueness per session. Replays must not spend twice.
- Server decides if an unfinished session can be resumed and how long sessions live; TTL is an *open implementation decision*, not a confirmed product requirement.

## State transition table
| Prior | Event | Conditions | Next | DB effect |
|---|---|---|---|---|
| — | start | playable song exists | PLAYING | 0 attempts / 0 score |
| PLAYING | guess | invalid type / ID / duplicate | PLAYING | no guess row; no decrement |
| PLAYING | guess | valid wrong, attempts 1..4 | PLAYING | +1 guess, +1 attempts |
| PLAYING | guess | valid right, attempts 1..5 | WON | +1 guess, +1 attempts, score |
| PLAYING | guess | valid wrong on #5 | LOST | +1 guess, attempts=5, score=0 |
| WON/LOST | new guess | not a replay | unchanged | `GAME_FINISHED` |
| any | idempotent retry | same key and payload | unchanged | return stored result |
| any | session read / refresh | guest owns session | unchanged | no mutation |

## Edge cases requiring explicit tests
- Parallel guesses for the same session; fifth wrong vs correct arriving concurrently.
- Reuse idempotency key with **different** payload (`IDEMPOTENCY_CONFLICT`).
- Same candidate reused with new idempotency key (`DUPLICATE_GUESS`).
- Other guest tries to use session ID (`NOT_FOUND` or `FORBIDDEN` without leaking existence).
- Correctness of one-song-many-artists (primary and featured with different acceptance).
- Stale/deactivated candidate between autocomplete and submit (reject without attempt).
- Audio errors, HTTP timeouts, disconnected client, page reload.
