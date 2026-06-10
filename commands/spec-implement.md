---
name: spec-implement
description: Step 5 of the Vibe-Spec workflow. Promote a phase plan to detailed, implement it following the vibe-spec references, then update the docs so the spec reflects reality.
args:
  - name: phase
    description: The phase number or name to implement (optional — defaults to the next phase that isn't Complete)
    required: false
---

You are running **Step 5 of the Vibe-Spec spec-driven workflow**: detailing and
implementing one phase. This step is **iterative** — run it once per phase, ideally in
a fresh session. See the `vibe-spec` skill (`reference/00-workflow.md`).

## What to do

1. **Load context.** Read `docs/project-spec.md` (the V2 spec) and the target phase's
   plan file under `docs/plans/`. Pick the phase from `$ARGUMENTS`, or default to the
   next phase whose status isn't `Complete`. Also read the *previous* phase's plan so
   decisions carry forward.
2. **Promote to detailed.** Expand the phase plan from High-level to **Detailed**:
   concrete files, schema, endpoints, and steps. Update the header's **Detail level**
   to `Detailed` and **Status** to `In Progress`. For each stack area, consult the
   matching `vibe-spec` reference file and follow its conventions and gotchas exactly
   (e.g. `01-scaffolding.md` for project setup, `05-prisma.md` for schema, `07-auth.md`
   for auth, `08-rbac.md` for roles, `10-testing.md` for tests).
3. **Implement** the detailed plan. Use official CLI/init commands for boilerplate
   wherever possible (`pnpm create next-app`, `pnpm prisma init`, `shadcn init`).
4. **Update the docs — this is not optional.** If anything drifted during
   implementation (design changes, bottlenecks, skipped or added features), update the
   phase doc so it reflects reality, and update dependent phase docs and the V2 spec
   where needed. Capture *decisions made*, not just TODOs. **A stale spec is worse
   than no spec — it actively misleads future sessions.** Set the phase **Status** to
   `Complete` when done.

End by summarizing what changed and telling the user to start a fresh session and run
`/spec-implement` for the next phase. If new phases became necessary, add them with
`/spec-phases` conventions and continue.
