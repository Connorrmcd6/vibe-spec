---
name: spec-doctor
description: Read-only environment health check for the Vibe-Spec stack. Detects your OS and reports which prerequisite tools (Git, Node, pnpm, Docker, uv) are installed, their versions, and what each is needed for. Installs nothing.
---

You are running **`/spec-doctor`**: a **read-only** health check of the user's
development environment. Consult the `vibe-spec` skill
(`reference/18-prerequisites.md`) for the canonical tool list and detection commands.

**You must not install, modify, or configure anything.** This command only reports.
If something is missing, point the user at `/spec-setup`; if a tool is present but
misbehaving, point them at `/spec-troubleshoot`.

## What to do

1. Detect the OS once (`uname -s` on macOS/Linux; note if on Windows).
2. From `reference/18-prerequisites.md`, run each tool's **detection command** with
   read-only Bash, capturing the version or the "not found" result:
   - `git --version`
   - `node --version`
   - `pnpm --version`
   - `docker --version`, then `docker info` (exit 0 = daemon running) and
     `docker compose version`
   - `uv --version`
   - `gh --version` (optional)
   Run independent checks together. Treat a non-zero exit or "command not found" as
   missing — do not error out; record it and continue.
3. Print a compact status table with one row per tool:

   | Tool | Status | Version | Needed for |
   | --- | --- | --- | --- |

   Use ✓ for present, ✗ for missing. For Docker, surface the daemon state explicitly
   (e.g. "✓ installed, daemon **not running**"). Fill "Needed for" from the reference
   (e.g. Git → always; Node/pnpm → any web app; Docker → local Postgres; uv → dbt).
4. Summarize in one or two lines: what's ready, what's missing, and which missing
   tools actually matter (note that Docker/uv are only needed for some project types).
5. End by telling the user:
   - Run **`/spec-setup`** to install missing tools (guided, only what the project needs).
   - Run **`/spec-troubleshoot`** if a tool is installed but failing.

Keep the output scannable. Do not propose or run install commands here.
