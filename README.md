# Vibe-Spec

A reusable stack reference guide for building full-stack web applications with Next.js, Prisma, and PostgreSQL — designed for spec-driven development with AI assistance.

## What Is This?

Vibe-Spec is a single markdown file (`Vibe-Spec.md`) that documents every tool, pattern, and convention you’d need to build a production web app. It was refined through three real-world projects and is meant to be used as context when working with AI coding tools like Claude Code.

You don’t adopt the whole thing. Each section has skip/need conditions so you only pick what fits your project.

## Getting the File

You only need `vibe-spec.md` — it’s a single file. Pick whichever method works for you:

| Method | Steps |
|--------|-------|
| **Download the file** | Open [`vibe-spec.md`](vibe-spec.md) on GitHub → click the **Download raw file** button (top-right) |
| **Copy-paste** | Open [`vibe-spec.md`](vibe-spec.md) → click **Raw** → select all → paste into a new file on your computer |
| **Download ZIP** | Green **Code** button on the repo page → **Download ZIP** → unzip |
| **Git clone** | `git clone https://github.com/Connorrmcd6/vibe-spec.git` (requires git) |

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

Each phase doc doubles as a plan *and* an architecture reference. You can hand a single phase file to a fresh session and it has everything it needs.

#### Step 4: Generate Phase Plans

Generate a high-level markdown file for each phase. Each file opens with a header containing scope, detail level (`High-level` or `Detailed`), and status (`Planned` → `In Progress` → `Complete`).

#### Step 5: Detail and Implement (Iterative)

Go through phases in order. For each phase:

1. **New session** — start fresh to avoid context bloat
2. **Add context** — attach the V2 spec and ask the AI to promote the phase doc to detailed
3. **Implement** — execute the detailed plan
4. **Update docs** — if anything drifted (bottlenecks, design changes, skipped features), update the phase doc so it reflects reality. Update dependent phase docs if needed
5. **Repeat** — move to the next phase with a new session

### The AGENTS.md Hierarchy

The repo is the system of record. An AI agent should be able to read `CLAUDE.md` and navigate to everything it needs.

```
CLAUDE.md                      ← Entry point (1 line: "See @AGENTS.md")
├── AGENTS.md                  ← Root hub: stack, directory map, conventions (~60-100 lines)
├── prisma/AGENTS.md           ← Schema conventions, migration checklist
├── src/lib/AGENTS.md          ← Library modules and import paths
├── src/app/api/AGENTS.md      ← Route groups, auth methods
└── src/components/AGENTS.md   ← UI stack, component patterns
```

- **Root `AGENTS.md`** is a map, not a manual — stack table, invariants, links to sub-files, testing commands
- **Sub-AGENTS.md files** provide domain-specific context that agents pick up automatically when working in that directory
- **Reference docs** (`src/lib/references/`) contain deep-dive checklists for complex topics (auth flows, RBAC, adding pages/endpoints)

### Tool Permissions

Whitelist safe commands in `.claude/settings.local.json` so the AI can run lint, test, typecheck, and git without prompting. Dangerous commands (rm, drop, force-push) stay unlisted — the AI must ask permission.

The full methodology with examples is in Section 1 of the guide.

## What’s Covered

|Section                |What It Covers                                             |
|-----------------------|-----------------------------------------------------------|
|AI-Assisted Development|Spec-driven workflow, AGENTS.md hierarchy, tool permissions|
|Project Scaffolding    |Next.js 16, TypeScript, pnpm, Tailwind v4, ESLint          |
|Docker                 |Local Postgres via docker-compose                          |
|Database Architecture  |Prisma singleton, dual-client pattern for raw SQL          |
|Prisma ORM             |Schema conventions, migrations, config                     |
|dbt Transforms         |Raw → staging → marts pipeline with uv                     |
|Authentication         |OAuth (Auth.js) or OTP + JWT (jose)                        |
|RBAC                   |Roles, permissions, server/client enforcement              |
|Validation             |Zod v4 patterns and gotchas                                |
|Testing                |Vitest with mocked Prisma, coverage config                 |
|UI Framework           |shadcn/ui, theming, component patterns                     |
|S3 Media Uploads       |Presigned URLs, lifecycle tags, CSP                        |
|Push Notifications     |Web Push API, VAPID, service workers                       |
|CI/CD                  |GitHub Actions, pipeline gates                             |
|Pre-commit Hooks       |Native git hooks, no Husky                                 |
|Deployment             |Vercel, Neon, security headers                             |
|Scripts & CLI Tools    |tsx-based operational tooling                              |

## Quick Start by Project Type

|Project Type   |Sections to Use                                                             |
|---------------|----------------------------------------------------------------------------|
|Static site    |Scaffolding, UI, Deployment                                                 |
|Simple CRUD app|Scaffolding, Docker, Prisma, Auth, RBAC, Testing, UI, CI, Deployment        |
|API backend    |Scaffolding, Docker, Prisma, Auth, RBAC, Validation, Testing, CI, Deployment|
|Data-heavy app |All sections                                                                |

## Projects Built with Vibe-Spec

| Project | Description | Sections Used |
|---------|-------------|---------------|
| [OffsideFPL.com](https://offsidefpl.com) | Fantasy Premier League social app with data pipelines, real-time dashboards, and game mechanics | All sections |
| [caps.audittoolbar.com](https://caps.audittoolbar.com) | License management CRUD app with OTP auth, RBAC, and external API | Scaffolding, Docker, Prisma, Auth, RBAC, Validation, Testing, UI, CI/CD, Pre-commit Hooks, Deployment, Scripts |
| [appventure.tech](https://appventure.tech) | Static marketing site | Scaffolding, UI, Deployment |

Built something with Vibe-Spec? [Open a PR](../../pulls) adding your project to the table.

## License

MIT