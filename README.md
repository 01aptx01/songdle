# Songdle — Agentic Coding Handoff

**Specification baseline:** Game Rules v1.0 / PRD v0.3 (consolidated)  
**Status:** documentation and proposed technical design, **not an implemented application**  
**Language:** Thai for product documentation; English identifiers for code/API  
**Stack target:** Next.js + TypeScript, Go REST API, PostgreSQL, Redis (defer until justified).

Songdle is a Thai T-Pop-focused browser game. Players choose **Guess the Song** or **Guess the Artist**, listen to a fixed **10-second** licensed audio clip, select an answer using **autocomplete**, and have up to **5 guesses**. Play is guest-first, no login required in MVP.

**Thai executive overview:** `docs/00-THAI_OVERVIEW.md` (สำหรับอ่านสรุปข้อกำหนดภาษาไทยก่อนเริ่มทำงาน)

## Recommended reading order for coding agents

1. **`AGENTS.md`** — operating rules, priorities, forbidden assumptions, Definition of Done.
2. **`docs/01-PRD.md`** — product goals, scope, user stories, acceptance criteria.
3. **`docs/02-GAME_RULES.md`** — precise game state transitions and validation.
4. **`docs/03-ARCHITECTURE.md`** — services, trust boundaries, repository structure.
5. **`docs/04-DATABASE.md`** — ERD, constraints, transactions, schema notes.
6. **`docs/05-API_CONTRACT.md`** — endpoint request/response examples and error semantics.
7. **`docs/06-UX_FLOW.md`** — screens, states, autocomplete behavior.
8. **`docs/07-TEST_PLAN.md`** — tests and security coverage.
9. **`docs/08-IMPLEMENTATION_PLAN.md`** — dependency-aware issues and milestones.
10. **`docs/09-DECISIONS.md`** — confirmed vs proposed vs open decisions.
11. **`db/reference/001_initial_schema.sql`** — *reference draft* of PostgreSQL DDL, not verified against production data.

## Key distinctions

- **Confirmed by product owner:** Thai/T-Pop focus, two modes, fixed 10 s, autocomplete answers.
- **Carried forward from the agreed planning baseline:** 5 attempts, 100/80/60/40/20 scoring, replay allowed, anonymous guest play, random single-song round, responsive UX.
- **Proposed implementation decisions:** HTTP endpoint paths, guest cookie strategy, UUIDs, DB indexes, seed size, hosting, session expiry and observability. May be adjusted with ADR and tests.

## How to hand this to a coding agent

Place the bundle at the repository root (preserve paths). Suggested initial instruction:

> Read `AGENTS.md` and the linked specification files before editing. Implement **Milestone M0 then M1** in `docs/08-IMPLEMENTATION_PLAN.md` only. Treat the reference SQL as a design draft; convert it into properly versioned migrations, add tests and do not invent or ship copyrighted audio content. Summarize deviations as a proposed decision in `docs/09-DECISIONS.md`.

Keep documentation version-controlled alongside source code. A Word overview is also provided outside this folder for human review.
