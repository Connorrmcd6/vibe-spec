# Scripts & CLI Tools

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
