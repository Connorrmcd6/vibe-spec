---
name: vibe-spec
description: Spec-driven development workflow plus a production-tested full-stack reference (Next.js 16, Prisma, PostgreSQL, Auth.js/OTP, RBAC, dbt, Zod, Vitest, shadcn/ui, S3, Web Push, GitHub Actions, Vercel). Use when planning a web app spec, choosing stack tools for a feature, breaking work into phases, or implementing a phase — and as a lookup for any of these stack areas. Pulls in only the relevant reference file on demand.
---

# Vibe-Spec

A reusable blueprint for building full-stack web apps with Next.js, Prisma, and
PostgreSQL using **spec-driven development**. Refined through real production
projects — every tool, pattern, and convention is documented so you can pick what
fits the project in front of you.

## Only adopt what you need

This catalogs a comprehensive stack, but most projects won't need all of it. A
static site doesn't need Prisma, Docker, or dbt; a simple CRUD app doesn't need S3
or push notifications. Adding tools you don't need is complexity for no benefit.
**Load only the reference file(s) relevant to the task at hand.**

### Quick reference: what do I need?

| Project type | Recommended references |
| --- | --- |
| Static / marketing site | `00-workflow`, `01-scaffolding`, `11-ui`, `15-pre-commit` |
| Simple CRUD app | `00`–`01`, `03`–`05`, `07-auth`, `08-rbac`, `10-testing`, `11-ui`, `14`–`16` |
| API-only backend | `00`–`01`, `03`–`05`, `02-nestjs` (optional), `07`–`10`, `14`–`16` |
| Data-heavy app (pipelines, transforms) | All references |

## The workflow (use the `/spec-*` commands)

The methodology: write a spec before touching code, refine it with AI, break it into
phases, and implement phase by phase with clean context boundaries. Each step has a
slash command:

1. **`/spec-draft`** — Write a rough **V0** spec: what the product does and the exact
   user workflows. No tooling decisions yet.
2. **`/spec-refine`** — Promote V0 → **V1**: fill gaps, then map each piece of
   functionality to concrete tools using the references below.
3. **`/spec-phases`** — Promote V1 → **V2**: break the spec into sequential,
   self-contained phases with a phase index.
4. **`/spec-plan`** — Generate a high-level plan file for **every** phase
   (`docs/plans/phase-*.md`), each with a scope + status header, so you have a
   complete set to work from.
5. **`/spec-implement`** — Implement one phase in a fresh session, then **update the
   docs** so the spec always reflects reality. A stale spec is worse than no spec.

Full detail (AGENTS.md hierarchy, tool permissions, phase conventions) lives in
[`reference/00-workflow.md`](reference/00-workflow.md).

**Getting set up:** before the workflow needs tools, `/spec-setup` installs only what
the project requires (guided, confirm each step), `/spec-doctor` reports what's
installed, and `/spec-troubleshoot` diagnoses common failures — all backed by
[`reference/18-prerequisites.md`](reference/18-prerequisites.md).

## Reference index

Load the file(s) that match the current task — not all of them.

| Reference | Skip if… / Use if… |
| --- | --- |
| [`00-workflow`](reference/00-workflow.md) | The spec-driven workflow, AGENTS.md hierarchy, tool permissions. Use when setting up methodology or AI context. |
| [`01-scaffolding`](reference/01-scaffolding.md) | Next.js 16 + TypeScript + pnpm + Tailwind v4 + ESLint. The base layer for any web app. |
| [`02-nestjs`](reference/02-nestjs.md) | Decoupled high-performance API (Fastify). Escape hatch — only when you've measured a need. |
| [`03-docker`](reference/03-docker.md) | Local Postgres 16 via docker-compose. Use when the app has a DB and you want an isolated local env. |
| [`04-database`](reference/04-database.md) | Dual-client (Prisma + raw pg Pool) and multi-schema layout. Use when you need ORM **and** raw SQL / JSONB. |
| [`05-prisma`](reference/05-prisma.md) | Prisma ORM schema conventions and migrations. Use for structured, relational data. |
| [`06-dbt`](reference/06-dbt.md) | raw → staging → marts transforms with uv. Use when you ingest raw data that needs transforming. |
| [`07-auth`](reference/07-auth.md) | OAuth (Auth.js) **or** OTP + JWT (jose). Use when the app needs sign-in / sessions / protected routes. |
| [`08-rbac`](reference/08-rbac.md) | Roles + permissions, server- and client-side enforcement. Use when access differs by role. |
| [`09-validation`](reference/09-validation.md) | Zod v4 runtime validation. Use when consuming external APIs, webhooks, or complex input. |
| [`10-testing`](reference/10-testing.md) | Vitest with mocked Prisma. Testing is not optional — use always. |
| [`11-ui`](reference/11-ui.md) | shadcn/ui components + theming via CSS variables. Use when building a web UI. |
| [`12-s3`](reference/12-s3.md) | Presigned uploads, lifecycle tags, CSP. Use for file / media uploads. |
| [`13-push-notifications`](reference/13-push-notifications.md) | Web Push + VAPID + service worker. Use for push notifications / PWA. |
| [`14-ci-cd`](reference/14-ci-cd.md) | GitHub Actions lint/test gates and scheduled pipelines. Use for any team repo. |
| [`15-pre-commit`](reference/15-pre-commit.md) | Native git hooks (no Husky). Use to enforce checks before commit. |
| [`16-deployment`](reference/16-deployment.md) | Vercel + Neon, security headers, env-var checklist. Use when shipping to production. |
| [`17-scripts`](reference/17-scripts.md) | TypeScript CLI tools (tsx) for pipelines, seeding, prod sync. Use for operational tooling. |
| [`18-prerequisites`](reference/18-prerequisites.md) | Required tools (Git, Node, pnpm, Docker, uv), how to detect them, and per-OS install methods. Used by `/spec-setup`, `/spec-doctor`, `/spec-troubleshoot`. |

## Putting it all together

For a new project: start with the spec (`/spec-draft` → `/spec-refine` →
`/spec-phases`), scaffold with [`01-scaffolding`](reference/01-scaffolding.md) using
official CLI init commands, then add only the references the quick-reference table
points to. Set up AGENTS.md and CI early. Break work into phases completable in 1–3
sessions, and update phase docs whenever implementation drifts from the plan.

The key principle: **every tool here exists because a real project needed it**. Your
project has different needs — start minimal, add complexity only when a specific
feature demands it.
