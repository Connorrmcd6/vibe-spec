---
description: Audit a Vibe-Spec app for secrets leaking to the browser. A locked-down, redacting command — a local script reads .env and the built bundle, and Claude only ever sees variable NAMES and pass/fail verdicts. Secret values never enter the model's context.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/secret-audit.sh:*)
---

You are running **`/spec-secrets`**: a secret-leak audit for the user's app.

## The trust boundary (do not break it)

A local, auditable script — `${CLAUDE_PLUGIN_ROOT}/scripts/secret-audit.sh` — is the
**only** thing that ever touches secret *values*. It reads `.env` files and the built
bundle, does deterministic exact-match string work locally, and prints a **redacted**
report: variable *names*, verdicts, and `file:line` locations only. You see that
report and nothing else.

**Your tools are locked to that one script for a reason.** You must **never** attempt
to read a `.env` file, `cat`/`grep` env values, or otherwise pull secret values into
your context — and you can't, because no `Read` or general `Bash` is permitted here.
Secret-matching is deterministic string work; the script does it better than an LLM
and without exposing anything. Your job is to run it and *explain* the findings.

## What to do

1. Run the audit script. Pick the invocation from the user's argument (`$ARGUMENTS`):
   - **default** (no arg): static checks + a bundle scan if a build already exists:
     `${CLAUDE_PLUGIN_ROOT}/scripts/secret-audit.sh`
   - **`build`**: run `pnpm build` first, then the definitive browser-exposure scan:
     `${CLAUDE_PLUGIN_ROOT}/scripts/secret-audit.sh --build`
   - To audit a subdirectory, pass `--dir <path>`.
2. Read the **redacted** report from stdout. Each finding is a variable name + verdict
   (+ `file:line` on a confirmed leak). Never ask the user to paste a secret value.
3. **Explain and fix.** This is where you add value — turn each finding into a cause
   and a concrete fix:
   - **🚨 mis-prefixed** (`NEXT_PUBLIC_*` that's secret-shaped): the `NEXT_PUBLIC_`
     prefix ships it to every browser. Rename to drop the prefix and read it only in
     server code; if it's genuinely public, add the name to `.spec-secrets-allow`.
   - **🚨 client-code reference**: a server-only var read inside a `"use client"`
     component is inlined into the bundle. Move the read to a Server Component, route
     handler, or server action and pass down only non-sensitive data.
   - **🚨 hardcoded literal**: a secret-shaped string sits in source — move it to
     `.env` (server-only) and **rotate** it, since it's in git history.
   - **🚨 bundle leak**: the value is confirmed in `.next/static`. Point at the
     `file:line`, trace why it's reachable from client code, and fix the import path.
   - **⚠ hygiene**: `.env` not gitignored, or present in git history — fix
     `.gitignore` and, if it was ever committed, **rotate the secrets**.
4. If everything is clean, say so plainly and note whether the **definitive** bundle
   scan ran (it only runs with a build) — suggest `/spec-secrets build` if it didn't.

## Honest scope

This checks **exposure** (is a value in client-shipped code), not whether a key
*should* exist. It won't catch runtime leaks (e.g. a server route that returns a
secret in its JSON response). For the catalog of stack secrets and the spec-time
security checklist, see
`${CLAUDE_PLUGIN_ROOT}/skills/vibe-spec/reference/19-secrets.md`.

Keep output scannable. Lead with the 🚨 findings; never echo a secret value.
