# Docker for Local Development

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
