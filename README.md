# Vibe-Spec

A reusable stack reference guide for building full-stack web applications with Next.js, Prisma, and PostgreSQL — designed for spec-driven development with AI assistance.

## What Is This?

Vibe-Spec is a single markdown file (`Vibe-Spec.md`) that documents every tool, pattern, and convention you’d need to build a production web app. It was refined through three real-world projects and is meant to be used as context when working with AI coding tools like Claude Code.

You don’t adopt the whole thing. Each section has skip/need conditions so you only pick what fits your project.

## Getting the File

You only need `vibe-spec.md` — it’s a single file. Pick whichever method works for you:

| Method                | Steps                                                                                                     |
| --------------------- | --------------------------------------------------------------------------------------------------------- |
| **Download the file** | Open [`vibe-spec.md`](vibe-spec.md) on GitHub → click the **Download raw file** button (top-right)        |
| **Copy-paste**        | Open [`vibe-spec.md`](vibe-spec.md) → click **Raw** → select all → paste into a new file on your computer |
| **Download ZIP**      | Green **Code** button on the repo page → **Download ZIP** → unzip                                         |
| **Git clone**         | `git clone https://github.com/Connorrmcd6/vibe-spec.git` (requires git)                                   |

Once you have the file, give it to your AI tool alongside your project spec.

## How to Use It

### Spec-Driven Development (5 Steps)

The core idea: write a spec before touching code, refine it with AI, break it into phases, and implement phase by phase with clean context boundaries.

#### Step 1: Write a V0 Spec

Write a rough first draft describing what your product does and how users interact with it. Focus on user workflows, not implementation — e.g. "User logs in with OTP, sees a dashboard filtered by their role." Don't worry about tooling choices yet.

#### Step 2: Refine to V1 Spec

Use planning mode on the best model you have access to. Give it your V0 spec + `vibe-spec.md` and ask it to:

- Improve your spec and ask clarifying questions about gaps
- Map each piece of functionality to specific tools from the stack reference

The V1 spec becomes your single source of truth — it details exactly what tools are used for each feature.

#### Step 3: Add Phases (V2 Spec)

Ask the AI to break the V1 spec into sequential, self-contained phases. Append a phase index to the end of the V1 spec — this becomes your **V2 spec** (final version, discard V0 and V1). Store phase files in `docs/plans/`. At this stage phases are **outlined only** — names and scope boundaries, not full plans.

Each phase doc doubles as a plan _and_ an architecture reference. You can hand a single phase file to a fresh session and it has everything it needs.

#### Step 4: Generate Phase Plans

Generate a high-level markdown file for each phase. Each file opens with a header containing scope, detail level (`High-level` or `Detailed`), and status (`Planned` → `In Progress` → `Complete`).

#### Step 5: Detail and Implement (Iterative)

Go through phases in order. For each phase:

1. **New session** — Start fresh to avoid context bloat
2. **Promote to detailed** — Attach the full spec and the target phase doc, then use planning mode to expand it to detailed. Don't just change the detail-level header — fill in the substance. This mirrors the V0 → V1 process but scoped to a single phase. If decisions here affect later phases (e.g., choosing Apple OAuth means adding env vars to the deployment phase), update those docs too.
3. **Implement** — Execute the detailed plan. If you hit bottlenecks, blockers, or direction changes, document what changed and why in the relevant phase docs.
4. **Update docs (critical)** — This is the most important step. The spec is the single source of truth — every future session builds on it, not on your memory of what happened. Reconcile the phase doc with what was actually built. If anything drifted — skipped features, design changes, workarounds — update the doc so it reflects reality. Cascade changes to dependent phase docs. A stale spec is worse than no spec; it actively misleads future sessions.
5. **Repeat** — Open a new session and move to the next phase.

## What’s Covered

| Section                 | What It Covers                                              |
| ----------------------- | ----------------------------------------------------------- |
| AI-Assisted Development | Spec-driven workflow, AGENTS.md hierarchy, tool permissions |
| Project Scaffolding     | Next.js 16, TypeScript, pnpm, Tailwind v4, ESLint           |
| Docker                  | Local Postgres via docker-compose                           |
| Database Architecture   | Prisma singleton, dual-client pattern for raw SQL           |
| Prisma ORM              | Schema conventions, migrations, config                      |
| dbt Transforms          | Raw → staging → marts pipeline with uv                      |
| Authentication          | OAuth (Auth.js) or OTP + JWT (jose)                         |
| RBAC                    | Roles, permissions, server/client enforcement               |
| Validation              | Zod v4 patterns and gotchas                                 |
| Testing                 | Vitest with mocked Prisma, coverage config                  |
| UI Framework            | shadcn/ui, theming, component patterns                      |
| S3 Media Uploads        | Presigned URLs, lifecycle tags, CSP                         |
| Push Notifications      | Web Push API, VAPID, service workers                        |
| CI/CD                   | GitHub Actions, pipeline gates                              |
| Pre-commit Hooks        | Native git hooks, no Husky                                  |
| Deployment              | Vercel, Neon, security headers                              |
| Scripts & CLI Tools     | tsx-based operational tooling                               |

## Quick Start by Project Type

| Project Type    | Sections to Use                                                              |
| --------------- | ---------------------------------------------------------------------------- |
| Static site     | Scaffolding, UI, Deployment                                                  |
| Simple CRUD app | Scaffolding, Docker, Prisma, Auth, RBAC, Testing, UI, CI, Deployment         |
| API backend     | Scaffolding, Docker, Prisma, Auth, RBAC, Validation, Testing, CI, Deployment |
| Data-heavy app  | All sections                                                                 |

## Projects Built with Vibe-Spec

| Project                                      | Description                                                                                     | Sections Used                                                                                                  |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [OffsideFPL.com](https://offsidefpl.com)     | Fantasy Premier League social app with data pipelines, real-time dashboards, and game mechanics | All sections                                                                                                   |
| [CAPS](https://atb-caps.vercel.app/)         | License management CRUD app with OTP auth, RBAC, and external API                               | Scaffolding, Docker, Prisma, Auth, RBAC, Validation, Testing, UI, CI/CD, Pre-commit Hooks, Deployment, Scripts |
| [Appventure](https://appventure.vercel.app/) | Static marketing site                                                                           | Scaffolding, UI, Deployment                                                                                    |

Built something with Vibe-Spec? [Open a PR](../../pulls) adding your project to the table.

## License

MIT
