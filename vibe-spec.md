# Vibe-Spec: Stack Reference Guide

A reusable blueprint for building full-stack web applications with Next.js, Prisma, and PostgreSQL. This guide was refined through two real-world projects built with **spec-driven development and AI assistance** — every tool, pattern, and convention is documented here so you can pick what fits your next project.

## How to Use This Guide

**Only adopt what you need.** This doc catalogs a comprehensive stack, but most projects won’t need all of it. A static site doesn’t need Prisma, Docker, or dbt. A simple CRUD app doesn’t need S3 or push notifications. Adding tools you don’t need creates complexity for no benefit.

Each section is self-contained with:

- **Skip/need conditions** — when to use it vs. when to ignore it
- **Key files** — what to create or reference
- **Configuration** — real, copy-pasteable code blocks
- **Gotchas & conventions** — non-obvious things that will bite you

### Quick Reference: What Do I Need?

| Project Type                           | Recommended Sections                                                                                         |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Static site / marketing page           | 1 (AI Dev), 2 (Scaffolding), 10 (UI), 14 (Hooks)                                                             |
| Simple CRUD app                        | 1–5 (AI Dev through Prisma), 7 (Auth), 8 (RBAC), 9 (Testing), 10 (UI), 13–16 (CI through Deployment)         |
| API-only backend                       | 1–5 (AI Dev through Prisma), 7 (Auth), 8 (RBAC), 9 (Validation), 10 (Testing), 13–15 (CI through Deployment) |
| Data-heavy app (pipelines, transforms) | All sections                                                                                                 |

---

## Table of Contents

1. [AI-Assisted Development (Spec-Driven Workflow)](#1-ai-assisted-development-spec-driven-workflow)
2. [Project Scaffolding](#2-project-scaffolding)
3. [Docker for Local Development](#3-docker-for-local-development)
4. [Database Architecture](#4-database-architecture)
5. [Prisma ORM](#5-prisma-orm)
6. [dbt Transforms](#6-dbt-transforms)
7. [Authentication](#7-authentication)
8. [Role-Based Access Control (RBAC)](#8-role-based-access-control-rbac)
9. [Validation (Zod)](#9-validation-zod)
10. [Testing (Vitest)](#10-testing-vitest)
11. [UI Framework (shadcn/ui)](#11-ui-framework-shadcnui)
12. [S3 Media Uploads](#12-s3-media-uploads)
13. [Push Notifications](#13-push-notifications)
14. [CI/CD (GitHub Actions)](#14-cicd-github-actions)
15. [Pre-commit Hooks](#15-pre-commit-hooks)
16. [Deployment](#16-deployment)
17. [Scripts & CLI Tools](#17-scripts--cli-tools)

---

## 1. AI-Assisted Development (Spec-Driven Workflow)

> **Skip this if:** you don’t use AI coding tools
> **You need this if:** you use Claude Code, Codex, or similar AI assistants in your workflow — or you want a structured methodology for breaking large projects into manageable phases

### Purpose

This section is placed first intentionally — it describes the methodology for using this entire guide. It covers a spec-driven development workflow, a structured system for giving AI tools the context they need (AGENTS.md hierarchy), and tool permissions for safe AI-assisted coding.

### Key Files

| File                          | Purpose                                                   |
| ----------------------------- | --------------------------------------------------------- |
| `Vibe-Spec.md`                | This file — stack reference and starter guide             |
| `CLAUDE.md`                   | Entry point — AI tools read this first                    |
| `AGENTS.md`                   | Root project conventions (stack, directory map, patterns) |
| `prisma/AGENTS.md`            | Prisma-specific conventions                               |
| `src/lib/AGENTS.md`           | src/lib directory structure                               |
| `src/lib/references/*.md`     | Deep-dive docs (auth-flow.md, rbac-guide.md)              |
| `.claude/settings.local.json` | Tool permissions for Claude Code                          |
| `docs/project-spec.md`        | Your product specification                                |
| `docs/plans/phase-*.md`       | Phase implementation plans                                |

### Spec-Driven Development Methodology

This is the recommended workflow for using this guide to build your own project. The core idea: write a spec before touching code, refine it with AI, break it into phases, and implement phase by phase with clean context boundaries.

#### Step 1: Write a V0 Spec

Write a rough first draft of your project spec. Accept that you won’t know everything — focus on high-level details of how you want it to work. Describe the exact user workflow, for example:

- User logs in with OTP (or OAuth), they are shown a dashboard
- Different pages are visible based on user roles
- The app exposes API endpoints that a webhook from another service can write to
- The app fetches data from an external API on a schedule

Don’t worry about tooling choices or implementation details yet — just describe what the product does and how users interact with it.

#### Step 2: Refine to V1 Spec

Use planning mode on the best model you have access to. Add this Vibe-Spec file to context and ask the AI to:

- Improve your V0 spec
- Ask clarifying questions about gaps
- Use this stack reference to design the V1 spec, mapping each piece of functionality to specific tools

The V1 spec should detail exactly what tools are used to achieve each piece of functionality. It becomes your single source of truth.

#### Step 3: Add Phases (V2 Spec)

Ask the AI to break the V1 spec into sequential phases — each one a self-contained chunk of work that can be planned, implemented, and verified independently. Append a phase index to the end of the V1 spec. This becomes your **V2 spec** — the final version. You can discard V0 and V1.

The phase index is a table of contents with one-line summaries. The actual detail lives in separate files inside a `docs/plans/` folder. At this stage, phases are **outlined only** — names, scope boundaries, and a sentence or two on what each covers. Don’t fully plan or design them yet.

**Example phase index** (appended to V2 spec):

```markdown
### Phase Plan

| # | File | Scope |
|---|------|-------|
| 1 | `docs/plans/phase-1-foundation.md` | Project scaffold, SDK integration, data ingestion |
| 2 | `docs/plans/phase-2-auth.md` | Auth, onboarding, seasonal leagues |
| 3 | `docs/plans/phase-3-dashboard.md` | dbt transforms, core dashboard views |
| 4 | `docs/plans/phase-4-rules.md` | Game rules, nominations, social features |
| 5 | `docs/plans/phase-5-orchestration.md` | Scheduling, PWA, push notifications |
| 6 | `docs/plans/phase-6-launch.md` | Landing page, performance, polish |
```

**Why phases work:** each doc doubles as a plan *and* an architecture reference. You can hand a single phase file to a fresh session and it has everything it needs — no context bleeding from previous work.

#### Step 4: Generate Phase Plans

Ask the AI to generate a markdown file for each phase. Keep them high-level at first — just enough structure to understand scope and sequence. Each file should open with a frontmatter-style header:

```markdown
# Phase 1 — Foundation

| Field | Value |
|-------|-------|
| **Scope** | Project scaffold, SDK integration, data ingestion |
| **Detail level** | High-level |
| **Status** | Planned |
```

Valid statuses: `Planned` → `In Progress` → `Complete`. Update the status as you work through each phase. The detail level starts as “High-level” and gets promoted to “Detailed” in Step 5 before implementation begins.

#### Step 5: Detail and Implement (Iterative)

Go through phases in order. For each phase:

1. **New session** — start fresh to avoid context bloat
2. **Add context** — attach the V2 spec and ask the AI to make the phase doc detailed
3. **Implement** — execute the detailed plan
4. **Update docs** — if anything drifted during implementation (bottlenecks, design changes, skipped features), update the phase doc so it always reflects reality. Update dependent phase docs if needed
5. **Repeat** — move to the next phase with a new session, adding the project spec and previous phase doc for context

You may find that you need to add more phases later. This is fine — proceed with the same pattern.

**Why this works:**

- Each phase is **independent enough** to be a clean conversation boundary — no context bleeding between sessions
- Phase plans capture **decisions made** during implementation, not just TODOs. Phase 4 can reference decisions from phase 2 without re-explaining them
- The spec doc is **living** — it gets updated as decisions are made, keeping it accurate as the source of truth

### The AGENTS.md Hierarchy

```
CLAUDE.md                      ← Entry point: "See @AGENTS.md for Project Conventions"
├── AGENTS.md                  ← Root: stack, directory map, key conventions
├── prisma/AGENTS.md           ← Prisma conventions (IDs, timestamps, schemas)
├── src/lib/AGENTS.md          ← src/lib directory structure
├── src/app/api/AGENTS.md      ← Route groups, auth methods
└── src/components/AGENTS.md   ← UI stack, component patterns
```

**Why this hierarchy:**

- **`CLAUDE.md`** is minimal (one line). AI tools read it first, then follow the pointer.
- **Root `AGENTS.md`** has everything that applies project-wide: stack, directory map, conventions. Keep it under 100 lines — it’s a map, not a manual.
- **Subdirectory `AGENTS.md` files** provide domain-specific context. When an AI tool is working in `src/lib/auth/`, it automatically picks up the auth conventions. This keeps the root file manageable while giving deep context where it matters.

**Root AGENTS.md must contain:**

1. One-line project description
2. Tech stack table
3. **Invariants** — non-negotiable rules (ID format, naming conventions, auth guard, import patterns)
4. Links to every sub-AGENTS.md with one-line descriptions
5. Testing section (framework, commands, setup location)

**Root AGENTS.md must NOT contain:** code examples, detailed how-tos, long prose. Those go in sub-files.

**Subdirectory AGENTS.md files should cover:**

- **Design decisions** — why this module is structured this way
- **Patterns** — the specific patterns used (e.g., namespace pattern, DI pattern, orchestrator pattern)
- **Testing notes** — how to mock this module’s dependencies
- **Gotchas** — domain-specific traps

**Reference docs** (`src/lib/references/`) are deep-dive documents with **checklists** for complex topics. Checklists make agents reliable — numbered step-by-step procedures for “How to add a new role”, “How to add a new page”, “How to create a v1 endpoint” mean agents follow them exactly instead of guessing.

**Documentation maintenance rule:** Every AGENTS.md includes a footer: _“When modifying [X], update the relevant section above.”_ — treat doc updates as part of the change, not an afterthought.

### Tool Permissions

**.claude/settings.local.json:**

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm lint)",
      "Bash(pnpm test)",
      "Bash(pnpm test:*)",
      "Bash(npx tsc --noEmit)",
      "Bash(npx prisma generate)",
      "Bash(npx shadcn@latest add chart --yes)",
      "Bash(git:*)",
      "Bash(npx prisma:*)",
      "Bash(npx vitest:*)",
      "Bash(gh run:*)",
      "Bash(gh pr:*)"
    ]
  }
}
```

This whitelists specific safe commands (lint, test, typecheck, prisma, git) so the AI tool can run them without prompting. Dangerous commands (rm, drop, force-push) are not listed, so the AI must ask for permission.

### Writing Effective AGENTS.md Files

The root `AGENTS.md` should cover:

- **Stack** — every major tool/library and its version
- **Directory map** — where things live and why
- **Conventions** — non-obvious patterns that the AI should follow (e.g., “never hardcode colors”, “use proxy.ts not middleware.ts”)
- **Domain-specific gotchas** — things unique to your project’s domain

### Skills (`.agents/skills/<name>/SKILL.md`)

Agent-invocable automations with YAML frontmatter:

```yaml
---
name: sync-readme
description: Ensures the readme is up to date with the repo file system
model: haiku-4
---
1. Check file structure defined in @README.md
2. Check actual file structure
3. Update readme to reflect the real structure
```

**Starter skills to create**: `sync-readme`, `new-endpoint`, `new-page`, `new-model`

---

## 2. Project Scaffolding

> **Skip this if:** you’re not building a web app (this is Next.js-specific)
> **You need this if:** you’re building any web application — this is the foundation

### Purpose

Next.js 16 App Router with TypeScript strict mode, pnpm package management, Tailwind CSS v4, and ESLint flat config. This is the base layer everything else builds on.

**Important:** Always generate boilerplate code with official CLI/init commands wherever possible. Use `pnpm create next-app`, `pnpm prisma init`, and `pnpm dlx shadcn@latest init` rather than hand-writing config files. The CLI output will match the current version’s expectations and avoid subtle misconfigurations.

### Key Files

| File                  | Purpose                             |
| --------------------- | ----------------------------------- |
| `package.json`        | Dependencies, scripts, build config |
| `tsconfig.json`       | TypeScript compiler options         |
| `postcss.config.mjs`  | Tailwind v4 PostCSS plugin          |
| `eslint.config.mjs`   | ESLint flat config                  |
| `pnpm-workspace.yaml` | pnpm build optimizations            |

### Configuration

**package.json** — Core dependencies and scripts:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "prisma generate && prisma migrate deploy && next build",
    "start": "next start",
    "lint": "eslint",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "prepare": "git config core.hooksPath .githooks"
  },
  "dependencies": {
    "next": "16.2.1",
    "react": "19.2.3",
    "react-dom": "19.2.3",
    "typescript": "^5",
    "tailwindcss": "^4",
    "zod": "^4.3.6"
  },
  "devDependencies": {
    "@tailwindcss/postcss": "^4",
    "eslint": "^9",
    "eslint-config-next": "16.2.1",
    "vitest": "^4.1.0",
    "tsx": "^4.21.0",
    "vite-tsconfig-paths": "^6.1.1"
  }
}
```

> **Note:** The `build` script includes `prisma generate && prisma migrate deploy` before `next build`. Remove these if you don’t use Prisma. The `prepare` script sets up git hooks — see [Section 15](#15-pre-commit-hooks).

**tsconfig.json** — Strict TypeScript with path aliases:

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "strict": true,
    "noEmit": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    ".next/dev/types/**/*.ts",
    "**/*.mts"
  ],
  "exclude": ["node_modules"]
}
```

**postcss.config.mjs** — Tailwind v4 (no `tailwind.config.js` needed):

```javascript
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
```

**eslint.config.mjs** — Modern flat config (ESLint 9+):

```javascript
import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  globalIgnores([
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    "src/generated/**",
  ]),
]);

export default eslintConfig;
```

**pnpm-workspace.yaml** — Build optimizations:

```yaml
packages:
  - "."
ignoredBuiltDependencies:
  - sharp
  - unrs-resolver
onlyBuiltDependencies:
  - "@prisma/engines"
  - esbuild
  - prisma
```

### Gotchas & Conventions

- **pnpm, not npm.** The lockfile is `pnpm-lock.yaml`. Run `pnpm install`, `pnpm dev`, `pnpm test`, etc.
- **Tailwind v4** uses `@tailwindcss/postcss` — there is no `tailwind.config.js` file. CSS variables and theme config live directly in `globals.css` using `@theme inline`.
- **Path aliases** use `@/*` mapping to `./src/*`. Always import as `@/lib/...`, `@/components/...`, never relative paths across directories.
- **`src/generated/**`** is in both `.gitignore` and ESLint ignores — this is where Prisma generates its client. If you don’t use Prisma, remove this ignore.
- **`tsx`** is used for running TypeScript scripts directly (e.g., `tsx scripts/seed.ts`). Useful for any CLI tooling you need.

---

## 3. Docker for Local Development

> **Skip this if:** you’re building a static site, or you use a hosted DB (like Neon or Supabase) for development
> **You need this if:** your app has a database and you want an isolated local environment

### Purpose

Local Postgres 16 via docker-compose. No Dockerfile — the app deploys to Vercel (or any Node host), Docker is only for the local database.

### Key Files

| File                        | Purpose                                       |
| --------------------------- | --------------------------------------------- |
| `docker-compose.yml`        | Postgres container definition                 |
| `scripts/setup-schemas.sql` | Init script for non-Prisma schemas (optional) |

### Configuration

**docker-compose.yml:**

```yaml
services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    ports: ["5432:5432"]
    environment:
      POSTGRES_USER: <appname>
      POSTGRES_PASSWORD: <appname>_local
      POSTGRES_DB: <appname>
    volumes:
      - pgdata:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4:latest
    restart: unless-stopped
    ports: ["5050:80"]
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@<appname>.dev
      PGADMIN_DEFAULT_PASSWORD: admin
      PGADMIN_CONFIG_SERVER_MODE: "False"
    depends_on: [postgres]

volumes:
  pgdata:
```

Replace `<appname>` with your project name throughout. If you need schemas that Prisma doesn’t manage (like `raw`, `staging`, `marts` for a data pipeline), add a volume mount for an init script:

```yaml
volumes:
  - pgdata:/var/lib/postgresql/data
  - ./scripts/setup-schemas.sql:/docker-entrypoint-initdb.d/01-setup-schemas.sql
```

### Gotchas & Conventions

- **Init scripts only run once** — on the first `docker compose up` when the volume is empty. To re-run them: `docker compose down -v && docker compose up -d` (the `-v` flag deletes the volume).
- **Default creds** (e.g., `<appname>/<appname>_local`) are fine for local dev — they never leave your machine.
- **No Dockerfile** in this repo. The app runs on Vercel/Node, not in Docker. If you need a containerized deployment, you’ll add your own Dockerfile.
- **Schema separation:** For simpler apps, Prisma manages a single `public` schema. For data-heavy apps, you might add `raw`, `staging`, and `marts` schemas via an init script.

---

## 4. Database Architecture

> **Skip this if:** your app has no database, or you only need a simple ORM layer
> **You need this if:** you have both an ORM (structured data) and raw SQL needs (JSONB landing zones, analytical queries)

### Purpose

For apps that only need structured relational data, Prisma alone is sufficient — skip the dual-client pattern below. For apps that also ingest raw data (e.g., from external APIs) and need to transform it, a dual-client architecture works well: **Prisma** for the structured schema (users, orders, settings) and a **raw pg Pool** for JSONB tables and analytical queries. Multiple Postgres schemas keep concerns separated.

### Schema Layout (Data-Heavy Apps)

```
app/       → Prisma-managed (users, orders, settings) — structured, relational
raw/       → JSONB landing zone (ingested API data) — unstructured, append/upsert
staging/   → dbt views (unpack JSONB → typed columns) — read-only transforms
marts/     → dbt tables (denormalized, indexed) — dashboard queries
```

### Key Files

| File                   | Purpose                                             |
| ---------------------- | --------------------------------------------------- |
| `src/lib/db/client.ts` | Prisma client singleton                             |
| `src/lib/db/raw.ts`    | pg Pool singleton for raw/mart queries (if needed)  |
| `src/lib/db/marts.ts`  | Typed query functions wrapping mart SQL (if needed) |

### Configuration

**Prisma client** (`src/lib/db/client.ts`) — Singleton with PrismaPg adapter:

```typescript
import { PrismaClient } from "@/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

function createPrismaClient(): PrismaClient {
  const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
  return new PrismaClient({ adapter });
}

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};
export const prisma = globalForPrisma.prisma ?? createPrismaClient();
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

**Raw pool** (`src/lib/db/raw.ts`) — Only needed for multi-schema setups:

```typescript
import pg from "pg";

const globalForPool = globalThis as unknown as { rawPool: pg.Pool };

function createPool(): pg.Pool {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error("DATABASE_URL is not set");
  const cleanUrl = url.replace(/\?schema=\w+/, "");
  return new pg.Pool({ connectionString: cleanUrl });
}

export const rawPool = globalForPool.rawPool || createPool();
if (process.env.NODE_ENV !== "production") globalForPool.rawPool = rawPool;
```

### Gotchas & Conventions

- **Both clients use the `globalThis` singleton pattern** to survive Next.js hot reload without leaking connections.
- **The raw pool strips `?schema=app`** from `DATABASE_URL` because it writes to `raw.*`, not `app.*`.
- **`safeQuery()`** in `marts.ts` catches Postgres error codes `42P01` (undefined table) and `42703` (undefined column), returning `[]` instead of crashing. This allows the app to start gracefully before dbt has been run.
- **For simpler projects**, Prisma alone is sufficient. The dual-client pattern is only needed when you have JSONB landing zones or analytical queries that Prisma can’t express.
- **Link tables with foreign keys wherever possible** to ensure referential integrity. This makes cascading deletes reliable when users want to delete their data.

---

## 5. Prisma ORM

> **Skip this if:** your app has no database (static site, serverless functions with KV store, etc.)
> **You need this if:** your app stores structured, relational data

### Purpose

Type-safe database access with auto-generated TypeScript types, declarative schema, and migration management. Prisma handles the structured schema — user accounts, resources, configurations, and all relational data.

### Key Files

| File                   | Purpose                                    |
| ---------------------- | ------------------------------------------ |
| `prisma/schema.prisma` | Database schema (models, enums, relations) |
| `prisma.config.ts`     | Prisma 7 config (replaces CLI flags)       |
| `prisma/migrations/`   | Migration history                          |
| `prisma/seed.mts`      | Dev seed script                            |
| `prisma/AGENTS.md`     | Schema conventions for AI tools            |

### Configuration

**prisma.config.ts:**

```typescript
import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations", seed: "tsx prisma/seed.mts" },
  datasource: { url: process.env["DATABASE_URL"] },
});
```

### Schema Conventions

These conventions keep the Prisma schema consistent and predictable:

```prisma
model TeamMember {
  id        String   @id @default(uuid()) @db.Uuid
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  // Fields: camelCase in Prisma → snake_case in Postgres via @map()
  joinedAt DateTime? @map("joined_at")

  // Relations
  team   Team   @relation(fields: [teamId], references: [id])
  teamId String @map("team_id") @db.Uuid

  @@map("team_members")   // Table name: snake_case plural
}
```

**Convention summary:**

| Convention       | Pattern                                                   |
| ---------------- | --------------------------------------------------------- |
| IDs              | `@id @default(uuid()) @db.Uuid`                           |
| Timestamps       | `createdAt` + `updatedAt` with `@map()` for snake_case    |
| Fields           | camelCase in Prisma → snake_case in Postgres via `@map()` |
| Models           | PascalCase → snake_case plural via `@@map()`              |
| Generated output | `../src/generated/prisma` (gitignored)                    |

### Gotchas & Conventions

- **Generated client outputs to `src/generated/prisma`**, not `node_modules`. Add `src/generated/**` to `.gitignore` and ESLint ignores.
- **`prisma generate` must run before `tsc` or `next build`** — the build script is `"prisma generate && prisma migrate deploy && next build"`.
- **`PrismaAdapter(prisma as never)`** — the `as never` cast is needed when using `@prisma/adapter-pg` due to a type mismatch with certain adapters (Auth.js, etc.). This is safe.
- **`prisma.config.ts`** is the Prisma 7+ way to configure — it replaces CLI flags and supports `dotenv/config` for env loading.
- **Migrations:** `pnpm prisma migrate dev` for local development (creates + applies), `pnpm prisma migrate deploy` in CI/production (applies only). Never hand-edit applied migration SQL — create a new migration.

---

## 6. dbt Transforms

> **Skip this if:** your app doesn’t have a data pipeline, analytics layer, or JSONB data that needs transformation
> **You need this if:** you ingest raw data (APIs, webhooks, etc.) and need to transform it into queryable tables

### Purpose

dbt-postgres transforms raw data into typed views and denormalized tables optimized for queries. You can structure your dbt layers however you see fit. One common pattern is `raw → staging → marts` where staging unpacks raw data into typed columns (no business logic) and marts apply business logic (rankings, deduplication, joins) and create indexed tables. But this is just one approach — adapt the layering to your domain.

**Why uv for dependencies:** dbt is a Python tool, and managing Python dependencies alongside a Node.js project can be painful. [uv](https://docs.astral.sh/uv/) solves this by providing fast, deterministic Python dependency management with a lockfile (`uv.lock`). This makes it easy to run dbt both locally and in GitHub Actions, and simplifies setup for multiple contributors — no more “which Python version do I need?” issues.

### Key Files

| File                                  | Purpose                               |
| ------------------------------------- | ------------------------------------- |
| `dbt/pyproject.toml`                  | Python deps (uv-managed)              |
| `dbt/dbt_project.yml`                 | dbt project config                    |
| `dbt/profiles.yml`                    | Dev/prod connection targets           |
| `dbt/macros/generate_schema_name.sql` | Custom schema routing                 |
| `dbt/models/staging/*.sql`            | Staging views                         |
| `dbt/models/marts/*.sql`              | Mart tables (business logic, indexed) |
| `src/lib/db/marts.ts`                 | TypeScript query layer for marts      |

### Configuration

**pyproject.toml** — uv-managed Python 3.12:

```toml
[project]
name = "<appname>-dbt"
version = "0.0.0"
requires-python = ">=3.12,<3.14"
dependencies = ["dbt-postgres>=1.9,<2"]
```

**dbt_project.yml** — Model materialization:

```yaml
name: <appname>
version: "1.0.0"
config-version: 2
profile: <appname>

models:
  <appname>:
    staging:
      +materialized: view
      +schema: staging
    marts:
      +materialized: table
      +schema: marts
```

**profiles.yml** — Dev and prod targets:

```yaml
<appname>:
  target: dev
  outputs:
    dev:
      type: postgres
      host: "{{ env_var('DB_HOST', 'localhost') }}"
      port: "{{ env_var('DB_PORT', '5432') | int }}"
      user: "{{ env_var('DB_USER', '<appname>') }}"
      password: "{{ env_var('DB_PASSWORD', '<appname>_local') }}"
      dbname: "{{ env_var('DB_NAME', '<appname>') }}"
      schema: staging
      threads: 4
    prod:
      type: postgres
      host: "{{ env_var('DB_HOST') }}"
      port: "{{ env_var('DB_PORT', '5432') | int }}"
      user: "{{ env_var('DB_USER') }}"
      password: "{{ env_var('DB_PASSWORD') }}"
      dbname: "{{ env_var('DB_NAME') }}"
      schema: staging
      threads: 4
      sslmode: require
```

**Custom schema macro** (`dbt/macros/generate_schema_name.sql`):

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}
```

This overrides dbt’s default behavior. Without it, dbt would create schemas like `staging_staging` (concatenating `{target_schema}_{custom_schema}`). With this macro, models go directly to `staging` or `marts`.

### Setup & Running

```bash
cd dbt
uv sync           # First time only — install Python deps
uv run dbt deps   # Install dbt packages
uv run dbt build  # Run all models + tests
```

Always run dbt commands from the `dbt/` directory with `uv run dbt ...`.

### Gotchas & Conventions

- **Staging models are views** (cheap, always up to date). Mart models are **tables** (materialized for performance, need explicit refresh).
- **dbt is CLI-only** — no frontend trigger. Run `uv run dbt build` after ingestion to refresh marts.
- **Mart queries use `rawPool`** (not Prisma) since they query `staging.*` and `marts.*` schemas.
- **`safeQuery()` in `marts.ts`** returns `[]` when tables don’t exist yet, allowing the app to work gracefully before dbt has been run.
- **Dev defaults** in `profiles.yml` use `env_var('DB_HOST', 'localhost')` — no `.env` file needed for local dbt.
- **The `generate_schema_name` macro is essential** — without it, your models end up in the wrong schemas.

---

## 7. Authentication

> **Skip this if:** your app has no user accounts (static sites, public APIs, internal tools with network-level auth)
> **You need this if:** your app needs user sign-in, session management, or protected routes

### Purpose

This section covers two authentication approaches. Choose the one that fits your project:

1. **OAuth (Auth.js)** — Third-party sign-in (Google, GitHub, etc.) with minimal setup. No email service required.
2. **OTP + JWT (jose)** — Email-based one-time password with custom session management. Requires an email service (SES, Resend, etc.) for production, but can use console logging for local dev.

**Why two options?** OAuth is simpler to set up and doesn’t require an email service, making it ideal for MVPs and consumer apps. OTP gives you full control over the auth flow and works well for internal tools and B2B apps where you need custom role assignment at sign-up. Standard email/password auth is not covered here because it requires an email service anyway (for verification and password resets), and OTP provides a better UX with the same infrastructure.

Route protection in both cases uses Next.js 16’s `proxy.ts` pattern (not the deprecated `middleware.ts`).

### Option A: OAuth (Auth.js)

#### Key Files

| File                      | Purpose                                        |
| ------------------------- | ---------------------------------------------- |
| `src/auth.ts`             | Auth.js config (providers, adapter, callbacks) |
| `src/proxy.ts`            | Route protection (cookie check + redirect)     |
| `src/app/providers.tsx`   | SessionProvider wrapper                        |
| `src/lib/auth/session.ts` | Server-side session verification               |

#### Configuration

**src/auth.ts** — Auth.js setup:

```typescript
import NextAuth from "next-auth";
import Google from "next-auth/providers/google";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { prisma } from "@/lib/db/client";

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma as never),
  providers: [Google],
  session: { strategy: "jwt" },
  pages: { signIn: "/sign-in" },
  trustHost: true,
  callbacks: {
    jwt({ token, user }) {
      if (user?.id) {
        token.sub = user.id;
      }
      return token;
    },
    session({ session, token }) {
      if (token.sub) {
        session.user.id = token.sub;
      }
      return session;
    },
  },
});
```

**src/proxy.ts** — Route protection (Next.js 16 pattern):

```typescript
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const protectedPatterns = [
  /^\/(dashboard)(.*)/,
  /^\/account(.*)/,
  /^\/settings(.*)/,
];

export default function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isProtected = protectedPatterns.some((pattern) =>
    pattern.test(pathname),
  );

  if (!isProtected) {
    return NextResponse.next();
  }

  const sessionToken =
    request.cookies.get("authjs.session-token") ??
    request.cookies.get("__Secure-authjs.session-token");

  if (!sessionToken) {
    const signInUrl = new URL("/sign-in", request.url);
    signInUrl.searchParams.set("callbackUrl", pathname);
    return NextResponse.redirect(signInUrl);
  }

  return NextResponse.next();
}
```

#### Environment Variables (OAuth)

```env
AUTH_SECRET=        # generate with: npx auth secret
AUTH_GOOGLE_ID=
AUTH_GOOGLE_SECRET=
AUTH_URL=http://localhost:3000
```

#### OAuth Gotchas

- **JWT strategy** (not database sessions) for performance. The `jwt` callback copies `user.id` to `token.sub`, the `session` callback copies it back.
- **`PrismaAdapter(prisma as never)`** — the `as never` cast is needed due to a Prisma adapter type mismatch when using `@prisma/adapter-pg`.
- **`trustHost: true`** is required for Vercel deployment.
- **Cookie names differ** between dev and prod: `authjs.session-token` (HTTP) vs `__Secure-authjs.session-token` (HTTPS). The proxy checks both.

### Option B: OTP + JWT (jose)

This approach uses email-based one-time passwords with custom JWT sessions via the `jose` library. It gives you full control over the auth flow and integrates naturally with RBAC (see [Section 8](#8-role-based-access-control-rbac)).

#### Key Files

| File                            | Purpose                                           |
| ------------------------------- | ------------------------------------------------- |
| `src/lib/auth/otp.ts`           | OTP generation, validation, expiry                |
| `src/lib/auth/sessions.ts`      | JWT creation/verification with jose               |
| `src/lib/auth/email.ts`         | Email provider abstraction (console/SES)          |
| `src/proxy.ts`                  | Route protection (JWT cookie check + RBAC)        |
| `src/app/(auth)/login/page.tsx` | Login page with OTP form                          |
| `src/app/api/auth/`             | Auth API routes (request-otp, verify-otp, logout) |

#### OTP Flow

```
1. User enters email on login page
2. Server generates 6-digit OTP, stores hash in DB with expiry
3. Email sent via configured provider (console in dev, SES/Resend in prod)
4. User enters OTP on verification page
5. Server validates OTP hash and expiry
6. Server creates JWT session token (signed with jose, stored as httpOnly cookie)
7. Subsequent requests validated via proxy.ts (cookie → JWT verification)
```

#### Key Patterns

**OTP generation** (`src/lib/auth/otp.ts`):

- Generate a random 6-digit code
- Store a SHA-256 hash (never the raw code) in the database with an expiry timestamp
- Validate by hashing the submitted code and comparing
- Delete the OTP record after successful verification (single use)

**JWT sessions** (`src/lib/auth/sessions.ts`):

- Use `jose` library for JWT signing and verification
- Store the JWT as an `httpOnly`, `secure`, `sameSite: lax` cookie
- Include `userId`, `email`, and `role` in the JWT payload
- Session expiry configurable via `SESSION_SECRET` env var

**Email provider abstraction** (`src/lib/auth/email.ts`):

- `console` provider logs OTP to server console (local dev — no email service needed)
- `ses` or `resend` provider sends real emails in production
- Controlled by `EMAIL_PROVIDER` env var
- Mock auth mode (`NEXT_PUBLIC_ENABLE_MOCK_AUTH=true`) bypasses OTP entirely for development

#### Environment Variables (OTP)

```env
SESSION_SECRET="generate-a-random-64-char-hex-string"
OTP_EXPIRY_MINUTES=10
EMAIL_PROVIDER=console   # console | ses | resend
NEXT_PUBLIC_ENABLE_MOCK_AUTH=true   # Skip OTP in dev
```

#### OTP Gotchas

- **Never store raw OTP codes** — always hash before storing.
- **Mock auth mode** (`NEXT_PUBLIC_ENABLE_MOCK_AUTH=true`) is essential for local development and testing. It bypasses the OTP flow entirely. Never enable in production.
- **Console email provider** logs OTP codes to the server terminal — check your `next dev` output to find the code during local development.
- **Two-layer auth:** The proxy is an optimistic first check (fast, cookie-only). Server-side `getSessionFromRequest()` is the definitive check (validates the JWT).

### Shared Gotchas (Both Options)

- **Next.js 16 uses `proxy.ts`, NOT `middleware.ts`** — the middleware convention is deprecated. This is the single biggest gotcha when starting a new Next.js 16 project.
- **Two-layer auth:** The proxy is an optimistic first check (fast, cookie-only). Server-side session verification is the definitive check (validates the token, hits the DB if needed).

---

## 8. Role-Based Access Control (RBAC)

> **Skip this if:** your app has no concept of user roles or permissions (all users see the same thing)
> **You need this if:** different users should see different pages, perform different actions, or access different API endpoints based on their role

### Purpose

RBAC controls what authenticated users can do. It works as a layer on top of authentication — auth determines _who_ you are, RBAC determines _what you can do_. This section covers the data model, server-side enforcement, client-side checks, and checklists for adding new roles and permissions.

### Key Files

| File                               | Purpose                             |
| ---------------------------------- | ----------------------------------- |
| `src/lib/rbac/roles.ts`            | Role and permission definitions     |
| `src/lib/rbac/permissions.ts`      | Permission checking functions       |
| `src/proxy.ts`                     | Route-level RBAC enforcement        |
| `src/hooks/useRbac.ts`             | Client-side permission checks       |
| `src/contexts/AuthContext.tsx`     | Auth + role state provider          |
| `src/lib/references/rbac-guide.md` | Deep-dive reference with checklists |

### Data Model

Roles are stored on the User model (or a junction table for multi-role systems):

```prisma
enum Role {
  ADMIN
  MANAGER
  USER
}

model User {
  id        String   @id @default(uuid()) @db.Uuid
  email     String   @unique
  role      Role     @default(USER)
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}
```

### Permission Definitions

Define permissions as a map from roles to allowed actions:

```typescript
// src/lib/rbac/roles.ts
export const ROLE_PERMISSIONS: Record<Role, string[]> = {
  ADMIN: [
    "users:read",
    "users:write",
    "users:delete",
    "settings:read",
    "settings:write",
    "reports:read",
  ],
  MANAGER: ["users:read", "users:write", "settings:read", "reports:read"],
  USER: ["settings:read"],
};

export function hasPermission(role: Role, permission: string): boolean {
  return ROLE_PERMISSIONS[role]?.includes(permission) ?? false;
}
```

### Server-Side Enforcement

**In `proxy.ts`** — route-level protection:

```typescript
// Define which routes require which roles
const routeRoleMap: Record<string, Role[]> = {
  "/admin": ["ADMIN"],
  "/management": ["ADMIN", "MANAGER"],
  "/dashboard": ["ADMIN", "MANAGER", "USER"],
};
```

The proxy checks the JWT payload’s `role` field against the route’s required roles. If the user’s role isn’t in the list, redirect to an unauthorized page.

**In API routes** — endpoint-level protection:

```typescript
// In any API route handler
const session = await getSessionFromRequest(request);
if (!session || !hasPermission(session.role, "users:write")) {
  return NextResponse.json({ error: "Forbidden" }, { status: 403 });
}
```

### Client-Side Checks

**`useRbac()` hook** for conditional UI rendering:

```typescript
// src/hooks/useRbac.ts
export function useRbac() {
  const { user } = useAuth();

  return {
    can: (permission: string) => hasPermission(user.role, permission),
    isRole: (role: Role) => user.role === role,
    isAdmin: user.role === "ADMIN",
  };
}

// Usage in components
const { can, isAdmin } = useRbac();

{can("users:write") && <EditUserButton />}
{isAdmin && <AdminPanel />}
```

### Checklists

**How to add a new role:**

1. Add the role to the `Role` enum in `prisma/schema.prisma`
2. Run `pnpm prisma migrate dev --name add_role_<name>`
3. Add permission mappings in `src/lib/rbac/roles.ts`
4. Add route access entries in `src/proxy.ts`
5. Update `prisma/AGENTS.md` with the new role
6. Update `src/lib/references/rbac-guide.md`

**How to add a new permission:**

1. Add the permission string to the relevant roles in `src/lib/rbac/roles.ts`
2. Add server-side checks where the permission is enforced
3. Add client-side `can()` checks for UI elements
4. Update `src/lib/references/rbac-guide.md`

**How to add a new protected page:**

1. Create the page component in `src/app/(dashboard)/`
2. Add the route pattern to `proxy.ts` with role requirements
3. Add navigation entry (conditionally rendered based on role)
4. Update `src/components/references/adding-a-page.md`

### Gotchas & Conventions

- **RBAC checks are always server-side first.** Client-side `useRbac()` is for UI convenience (hiding buttons), not security. The proxy and API routes are the real enforcement layer.
- **Keep the permission model flat** — `resource:action` format (e.g., `users:write`, `reports:read`) scales well and is easy to reason about.
- **Never check roles directly in components** — use `can(permission)` instead. This decouples UI from role definitions and makes it easy to change what a role can do without updating every component.
- **Impersonation** (admin acting as another user) should be logged and auditable. Include the impersonator’s ID in the session payload if you implement this.

---

## 9. Validation (Zod)

> **Skip this if:** your app doesn’t consume external APIs or accept complex user input
> **You need this if:** you consume external APIs, process webhooks, or need runtime type validation

### Purpose

Zod v4 validates data at runtime. Every response from an external API should be parsed through a Zod schema before your app touches it. This catches API changes, malformed data, and type mismatches before they cause bugs downstream. Zod is also used for validating user input in forms and API request bodies.

### Key Pattern

```typescript
import { z } from "zod/v4";

// Schema with coercion for string-typed numbers
const ProductSchema = z
  .object({
    id: z.number(),
    name: z.string(),
    price: z.number(),
    discount: z.coerce.number(), // Comes as "0.15" string — coerced to number
  })
  .passthrough(); // Allow unknown fields for forward compat

// Type inference
type Product = z.infer<typeof ProductSchema>;
```

### Patterns Used

| Pattern                             | When to Use                                                    |
| ----------------------------------- | -------------------------------------------------------------- |
| `z.coerce.number()`                 | API returns numbers as strings (`"3.2"` → `3.2`)               |
| `.passthrough()`                    | External APIs may add new fields — don’t break on unknown keys |
| `z.record(z.string(), z.unknown())` | Zod v4 requires two args for `z.record()`                      |
| `z.string().uuid()`                 | Validates strict RFC 4122 format                               |

### Gotchas & Conventions

- **Zod v4 breaking change:** `z.record()` needs two args. `z.record(z.unknown())` won’t compile — use `z.record(z.string(), z.unknown())`.
- **Always `.passthrough()`** on external API response objects. If the API adds a new field, your app shouldn’t crash.
- **Keep fixture files** with real API responses (`src/tests/fixtures/*.json`) — use these in schema tests to catch regressions.
- **Validate at the boundary**, not everywhere. Internal function calls between your own modules don’t need Zod validation.

---

## 10. Testing (Vitest)

> **Skip this if:** never (testing is not optional)
> **You need this if:** always

### Purpose

Vitest with mocked dependencies — no real database or network calls needed. Tests run fast, in isolation, and in CI.

### Key Files

| File                        | Purpose                               |
| --------------------------- | ------------------------------------- |
| `vitest.config.ts`          | Test runner config                    |
| `src/tests/setup.ts`        | Global mocks (Prisma, next/cache)     |
| `src/tests/fixtures/*.json` | Real API response fixtures            |
| `docs/testing.md`           | Full testing conventions and patterns |

### Configuration

**vitest.config.ts:**

```typescript
import { defineConfig } from "vitest/config";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    environment: "node",
    globals: false,
    setupFiles: ["./src/tests/setup.ts"],
    coverage: {
      provider: "v8",
      include: ["src/lib/**/*.ts"],
      exclude: ["src/lib/db/client.ts"],
    },
  },
});
```

**src/tests/setup.ts** — Global mocks:

```typescript
import { vi } from "vitest";

// Mock Next.js cache functions (used in server components/actions)
vi.mock("next/cache", () => ({
  unstable_cache: <T extends (...args: unknown[]) => unknown>(fn: T) => fn,
  revalidateTag: vi.fn(),
  revalidatePath: vi.fn(),
}));

// Mock Prisma with all model methods
const mockPrismaModel = () => ({
  create: vi.fn(),
  createMany: vi.fn(),
  update: vi.fn(),
  updateMany: vi.fn(),
  delete: vi.fn(),
  deleteMany: vi.fn(),
  findFirst: vi.fn(),
  findMany: vi.fn(),
  findUnique: vi.fn(),
  upsert: vi.fn(),
  count: vi.fn(),
});

// Add a mock for each of your Prisma models
vi.mock("@/lib/db/client", () => {
  return {
    prisma: {
      user: mockPrismaModel(),
      // ... add your models here
      $disconnect: vi.fn(),
      $transaction: vi.fn((fn: (tx: unknown) => unknown) =>
        fn({
          user: mockPrismaModel(),
          // ... mirror the models above
        }),
      ),
    },
  };
});
```

### Mock Patterns

| What to Mock      | How                                                                |
| ----------------- | ------------------------------------------------------------------ |
| **Prisma**        | Global setup file (above) — provides all model methods             |
| **HTTP calls**    | Mock `global.fetch` directly in the test file                      |
| **pg Pool**       | `vi.mock("@/lib/db/raw")` with `rawPool: { query: vi.fn() }`       |
| **S3 client**     | `vi.mock("@/lib/s3/client")` with individual function mocks        |
| **Auth**          | `vi.mock("@/auth")` with `auth: vi.fn()` returning session or null |
| **Next.js cache** | Handled in global setup (passthrough for `unstable_cache`)         |

### Gotchas & Conventions

- **`vite-tsconfig-paths` is required** for `@/*` path aliases to work in Vitest.
- **`globals: false`** — always `import { describe, it, expect, vi } from "vitest"` explicitly.
- **`vi.clearAllMocks()` in `beforeEach` wipes mock return values** set in `vi.mock()` factories. If you use `clearAllMocks`, you must re-set auth mocks in each `beforeEach`.
- **Use `as never`** (not `as any`) for mock return values that don’t match full Prisma types.
- **Fixture files** (`src/tests/fixtures/*.json`) contain real API responses. Use them in schema validation tests to catch regressions when APIs change.
- **Coverage excludes** files that are hard to test in isolation (DB client singletons). Set realistic thresholds — 100% is not the goal.
- **Colocate tests** — `otp.test.ts` lives next to `otp.ts`, not in a separate `__tests__` directory.

---

## 11. UI Framework (shadcn/ui)

> **Skip this if:** you’re building a headless API or using a different UI library
> **You need this if:** you’re building a web UI and want high-quality, customizable components

### Purpose

shadcn/ui provides accessible, composable UI components. Components are generated into your project (not imported from a package), so you own and can customize every line. To build custom themes, visit [tweakcn](https://tweakcn.com) for a visual theme editor that generates shadcn-compatible CSS variables.

### Key Files

| File                                   | Purpose                                      |
| -------------------------------------- | -------------------------------------------- |
| `components.json`                      | shadcn configuration (style, aliases, icons) |
| `src/app/globals.css`                  | Theme variables and Tailwind imports         |
| `src/components/ui/*.tsx`              | Generated shadcn components                  |
| `src/components/ui/button-variants.ts` | buttonVariants helper for server components  |

### Configuration

**components.json:**

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "iconLibrary": "lucide",
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
```

### Adding Components

```bash
pnpm dlx shadcn@latest add <component>   # e.g., pnpm dlx shadcn@latest add dialog
```

The CLI reads `components.json` and generates the output into `src/components/ui/`.

### Gotchas & Conventions

- **Never hardcode colors** like `bg-zinc-50`, `text-white`, or `border-gray-200`. Always use CSS theme variables: `bg-sidebar`, `text-primary`, `border-border`, `bg-muted`, etc. This ensures both light and dark mode work correctly.
- **Icons from `lucide-react` only** — never hand-roll SVGs for standard UI icons (home, user, plus, settings, etc.). Custom SVGs are fine for brand logos only.
- **`TooltipProvider`** must be mounted in `src/app/providers.tsx` — it’s required by the shadcn sidebar component.
- **Sidebar pattern:** `SidebarProvider` + `Sidebar` + `SidebarInset` for desktop, separate `BottomNav` for mobile.
- **Check the shadcn style you chose** — different styles (new-york, default, base-nova) use different underlying libraries (Radix vs @base-ui/react) and have different component APIs. base-nova has no `asChild` prop on buttons, for example.

---

## 12. S3 Media Uploads

> **Skip this if:** your app doesn’t accept user-uploaded files, or file sizes are small enough to handle through standard form uploads
> **You need this if:** users upload files larger than ~4MB and you need secure, scalable file storage

### Purpose

Presigned URL flow for direct browser-to-S3 uploads. This pattern solves a specific problem: **serverless platforms like Vercel have request body size limits** (4.5MB on Vercel). By generating a presigned PUT URL server-side and having the client upload directly to S3, the file never passes through your server. For smaller files that fit within your platform’s body limit, standard form uploads to an API route are simpler and perfectly fine.

S3 object tags are used to configure lifecycle policies for automatic cleanup. Tags like `retention: "7d"` or `retention: "30d"` are applied to objects server-side, and S3 lifecycle rules (configured in the AWS console or via IaC) automatically delete objects when they expire. This keeps storage costs predictable without application-level cleanup code.

### Key Files

| File                       | Purpose                                           |
| -------------------------- | ------------------------------------------------- |
| `src/lib/s3/client.ts`     | S3 operations (upload URL, view URL, tag, delete) |
| `src/lib/s3/validation.ts` | Accepted MIME types, size limits                  |
| `src/lib/s3/media-urls.ts` | Batch presigned GET URL resolver                  |
| `next.config.ts`           | CSP directives for S3 domains                     |

### Configuration

**S3 client** (`src/lib/s3/client.ts`):

```typescript
import {
  S3Client,
  PutObjectCommand,
  PutObjectTaggingCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const bucket = process.env.S3_BUCKET_NAME!;
const s3 = new S3Client({
  region: process.env.S3_REGION ?? "eu-west-2",
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY_ID!,
    secretAccessKey: process.env.S3_SECRET_ACCESS_KEY!,
  },
});

// Presigned PUT URL (5-min expiry) — client uploads directly
export async function generateUploadUrl(
  key: string,
  contentType: string,
): Promise<string> {
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    ContentType: contentType,
  });
  return getSignedUrl(s3, command, { expiresIn: 300 });
}

// Presigned GET URL (1-hour expiry) — for viewing
export async function generateViewUrl(key: string): Promise<string> {
  const command = new GetObjectCommand({ Bucket: bucket, Key: key });
  return getSignedUrl(s3, command, { expiresIn: 3600 });
}

// Tag object with retention policy for S3 lifecycle rules
export async function tagObject(key: string, retention: string): Promise<void> {
  const command = new PutObjectTaggingCommand({
    Bucket: bucket,
    Key: key,
    Tagging: { TagSet: [{ Key: "retention", Value: retention }] },
  });
  await s3.send(command);
}

// Delete object
export async function deleteObject(key: string): Promise<void> {
  await s3.send(new DeleteObjectCommand({ Bucket: bucket, Key: key }));
}
```

**Validation** (`src/lib/s3/validation.ts`):

```typescript
export const ACCEPTED_IMAGE_TYPES = [
  "image/jpeg",
  "image/png",
  "image/heic",
  "image/webp",
] as const;
export const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5 MB post-compression
```

### Upload Flow

```
1. Client requests presigned PUT URL from server (with content type + key)
2. Server validates the request, generates presigned URL, returns it
3. Client uploads directly to S3 using the presigned URL
4. Client notifies server that upload is complete
5. Server tags the S3 object with retention policy
6. DB stores only the S3 key (not the full URL)
```

### Environment Variables

```env
S3_BUCKET_NAME=your-bucket-name
S3_REGION=eu-west-2
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
```

### Gotchas & Conventions

- **Store only the S3 object key in the DB**, not the full URL. Generate presigned view URLs on demand.
- **Key format:** `{scopeId}/{resourceId}/{nanoid}.{ext}` — structured for easy cleanup and access control.
- **Retention via S3 tags + lifecycle rules**, not application code. Tag objects with `retention: "7d"` or `retention: "30d"`, then configure S3 lifecycle rules to delete based on tags. See [AWS S3 lifecycle documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) for setup.
- **CSP configuration required** — add S3 domains to `img-src`, `media-src`, and `connect-src` in `next.config.ts`.
- **Client-side compression** before upload (max 1200px, JPEG 0.8 quality) keeps uploads fast and storage costs low.
- **Block all public access** on the S3 bucket — all reads go through presigned GET URLs.

---

## 13. Push Notifications

> **Skip this if:** your app doesn’t need real-time user notifications
> **You need this if:** you need to alert users about events when they’re not actively using the app

### Purpose

Web Push API notifications with VAPID keys. The service worker handles push events only (no caching, no offline support) to keep things simple.

**Important:** Since this is a web app (not a native app), you won’t get true push notifications on all platforms. On iOS Safari, users must install the app as a PWA (add to Home Screen) before push notifications will work. On Android and desktop browsers, notifications work without PWA installation but the user still needs to grant permission.

### Key Components

| Component                      | Purpose                                            |
| ------------------------------ | -------------------------------------------------- |
| `public/sw.js`                 | Service worker (push + notificationclick handlers) |
| `web-push` npm package         | Server-side push delivery                          |
| `PushSubscription` model       | Stores browser push endpoints                      |
| `NotificationPreference` model | Per-type opt-in/out                                |
| `Notification` model           | Delivery log with idempotency                      |

### Key Patterns

**Idempotency keys** prevent duplicate notifications. The `Notification` model has a `@@unique([userId, idempotencyKey])` constraint. Before sending, check if a notification with that key already exists.

**Preferences default to enabled** — users opt out, not in. The `NotificationPreference` model stores `pushEnabled: Boolean @default(true)` per notification type.

**Service worker** handles only push events — no caching, no fetch interception, no offline mode. This is intentional: a push-only service worker is trivial to debug and doesn’t interfere with Next.js’s own caching.

### Environment Variables

```env
VAPID_PUBLIC_KEY=     # Generate with: npx web-push generate-vapid-keys
VAPID_PRIVATE_KEY=
VAPID_SUBJECT=mailto:you@example.com
NEXT_PUBLIC_VAPID_PUBLIC_KEY=   # Same as VAPID_PUBLIC_KEY (exposed to client)
```

### Gotchas & Conventions

- **Generate VAPID keys once** with `npx web-push generate-vapid-keys` and store them permanently. Changing keys invalidates all existing subscriptions.
- **The `NEXT_PUBLIC_` prefix** exposes the public key to the client (needed for subscription). The private key stays server-only.
- **iOS Safari** supports Web Push but has quirks — the app must be installed as a PWA first.
- **Keep the service worker minimal.** Adding caching or fetch interception creates hard-to-debug issues with Next.js hot reload and routing.

---

## 14. CI/CD (GitHub Actions)

> **Skip this if:** you’re the only developer and don’t deploy to production
> **You need this if:** you have a team, deploy to production, want automated quality gates, or need to run scheduled pipelines (e.g., dbt transforms). Use gates to determine when a pipeline should run to save unnecessary Actions minutes and cost.

### Purpose

GitHub Actions for automated lint/test on PRs, and scheduled data pipeline execution.

### Key Files

| File                             | Purpose                                 |
| -------------------------------- | --------------------------------------- |
| `.github/workflows/ci.yml`       | Lint + typecheck + test on every PR     |
| `.github/workflows/pipeline.yml` | Scheduled data pipeline (if applicable) |

### Configuration

**ci.yml** — Quality gates on every PR:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  check:
    name: Lint, Type Check & Test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 10

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Generate Prisma client
        run: npx prisma generate

      - name: Lint
        run: pnpm lint

      - name: Type check
        run: npx tsc --noEmit

      - name: Test with coverage
        run: pnpm test:coverage
```

**pipeline.yml** — Scheduled pipeline with “should-run” gate:

```yaml
name: Data Pipeline

on:
  schedule:
    - cron: "0 */2 * * *"
  workflow_dispatch:

env:
  APP_URL: ${{ vars.APP_URL }}
  PIPELINE_API_KEY: ${{ secrets.PIPELINE_API_KEY }}

jobs:
  pipeline:
    runs-on: ubuntu-latest
    steps:
      - name: Gate — should pipeline run?
        id: gate
        run: |
          RESPONSE=$(curl -sf -H "Authorization: Bearer $PIPELINE_API_KEY" \
            "$APP_URL/api/pipeline/should-run")
          SHOULD_RUN=$(echo "$RESPONSE" | jq -r '.shouldRun')
          echo "should_run=$SHOULD_RUN" >> "$GITHUB_OUTPUT"

      - name: Run pipeline
        if: steps.gate.outputs.should_run == 'true'
        run: |
          curl -sf -X POST -H "Authorization: Bearer $PIPELINE_API_KEY" \
            "$APP_URL/api/pipeline/run"
```

### Gotchas & Conventions

- **`npx prisma generate` must run before lint/typecheck** in CI — it generates the types that TypeScript needs.
- **The “should-run” gate pattern** saves ~95% of Actions minutes. The app’s own API decides whether there’s new data to process, and the pipeline skips if not. Adopt this pattern for any scheduled pipeline.
- **Pipeline steps are API calls** to the deployed app, not CLI scripts. The app has `/api/pipeline/*` routes protected by `PIPELINE_API_KEY`. This means the pipeline logic lives in your app (testable, deployable) rather than in bash scripts.
- **dbt runs in CI** need `astral-sh/setup-uv@v4` with cache on `dbt/uv.lock` and DB credentials as secrets.
- **`pnpm/action-setup@v4`** with `version: 10` — always pin the pnpm version to match your local version.
- **`workflow_dispatch`** on all workflows enables manual triggering from the GitHub UI — invaluable for debugging.

---

## 15. Pre-commit Hooks

> **Skip this if:** you’re comfortable relying solely on CI for quality checks
> **You need this if:** you want to catch issues before they ever get pushed

### Purpose

Native git hooks (no Husky dependency) that run lint, typecheck, and tests before every commit. Catches issues instantly rather than waiting for CI.

### Key Files

| File                            | Purpose                            |
| ------------------------------- | ---------------------------------- |
| `.githooks/pre-commit`          | The hook script                    |
| `package.json` `prepare` script | Configures git to use `.githooks/` |

### Configuration

**.githooks/pre-commit:**

```bash
#!/bin/sh
set -e

echo "Running lint..."
pnpm lint

echo "Running type check..."
npx tsc --noEmit

echo "Running tests..."
pnpm test
```

**package.json** `prepare` script:

```json
{
  "scripts": {
    "prepare": "git config core.hooksPath .githooks"
  }
}
```

### Setup

The `prepare` script runs automatically on `pnpm install`, setting `core.hooksPath` to `.githooks/`. No additional setup needed.

The hook file must be executable:

```bash
chmod +x .githooks/pre-commit
```

### Gotchas & Conventions

- **No Husky or lint-staged** — native `.githooks/` with `git config core.hooksPath` is simpler and has zero dependencies.
- **The `prepare` script runs on `pnpm install`**, so any developer who clones and installs automatically gets hooks configured.
- **The hook runs the same checks as CI** (lint + typecheck + tests). This means CI failures are extremely rare because issues are caught locally first.
- **To skip the hook** (emergency): `git commit --no-verify`. Use sparingly.

---

## 16. Deployment

> **Skip this if:** you’re only running locally
> **You need this if:** you’re deploying to production

### Purpose

Vercel deployment with Prisma client generation and migration in the build step. Neon Postgres for the production database. Security headers configured in `next.config.ts`.

### Key Files

| File                          | Purpose                                                  |
| ----------------------------- | -------------------------------------------------------- |
| `package.json` `build` script | `prisma generate && prisma migrate deploy && next build` |
| `next.config.ts`              | Security headers (CSP, HSTS, X-Frame-Options)            |
| `.env.example`                | Complete env var reference                               |

### Build Script

```json
{
  "build": "prisma generate && prisma migrate deploy && next build"
}
```

- `prisma generate` — generates TypeScript types from the schema
- `prisma migrate deploy` — applies any pending migrations (safe for production — only applies, never creates)
- `next build` — builds the Next.js app

### Security Headers

**next.config.ts:**

```typescript
import type { NextConfig } from "next";

const isDev = process.env.NODE_ENV === "development";

const cspDirectives = [
  "default-src 'self'",
  `script-src 'self' 'unsafe-inline'${isDev ? " 'unsafe-eval'" : ""}`,
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data: blob:",
  "connect-src 'self'",
  "worker-src 'self'",
  "frame-ancestors 'none'",
  "form-action 'self'",
  "base-uri 'self'",
];

const securityHeaders = [
  { key: "Content-Security-Policy", value: cspDirectives.join("; ") },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "X-Frame-Options", value: "DENY" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  {
    key: "Strict-Transport-Security",
    value: "max-age=31536000; includeSubDomains; preload",
  },
  {
    key: "Permissions-Policy",
    value: "camera=(), microphone=(), geolocation=()",
  },
];

const nextConfig: NextConfig = {
  devIndicators: false,
  async headers() {
    return [{ source: "/(.*)", headers: securityHeaders }];
  },
};

export default nextConfig;
```

> **Note:** Add external domains to CSP directives as needed — S3 buckets in `img-src` and `connect-src`, push notification services in `connect-src`, OAuth providers, etc. Missing a domain causes silent failures.

### Environment Variable Checklist

```env
# Database
DATABASE_URL="postgresql://user:pass@host:5432/dbname?schema=public"

# Auth (choose one approach)
# OAuth:
AUTH_SECRET=
AUTH_GOOGLE_ID=
AUTH_GOOGLE_SECRET=
AUTH_URL=https://your-domain.com
# OTP:
SESSION_SECRET=
OTP_EXPIRY_MINUTES=10
EMAIL_PROVIDER=console

# App
NEXT_PUBLIC_APP_NAME="YourApp"

# Pipeline (API key for GitHub Actions, if applicable)
PIPELINE_API_KEY=    # generate with: openssl rand -hex 32

# Web Push (if applicable)
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
VAPID_SUBJECT=mailto:you@example.com
NEXT_PUBLIC_VAPID_PUBLIC_KEY=

# S3 (if applicable)
S3_BUCKET_NAME=
S3_REGION=eu-west-2
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
```

### Gotchas & Conventions

- **CSP must include all external domains** your app talks to — S3 buckets, push notification services, OAuth providers, etc. Missing a domain = silent failures.
- **`'unsafe-eval'` in dev only** — needed for Next.js hot reload. Never in production.
- **`devIndicators: false`** suppresses the Next.js dev mode badge.
- **Neon Postgres** is the production database (serverless Postgres). The Prisma client uses `@prisma/adapter-pg` for connection.

---

## 17. Scripts & CLI Tools

> **Skip this if:** your app has no data pipeline, seeding, or operational needs beyond `dev` and `build`
> **You need this if:** you need CLI tools for data ingestion, testing setup, or operational tasks

### Purpose

TypeScript CLI tools for bespoke operations unique to your project — pipeline orchestration, data ingestion, test data seeding, production database sync. All scripts use `tsx` for direct TypeScript execution and import from `@/lib/*` using path aliases.

**Don’t create scripts preemptively.** Scripts are for solving specific operational problems. If you don’t have a data pipeline or complex seeding needs, you don’t need this section.

### Common Script Types

| Script Type               | Purpose                                            | Example                     |
| ------------------------- | -------------------------------------------------- | --------------------------- |
| **Pipeline orchestrator** | Unified entry point for multi-step data processing | `scripts/pipeline.ts`       |
| **Ingestion**             | Fetch and store data from external APIs            | `scripts/ingest.ts`         |
| **Seed**                  | Generate test data for development                 | `scripts/seed-members.ts`   |
| **Prod sync**             | Pull and sanitize production DB locally            | `scripts/sync-prod-db.sh`   |
| **Schema init**           | Create non-Prisma schemas in Docker                | `scripts/setup-schemas.sql` |

### Patterns

**Unified orchestrator**: A single entry point with subcommands, each calling the relevant library function. Easier to maintain than a dozen separate scripts.

**Prod sync**: `pg_dump` from production, `pg_restore` locally, then **sanitize sensitive data** (delete sessions, null OAuth tokens, delete push subscriptions). Never work with raw production user data locally.

### Gotchas & Conventions

- **All scripts use `tsx`** for TypeScript execution — add it as a devDependency.
- **Scripts import from `@/lib/*`** using path aliases, which `tsx` resolves via `tsconfig.json`.
- **`dotenv/config`** is imported at the top of scripts that need environment variables.
- **The prod sync script sanitizes data** — this is critical. Never skip the sanitization step when pulling production data.

---

## Putting It All Together

### For a New Project

1. **Start with the spec** — Write your V0 product specification before touching code (see [Section 1](#1-ai-assisted-development-spec-driven-workflow)). Refine with AI into a V1 spec, break into phases, then implement phase by phase. Always update phase docs when implementation drifts from the plan.
2. **Scaffold** — Set up Next.js, TypeScript, pnpm, Tailwind, ESLint ([Section 2](#2-project-scaffolding)). Use official CLI init commands.
3. **Add what you need** — Reference the quick reference table at the top to decide which sections apply
4. **Set up AGENTS.md** — Even if you’re not using AI tools, convention docs help any developer onboard faster ([Section 1](#1-ai-assisted-development-spec-driven-workflow))
5. **Set up CI early** — Lint + typecheck + test on every PR catches issues before they compound ([Section 14](#14-cicd-github-actions))
6. **Break work into phases** — Each phase should have clear entry/exit criteria and be completable in 1-3 sessions

### What to Skip for Common Project Types

**Static marketing site:** You need Section 2 (scaffolding), Section 11 (UI), and maybe Section 16 (deployment). Skip everything else — no database, no auth, no pipeline, no S3.

**Simple SaaS app:** Add Sections 3-5 (database), Section 7 (auth), Section 8 (RBAC), Section 10 (testing). Skip dbt, S3, and push notifications unless your specific features need them.

**Data platform / analytics app:** You likely need everything. The dbt + dual-client + pipeline pattern was designed for exactly this use case.

**API backend:** Skip Section 11 (UI) and Section 13 (push notifications). Focus on Sections 2-5, 7-10, and 14-16.

The key principle: **every tool in this doc exists because a real project needed it**. Your project has different needs. Start minimal, add complexity only when a specific feature demands it.
