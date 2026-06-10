# Database Architecture

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
