# Vibe-Spec

A spec-driven development workflow **and** a production-tested full-stack reference —
packaged as a Claude Code plugin. Instead of copy-pasting a markdown file, install it
once and get five `/spec-*` commands plus an on-demand stack reference for Next.js,
Prisma, PostgreSQL, and the rest of the stack.

Refined through real production projects. You only adopt what you need — every
reference has skip/need conditions.

## Install

In Claude Code, run:

```
/plugin marketplace add Connorrmcd6/vibe-spec
/plugin install vibe-spec
```

That's it — the `/spec-*` commands and the `vibe-spec` skill are now available.

> Prefer the old way? The full reference still lives in the repo under
> [`skills/vibe-spec/reference/`](skills/vibe-spec/reference/) — read or copy any
> section directly.

## The workflow: 5 commands

Write a spec before touching code, refine it with AI, break it into phases, and
implement phase by phase with clean context boundaries.

| Command | Step | What it does |
| --- | --- | --- |
| `/spec-draft` | 1 — V0 | Interview you and write a rough, tool-agnostic spec: what the product does and how users interact with it. |
| `/spec-refine` | 2 — V1 | Critique the draft, fill gaps, and map each feature to concrete stack tools using the references. |
| `/spec-phases` | 3 — V2 | Break the spec into sequential, self-contained phases with a phase index. |
| `/spec-plan` | 4 | Generate high-level plan files for **all** phases (scope + status header each), so you have a complete set to work from. |
| `/spec-implement` | 5 | Promote a phase to detailed, implement it, then update the docs so the spec stays the source of truth. |

Step 5 is iterative — run it once per phase in a fresh session. **A stale spec is
worse than no spec; it actively misleads future sessions**, so updating docs after
implementation is part of the step, not an afterthought.

## The reference (the `vibe-spec` skill)

The skill carries 18 stack references that Claude loads **on demand** — only the file
relevant to the task, keeping context lean. The commands consult them automatically;
you can also just ask a stack question and the skill pulls the right reference.

| Reference | What it covers |
| --- | --- |
| AI-Assisted Development | Spec-driven workflow, AGENTS.md hierarchy, tool permissions |
| Project Scaffolding | Next.js 16, TypeScript, pnpm, Tailwind v4, ESLint |
| High-Performance APIs | NestJS in a decoupled monorepo — when Next.js routes aren't enough |
| Docker | Local Postgres via docker-compose |
| Database Architecture | Prisma singleton, dual-client pattern for raw SQL |
| Prisma ORM | Schema conventions, migrations, config |
| dbt Transforms | Raw → staging → marts pipeline with uv |
| Authentication | OAuth (Auth.js) or OTP + JWT (jose) |
| RBAC | Roles, permissions, server/client enforcement |
| Validation | Zod v4 patterns and gotchas |
| Testing | Vitest with mocked Prisma, coverage config |
| UI Framework | shadcn/ui, theming, component patterns |
| S3 Media Uploads | Presigned URLs, lifecycle tags, CSP |
| Push Notifications | Web Push API, VAPID, service workers |
| CI/CD | GitHub Actions, pipeline gates |
| Pre-commit Hooks | Native git hooks, no Husky |
| Deployment | Vercel, Neon, security headers |
| Scripts & CLI Tools | tsx-based operational tooling |

## Quick start by project type

| Project type | References to use |
| --- | --- |
| Static site | Scaffolding, UI, Deployment |
| Simple CRUD app | Scaffolding, Docker, Prisma, Auth, RBAC, Testing, UI, CI, Deployment |
| API backend | Scaffolding, Docker, Prisma, Auth, RBAC, Validation, Testing, CI, Deployment (+ NestJS for extremely performant APIs) |
| Data-heavy app | All references |

## Website

A landing page (built with Astro, à la [impeccable.style](https://impeccable.style))
is in progress. Install today is via the plugin marketplace above.

## License

MIT
