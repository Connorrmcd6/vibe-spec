---
description: Step 2 of the Vibe-Spec workflow. Critique the V0 spec, fill gaps with clarifying questions, then promote it to a V1 spec that maps each piece of functionality to concrete stack tools using the vibe-spec references.
---

You are running **Step 2 of the Vibe-Spec spec-driven workflow**: promoting the **V0
spec → V1 spec**. The V1 spec becomes the single source of truth — it details exactly
*which tools* achieve each piece of functionality.

## What to do

1. Read the existing spec at **`docs/project-spec.md`** (the V0 draft from
   `/spec-draft`). If it doesn't exist, tell the user to run `/spec-draft` first.
2. **Critique it.** Identify gaps, ambiguities, and missing edge cases, and ask the
   user clarifying questions about them before deciding anything.
3. **Map functionality → tools** using the `vibe-spec` skill. For each capability in
   the spec, load the relevant reference file(s) (under
   `${CLAUDE_PLUGIN_ROOT}/skills/vibe-spec/`) and choose the documented approach:
   - Web app foundation → `reference/01-scaffolding.md`
   - Local DB / structured data → `reference/03-docker.md`, `04-database.md`, `05-prisma.md`
   - Auth → `reference/07-auth.md` (decide OAuth vs OTP+JWT with the user)
   - Roles / permissions → `reference/08-rbac.md`
   - External APIs / webhooks / input → `reference/09-validation.md`
   - Data pipelines / analytics → `reference/06-dbt.md`, `17-scripts.md`
   - Uploads → `reference/12-s3.md`; push / PWA → `reference/13-push-notifications.md`
   - UI → `reference/11-ui.md`; testing → `reference/10-testing.md`
   - CI/CD, hooks, deploy → `reference/14-ci-cd.md`, `15-pre-commit.md`, `16-deployment.md`
   - High-performance API → `reference/02-nestjs.md` (only if a measured need exists)

   Use the skill's quick-reference table to avoid pulling in tools the project
   doesn't need. Prefer the simplest option that satisfies the requirement.
4. Rewrite **`docs/project-spec.md`** as the **V1 spec**: the same workflows, now with
   an explicit tech-stack section and per-feature tool choices (with a one-line
   rationale each). Note anything deliberately skipped and why.

This is a good step to run in planning mode. End by telling the user to run
`/spec-phases` next.
