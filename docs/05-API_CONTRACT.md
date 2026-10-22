# API Contract v0.1 — Proposed REST contract

**Base:** `/api/v1`  
**Auth:** opaque server-issued guest cookie; session lookup must validate ownership. JSON requests/responses except media. Paths and status codes are proposals pending implementation.

## Shared fields and conventions
- `mode` is `SONG` or `ARTIST` (uppercase).
- `status` is `PLAYING`, `WON` or `LOST`.
- Identifiers are UUID strings. `request_id` is an idempotency UUID generated fresh **per intended new answer**, reused for retries of that answer.
- The server is authoritative; clients must not infer results from candidate labels.
- Pagination/limits for autocomplete: proposed `q` length 1..80, `limit` <= 20, safe result bounding; refine with UX tests.
- Error envelope: `{ "error": { "code": "DUPLICATE_GUESS", "message": "...", "request_id": "..." } }`. Do not include secret target answers in errors.

## 1. `POST /games` — create round
Request:
```json
{ "mode": "SONG" }
```
Response `201` while active:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "mode": "SONG",
  "status": "PLAYING",
  "attempts_used": 0,
  "attempts_remaining": 5,
  "score": 0,
  "audio_url": "/api/v1/games/550e8400-e29b-41d4-a716-446655440000/audio"
}
```
Do **not** return `song_id`, artists, audio storage key, original file name, approved artist list or full catalog object.

## 2. `GET /games/{id}` — active/resume or finished
Active `200`:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "mode": "ARTIST", "status": "PLAYING",
  "attempts_used": 2, "attempts_remaining": 3, "score": 0,
  "guesses": [
    {"candidate_type":"ARTIST","candidate_id":"d4fdd7ad-1ce9-40c9-b29b-093bdd285bed","is_correct":false,"attempt_number":1},
    {"candidate_type":"ARTIST","candidate_id":"b780145e-7023-478b-ac65-96b3e0194a17","is_correct":false,"attempt_number":2}
  ],
  "audio_url": "/api/v1/games/550e8400-e29b-41d4-a716-446655440000/audio"
}
```
Active responses may show the *player's own prior guesses*, but no target identifiers. Finished responses add `result` as below.

## 3. `GET /songs/search?q=...&limit=10` and `GET /artists/search?q=...&limit=10`
Song example:
```json
{ "items": [{"id":"4a7d23f6-f39c-4faa-829e-188d33e95342","label":"เพลงตัวอย่าง A","subtitle":"ศิลปินตัวอย่าง X"}] }
```
Artist example:
```json
{ "items": [{"id":"d4fdd7ad-1ce9-40c9-b29b-093bdd285bed","label":"ศิลปินตัวอย่าง X"}] }
```
The catalog search is **global**; not scoped to a game session or the correct answer. Active searchable candidates only. Search by normalized text/alias as implemented; never return `is_correct`.

## 4. `POST /games/{id}/guesses` — one answer
Request for SONG:
```json
{
  "request_id":"788452fd-ce46-492d-9772-4edee891d593",
  "candidate_type":"SONG",
  "candidate_id":"4a7d23f6-f39c-4faa-829e-188d33e95342"
}
```
Request for ARTIST uses `candidate_type="ARTIST"` and selected `artist_id` as `candidate_id`. Back end checks mode, existence, active status, prior guesses, ownership and idempotency.

Wrong nonterminal response `200`:
```json
{ "is_correct":false, "status":"PLAYING", "attempts_used":1, "attempts_remaining":4, "score":0 }
```
Correct/terminal response `200`:
```json
{
  "is_correct":true, "status":"WON", "attempts_used":2,
  "attempts_remaining":3, "score":80,
  "result": {
    "song": {"id":"4a7d23f6-f39c-4faa-829e-188d33e95342","title":"เพลงตัวอย่าง A"},
    "artists":[{"id":"d4fdd7ad-1ce9-40c9-b29b-093bdd285bed","name":"ศิลปินตัวอย่าง X"}]
  }
}
```
On `LOST`, return `is_correct=false`, `status=LOST`, `attempts_used=5`, `attempts_remaining=0`, `score=0`, and the same safe terminal reveal shape.

An exact retry of the same `request_id` and candidate should return its **original applied outcome**, not deduct a new attempt. A reused request ID with a different candidate returns a conflict.

## 5. `GET /games/{id}/audio`
Stream or redirect via an opaque licensed mechanism only for owning guest. Exact response content type depends on permitted audio source. No public `Content-Disposition` filenames or metadata revealing the answer. Avoid unsafe caches / browser range behavior that expose spoiler-bearing storage paths. Support playback/replay without consuming attempts. If provider terms require embeds instead of streaming, revise this endpoint contract via ADR.

## 6. Proposed error code contract
| HTTP | Code | Meaning | Attempt spent? |
|---:|---|---|---|
| 400 | `VALIDATION_ERROR` | malformed JSON or invalid fields | No |
| 400 | `INVALID_MODE` | unknown game/answer mode | No |
| 404 | `GAME_NOT_FOUND` | missing session or inaccessible to guest | No |
| 404 | `CANDIDATE_NOT_FOUND` | missing/inactive song or artist | No |
| 409 | `DUPLICATE_GUESS` | same candidate already attempted | No |
| 409 | `GAME_FINISHED` | new answer after win/loss | No |
| 409 | `IDEMPOTENCY_CONFLICT` | same request_id, different payload | No |
| 429 | `RATE_LIMITED` | too many requests | No |
| 503 | `AUDIO_UNAVAILABLE` | clip cannot be played | No |

## Example client behavior
- Debounce autocomplete queries; use AbortController; prevent out-of-order suggestions.
- Generate a `request_id` on submit, hold until request is resolved, reuse only for retry of same submission.
- Disable submit while request is pending; disable game controls after terminal status.
- On uncertainty after network failure, call `GET /games/{id}` and/or retry using the **same** request ID rather than sending a fresh guess.

## Security/privacy notes
Cookie-authenticated `POST` needs CSRF controls appropriate to origin policy. Rate-limit session creation, media delivery and search. Search response should not include spoilers (or rankings based on correct answer). Never trust client-side score/attempt values. API response examples use synthetic identifiers and names.
