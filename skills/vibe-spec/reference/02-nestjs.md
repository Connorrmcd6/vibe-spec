# High-Performance APIs (NestJS)

> **Skip this if:** you’re building an MVP, a small app, or a typical monorepo — Next.js Route Handlers and Server Actions cover your API needs. This is the right default for almost everything, and for initial versions Next.js is almost always enough.
> **You need this if:** you’ve hit a **specific, measured** limit — sustained high-throughput endpoints, long-lived connections (WebSockets / SSE / streaming), heavy background or queue processing, CPU-bound work, or you need a backend whose lifecycle is independent of the frontend’s serverless deploy model.

### Purpose

Next.js API routes are serverless functions: stateless, with cold starts, execution-time limits, and request body-size limits (the 4.5 MB Vercel limit noted in the [S3 section](12-s3.md)). That model is great for the vast majority of apps. But when an API has to be **extremely performant or long-running**, a dedicated **long-running NestJS server** (using the Fastify adapter) is a better fit.

The default for this stack stays the same — **Next.js for the frontend, plus its own API routes**. NestJS is an escape hatch, not a starting point. It’s overkill for early versions: the decoupled split adds real operational overhead (two deploy targets, CORS, shared-package versioning), so only reach for it when a concrete need appears.

### Decoupled Monorepo Structure

When you do split the backend out, keep both apps in one repo and share the cross-cutting code through packages:

```
my-app/
├── apps/
│   ├── web/          → Next.js (frontend + light API routes)   → Vercel
│   └── api/          → NestJS (high-performance backend)         → container host
├── packages/
│   ├── db/           → shared Prisma schema + client singleton
│   ├── validation/   → shared Zod schemas / DTOs
│   └── types/        → shared TypeScript types
├── pnpm-workspace.yaml
└── turbo.json        (optional — Turborepo for task orchestration)
```

The frontend can still own light BFF-style endpoints; NestJS owns the heavy, performance-critical surface.

### How It Relates to the Rest of This Guide

- **Scaffolding ([Section 2](01-scaffolding.md)):** still pnpm + strict TypeScript, now a workspace with multiple `apps/*`.
- **Database & Prisma ([Sections 5](04-database.md)–[6](05-prisma.md)):** the Prisma client moves into `packages/db`, shared by both apps — one source of truth, never duplicated.
- **Validation ([Section 10](09-validation.md)):** Zod schemas live in `packages/validation`; NestJS validates request bodies against the same schemas the frontend uses.
- **Auth ([Section 8](07-auth.md)) & RBAC ([Section 9](08-rbac.md)):** NestJS verifies the same JWT/session and enforces roles via **Guards** — the server-side equivalent of `proxy.ts` plus API-route checks.
- **Testing ([Section 11](10-testing.md)):** NestJS uses Vitest too — same runner, same conventions.
- **Deployment ([Section 17](16-deployment.md)):** `web` deploys to Vercel; `api` deploys to a long-running container host (Railway / Fly.io / Render / AWS ECS), not Vercel serverless. This requires CORS configuration and a shared auth secret across the two origins.

### Gotchas & Conventions

- **Use the Fastify adapter**, not the default Express adapter, for maximum throughput.
- **Don’t reach for this prematurely.** Two deploy targets, CORS, and shared-package versioning are real costs. Next.js route handlers serve the large majority of apps — split only when you’ve measured a need.
- **Keep one source of truth** for the DB schema and validation via `packages/*`; never fork them between the two apps.
