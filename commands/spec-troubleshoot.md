---
name: spec-troubleshoot
description: Diagnose and fix common Vibe-Spec stack problems — tools that are installed but failing, database connection errors, Prisma issues, failing lint/test gates, broken git hooks. Maps the symptom to a cause and a fix, confirming before changing anything.
args:
  - name: problem
    description: A description of what's going wrong, or a pasted error message (optional — you'll be asked if omitted)
    required: false
---

You are running **`/spec-troubleshoot`**: a symptom → cause → fix diagnostician for the
Vibe-Spec stack. Consult the `vibe-spec` skill — start with
`reference/18-prerequisites.md`, then load the **specific** reference for the failing
area (e.g. Prisma ⇒ `05-prisma` + `04-database`; local DB ⇒ `03-docker`; lint/test ⇒
`10-testing` / `14-ci-cd`; commit hooks ⇒ `15-pre-commit`).

## Hard rules

- Diagnostics may run freely (read-only). **Confirm with the user before running any
  command that changes state** (e.g. `docker compose up -d`, `pnpm install`,
  `pnpm prisma generate`, editing files).
- One fix at a time; re-check after each.

## What to do

1. If `$ARGUMENTS` is empty, ask what's going wrong or offer the common categories
   below. If they pasted an error, parse it for the failing tool/area.
2. Run **targeted read-only diagnostics** for the suspected area (daemon status, port
   in use, env var present, versions, install/generate state).
3. Map to a known cause and **propose a fix, then confirm before running it.** Re-run
   the diagnostic to verify it's resolved. Link the relevant reference.

## Common failures catalog

For each: how to confirm → fix → reference.

- **`pnpm: command not found`** — confirm `pnpm --version` fails → install via Corepack
  (`corepack enable`); if it's an npm/pnpm mix-up, note pnpm-not-npm. → `18-prerequisites`, `01-scaffolding`
- **`uv` / `docker` not found** — confirm with `--version` → install per
  `18-prerequisites` (point to `/spec-setup`). → `18-prerequisites`
- **`Cannot connect to the Docker daemon`** — `docker info` exits non-zero → start the
  daemon (Docker Desktop / `colima start` / `sudo systemctl start docker`). → `03-docker`
- **Postgres port 5432 already in use** — `lsof -i :5432` (or `docker ps`) shows a
  conflict → stop the other Postgres or remap the host port in `docker-compose.yml`. → `03-docker`
- **DB connection refused / `DATABASE_URL` missing or wrong** — check `.env` has
  `DATABASE_URL` and the container is up (`docker compose ps`) → fix the URL / start the
  DB. → `03-docker`, `04-database`
- **Prisma: client not generated / `@prisma/client` did not initialize / `src/generated`
  missing** — run `pnpm prisma generate`; for schema drift `pnpm prisma migrate dev`. → `05-prisma`
- **pnpm vs npm lockfile mismatch** (`package-lock.json` present, or "lockfile out of
  date") — remove `package-lock.json`, use `pnpm install`. → `01-scaffolding`
- **Node version too old** (engine warnings, build failures) — `node --version` below
  LTS → switch with `fnm use --lts` / `nvm use --lts`. → `18-prerequisites`, `01-scaffolding`
- **Git hooks not running** (lint/format didn't fire on commit) — `git config
  core.hooksPath` is unset → run `pnpm run prepare` (sets `core.hooksPath .githooks`). → `15-pre-commit`
- **Lint/test gate failing** — run `pnpm lint` / `pnpm test` to see the real error;
  surface it before guessing. → `10-testing`, `14-ci-cd`

If the problem isn't covered, gather the exact error output, identify the tool, and
reason from the relevant reference. End with what was fixed and any follow-up.
