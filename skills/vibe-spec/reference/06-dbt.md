# dbt Transforms

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
