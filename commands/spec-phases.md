---
name: spec-phases
description: Step 3 of the Vibe-Spec workflow. Break the V1 spec into sequential, self-contained phases and append a phase index, producing the final V2 spec.
---

You are running **Step 3 of the Vibe-Spec spec-driven workflow**: promoting the **V1
spec → V2 spec** by breaking it into phases. See the `vibe-spec` skill
(`reference/00-workflow.md`) for the phase conventions.

## What to do

1. Read **`docs/project-spec.md`** (the V1 spec from `/spec-refine`). If it isn't a
   tool-mapped V1, tell the user to run `/spec-refine` first.
2. Break the work into **sequential, self-contained phases**. Each phase should be a
   chunk that can be planned, implemented, and verified independently, completable in
   roughly 1–3 sessions, with clear entry/exit boundaries so no context bleeds between
   phases. Early phases lay foundation (scaffold, DB, auth); later phases build
   features and polish.
3. **Outline only** at this stage — phase name, scope boundaries, and a sentence or
   two on what each covers. Do **not** fully design them yet (that's `/spec-plan`).
4. Append a **phase index** table to the end of `docs/project-spec.md` and mark the
   document **V2**. Use this shape:

   ```markdown
   ### Phase Plan

   | # | File | Scope |
   |---|------|-------|
   | 1 | `docs/plans/phase-1-foundation.md` | Project scaffold, data ingestion |
   | 2 | `docs/plans/phase-2-auth.md`       | Auth, onboarding |
   | 3 | `docs/plans/phase-3-dashboard.md`  | Transforms, core dashboard views |
   ```

The V2 spec is the final version — V0 and V1 can be discarded. End by telling the
user to run `/spec-plan` to flesh out the first phase.
