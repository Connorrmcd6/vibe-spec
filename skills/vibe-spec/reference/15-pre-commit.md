# Pre-commit Hooks

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

echo "Auditing for leaked secrets..."
"$CLAUDE_PLUGIN_ROOT/scripts/secret-audit.sh" --staged || exit 1
```

The secret audit runs the fast, build-free static checks on staged files and blocks
the commit if a secret is mis-prefixed, hardcoded, or about to be committed in a
`.env`. See [`19-secrets`](19-secrets.md) for the full picture (and the CI gate that
runs the definitive bundle scan).

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
