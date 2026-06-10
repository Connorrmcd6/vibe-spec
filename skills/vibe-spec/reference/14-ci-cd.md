# CI/CD (GitHub Actions)

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
