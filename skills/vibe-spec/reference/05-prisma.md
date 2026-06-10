# Prisma ORM

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
