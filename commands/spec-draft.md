---
description: Step 1 of the Vibe-Spec workflow. Interview the user about their product and write a rough V0 spec — what it does and how users interact with it, no tooling decisions yet.
argument-hint: [idea]
---

You are running **Step 1 of the Vibe-Spec spec-driven workflow**: writing a **V0
spec**. Consult the `vibe-spec` skill
(`${CLAUDE_PLUGIN_ROOT}/skills/vibe-spec/reference/00-workflow.md`) for the full
methodology.

The goal of V0 is a rough first draft. It is intentionally **tool-agnostic** — do not
choose frameworks, databases, or libraries yet. Capture *what the product does* and
*how users interact with it*.

## What to do

1. If `$ARGUMENTS` (the idea) is empty, ask the user for a one-line description of
   what they want to build.
2. Interview the user to fill in the essentials. Ask about, at minimum:
   - The core problem the product solves and who it's for
   - The exact **user workflows** — e.g. "user logs in with OTP, sees a dashboard;
     pages differ by role; the app ingests data from an external API on a schedule"
   - Distinct user types / roles, if any
   - External systems it talks to (webhooks in/out, third-party APIs, scheduled jobs)
   - What "done" looks like for a first version
   Ask in small batches; don't overwhelm. Accept that the user won't know everything
   yet — that's fine for V0.
3. Write the result to **`docs/project-spec.md`** with a clear heading marking it as
   **V0**. Structure it as: product summary, user types, user workflows (the bulk),
   external integrations, and open questions you couldn't resolve.

Keep it high-level and readable. **Do not** map features to tools — that's
`/spec-refine` (Step 2). End by telling the user to run `/spec-refine` next.
