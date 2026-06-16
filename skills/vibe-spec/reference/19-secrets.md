# Secret Hygiene & Leak Auditing

> **Skip this if:** your app has no secrets at all (rare — even an API base URL config usually has one)
> **You need this if:** you have a `.env` with anything sensitive (almost every app)

### Purpose

Keep secret *values* out of the browser bundle and out of git, and verify it
deterministically rather than by eyeballing. The whole approach rests on one
**trust boundary**:

> A local, auditable script is the only thing that ever touches secret *values*. The
> AI only ever sees variable *names* and pass/fail verdicts — a redacted report.

Secret-matching ("does this exact value appear in this file?") is deterministic string
work — the wrong job for an LLM (non-deterministic, can hallucinate, and requires
*seeing* the secret). So the work is split: a script reads `.env` and the bundle and
classifies; the AI runs it and explains the fixes. This is the same pattern as
[`/spec-doctor`](15-pre-commit.md) — a locked-down command + deterministic script +
redacted report — applied to secrets. See [`16-deployment`](16-deployment.md) for the
production env-var checklist and security headers this complements.

### The `NEXT_PUBLIC_` rule

Next.js inlines any `process.env.NEXT_PUBLIC_*` value into the **client** bundle at
build time. Everything without that prefix is server-only — *unless* you read it inside
a `"use client"` component, in which case the bundler inlines it too. So two mistakes
leak secrets to every browser:

1. **Mis-prefixing** a secret as `NEXT_PUBLIC_*`.
2. **Reading** a server-only var inside client code.

### Known-sensitive vars in this stack

The audit ships with a catalog of names that are sensitive by definition here (a
catalog beats entropy guessing). None of these should ever be `NEXT_PUBLIC_` or appear
in `.next/static`:

| Var | From |
| --- | --- |
| `AUTH_SECRET`, `AUTH_GOOGLE_SECRET`, `SESSION_SECRET` | [`07-auth`](07-auth.md) |
| `S3_SECRET_ACCESS_KEY`, `S3_ACCESS_KEY_ID` | [`12-s3`](12-s3.md) |
| `VAPID_PRIVATE_KEY` | [`13-push-notifications`](13-push-notifications.md) |
| `DATABASE_URL`, `DB_PASSWORD`, `POSTGRES_PASSWORD`, `PGADMIN_DEFAULT_PASSWORD` | [`03-docker`](03-docker.md), [`04-database`](04-database.md) |
| `PIPELINE_API_KEY` | [`17-scripts`](17-scripts.md) |

`NEXT_PUBLIC_VAPID_PUBLIC_KEY` and `NEXT_PUBLIC_APP_NAME` **are** meant to ship to the
browser — they're public by design and the audit treats them as OK.

### The audit script — what it checks

`scripts/secret-audit.sh` (run via **`/spec-secrets`**) layers cheap checks first:

**Static (instant, no build):**
1. **Mis-prefixed secrets** — `NEXT_PUBLIC_*` whose name or value is secret-shaped.
2. **Secrets in client code** — `process.env.<server-only var>` inside `"use client"` files.
3. **Hardcoded literals** — secret-shaped strings in source (`sk_live_`, JWTs, PEM blocks, URLs with credentials).
4. **Hygiene** — is `.env` gitignored? Was it ever committed (`git log --all`)?

**Dynamic (definitive, needs `pnpm build`):**
5. For each non-public, secret-shaped var, grep `.next/static/` for its actual value. A hit = confirmed leak. `NEXT_PUBLIC_*` vars are skipped (they belong there).

The **redacted** report shows the variable name, prefix, in-bundle state, verdict, and
on a hit the `file:line` — **never the value**.

### Three surfaces, one engine

| Surface | When | What |
| --- | --- | --- |
| **`/spec-secrets`** | On demand | Full report; AI explains + fixes. Tools locked to the script only. |
| **Pre-commit hook** | Every commit | `secret-audit.sh --staged` runs the *static* checks on staged files; blocks the commit on a 🚨. See [`15-pre-commit`](15-pre-commit.md). |
| **CI gate** | Every PR | Full build + dynamic scan; fails the build on any leak. The backstop that can't be skipped locally. See [`14-ci-cd`](14-ci-cd.md). |

### Wiring the static check into the pre-commit hook

Add to `.githooks/pre-commit` (after the existing lint/type/test checks):

```bash
echo "Auditing for leaked secrets..."
"$CLAUDE_PLUGIN_ROOT/scripts/secret-audit.sh" --staged || exit 1
```

If you vendor the script into the app, point the path at the vendored copy instead.

### Allowlisting intentional public values

False positive on a value that's genuinely public? Add the variable **name** (one per
line) to `.spec-secrets-allow` at the project root. The audit skips allowlisted names
in the mis-prefix and pre-commit checks.

### Gotchas & Conventions

- **Never paste a secret into any AI** — including this one. The whole point is the
  script reads values so the model never has to. `/spec-secrets` has no `Read`/`cat`
  permission by design.
- **Rotate, don't just delete.** If a secret was committed or shipped in a bundle,
  removing it isn't enough — it's in git history / someone's cache. Rotate the key.
- **Entropy heuristics aren't perfect.** The name catalog + `.spec-secrets-allow`
  beats pure entropy; tune the allowlist rather than loosening the patterns.
- **Next.js env resolution order matters** — `.env`, `.env.local`, `.env.[mode]`,
  `.env.[mode].local`, plus platform env (Vercel). The script reads the local files
  in load order; it can't see secrets that live only in the hosting provider's UI.
- **It checks exposure, not policy.** It can't know whether a key *should* exist, and
  it won't catch runtime leaks (e.g. a route returning a secret in its JSON response).
  That's a fair v2.

### Spec-time integration

Security is cheapest when considered at spec time, not bolted on. During
[`/spec-refine`](00-workflow.md), for each capability that needs a secret, note which
env var holds it and that it is **server-only** (never `NEXT_PUBLIC_`). That makes the
later `/spec-secrets` audit a confirmation rather than a discovery.
