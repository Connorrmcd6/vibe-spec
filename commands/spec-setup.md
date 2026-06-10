---
name: spec-setup
description: Guided environment setup for the Vibe-Spec stack. Figures out which tools your project needs (from your spec, or by project type), checks what's missing, and helps you install only the gaps — proposing exact per-OS commands and running each only after you confirm.
args:
  - name: project_type
    description: One of static | crud | api | data, to skip the interview (optional — derived from your spec or asked if omitted)
    required: false
---

You are running **`/spec-setup`**: a **guided, confirm-each-step** onboarding that
gets the user's machine ready by installing **only the tools their project needs**.
Consult the `vibe-spec` skill (`reference/18-prerequisites.md`) for the tool list,
detection commands, and OS-specific install methods.

## Hard rules

- **Never auto-install.** Propose the exact command and **wait for the user to confirm**
  before running anything. If they decline, just print the command for them to run
  themselves.
- **Never run `sudo`** without surfacing it explicitly and getting confirmation.
- Prefer **user-space installers** (Corepack for pnpm, fnm/nvm for Node, uv, Colima for
  Docker) over system-wide package changes.
- Handle **one tool at a time**, in dependency order.
- **Skip tools that are already present** — just note the version.

## What to do

1. Consult `reference/18-prerequisites.md`.

2. **Determine the required tool set (spec first):**
   - If `docs/project-spec.md` exists, read it and infer the needed tools from the
     features and the tool mappings written during `/spec-refine`:
     - any web app ⇒ **Git, Node, pnpm**
     - Postgres / Prisma / a local database ⇒ **Docker**
     - dbt / data pipelines / transforms ⇒ **uv**
     - Git is **always** required
   - Otherwise, use the `$ARGUMENTS` project type if given, else ask the user which it
     is (static / crud / api / data). Map it to references via the "what do I need?"
     table in `SKILL.md`, then to tools.
   - Tell the user the resolved tool set and why, before proceeding.

3. **Detect what's already installed** (same checks as `/spec-doctor`), scoped to the
   required set. Detect the OS first. For Docker, also check the daemon (`docker info`).

4. **For each MISSING tool, in dependency order (Git → Node → pnpm → Docker → uv):**
   - State what it's for and the recommended **OS-specific** install command from the
     reference (prefer Corepack for pnpm, fnm/nvm for Node).
   - **Ask the user to confirm before running it.** On confirmation, run it; if they
     decline, print the command and move on.
   - **Re-run that tool's detection to verify** it now works before continuing. If it
     still fails, suggest `/spec-troubleshoot` and the reference's alternate install
     method.

5. End with a summary (installed / already-present / skipped) and the next step:
   - If a spec exists and tooling is ready, point to `/spec-refine` or `/spec-implement`
     as appropriate.
   - Otherwise suggest `/spec-draft` to start the workflow.
   - Mention `/spec-doctor` for a re-check anytime.
