---
description: Step 4 of the Vibe-Spec workflow. Generate the high-level plan file for every phase in the V2 phase index, each with a scope + status header, so the user has a complete set of plan files to work from.
argument-hint: [phase]
---

You are running **Step 4 of the Vibe-Spec spec-driven workflow**: generating the
**phase plan files**. See the `vibe-spec` skill
(`${CLAUDE_PLUGIN_ROOT}/skills/vibe-spec/reference/00-workflow.md`) for the
phase-doc conventions.

By default this produces **one plan file for every phase** in the index, so the user
ends with a complete set and can start a fresh session on any phase.

## What to do

1. Read **`docs/project-spec.md`** and find the phase index. If there's no phase
   index, tell the user to run `/spec-phases` first.
2. Determine the set of phases to generate:
   - If `$ARGUMENTS` names a specific phase, generate only that one (use this to
     (re)generate a single phase).
   - Otherwise, generate **all phases** listed in the index. Skip any phase whose plan
     file already exists unless its content is just a stub, so re-running is safe and
     won't clobber work in progress.
3. For **each** phase in the set, create its plan file at the path named in the index
   (e.g. `docs/plans/phase-1-foundation.md`). Open every file with this header:

   ```markdown
   # Phase 1 — Foundation

   | Field | Value |
   |-------|-------|
   | **Scope** | Project scaffold, data ingestion |
   | **Detail level** | High-level |
   | **Status** | Planned |
   ```

   Valid statuses: `Planned` → `In Progress` → `Complete`. Detail level starts
   **High-level** here and is promoted to **Detailed** in `/spec-implement`.
4. Fill in each plan at a **high level** — enough structure to understand scope and
   sequence, not full implementation detail. For each stack area a phase touches, pull
   the relevant `vibe-spec` reference file (e.g. `05-prisma.md` for schema work,
   `07-auth.md` for auth) and capture the documented approach and key conventions so
   each phase doc doubles as an architecture reference. When a phase establishes a
   documented invariant worth governing, note it should be anchored as a Surface hub
   claim during implementation (`20-surface.md`).

Keep every plan high-level — full detail comes when you implement. When done, list the
plan files you created and tell the user they can now start a fresh session and run
`/spec-implement` on the first phase.
