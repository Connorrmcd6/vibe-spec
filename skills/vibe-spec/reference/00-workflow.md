# AI-Assisted Development (Spec-Driven Workflow)

> **Skip this if:** you don’t use AI coding tools
> **You need this if:** you use Claude Code, Codex, or similar AI assistants in your workflow — or you want a structured methodology for breaking large projects into manageable phases

### Purpose

This section is placed first intentionally — it describes the methodology for using this entire guide. It covers a spec-driven development workflow, a structured system for giving AI tools the context they need (AGENTS.md hierarchy), and tool permissions for safe AI-assisted coding.

### Key Files

| File                          | Purpose                                                   |
| ----------------------------- | --------------------------------------------------------- |
| `CLAUDE.md`                   | Entry point — AI tools read this first                    |
| `AGENTS.md`                   | Root project conventions (stack, directory map, patterns) |
| `prisma/AGENTS.md`            | Prisma-specific conventions                               |
| `src/lib/AGENTS.md`           | src/lib directory structure                               |
| `src/lib/references/*.md`     | Deep-dive docs (auth-flow.md, rbac-guide.md)              |
| `.claude/settings.local.json` | Tool permissions for Claude Code                          |
| `docs/project-spec.md`        | Your product specification                                |
| `docs/plans/phase-*.md`       | Phase implementation plans                                |

### Spec-Driven Development Methodology

This is the recommended workflow for using this guide to build your own project. The core idea: write a spec before touching code, refine it with AI, break it into phases, and implement phase by phase with clean context boundaries.

#### Step 1: Write a V0 Spec

Write a rough first draft of your project spec. Accept that you won’t know everything — focus on high-level details of how you want it to work. Describe the exact user workflow, for example:

- User logs in with OTP (or OAuth), they are shown a dashboard
- Different pages are visible based on user roles
- The app exposes API endpoints that a webhook from another service can write to
- The app fetches data from an external API on a schedule

Don’t worry about tooling choices or implementation details yet — just describe what the product does and how users interact with it.

#### Step 2: Refine to V1 Spec

Use planning mode on the best model you have access to. With the `vibe-spec` skill available (or this reference in context), ask the AI to:

- Improve your V0 spec
- Ask clarifying questions about gaps
- Use this stack reference to design the V1 spec, mapping each piece of functionality to specific tools

The V1 spec should detail exactly what tools are used to achieve each piece of functionality. It becomes your single source of truth.

#### Step 3: Add Phases (V2 Spec)

Ask the AI to break the V1 spec into sequential phases — each one a self-contained chunk of work that can be planned, implemented, and verified independently. Append a phase index to the end of the V1 spec. This becomes your **V2 spec** — the final version. You can discard V0 and V1.

The phase index is a table of contents with one-line summaries. The actual detail lives in separate files inside a `docs/plans/` folder. At this stage, phases are **outlined only** — names, scope boundaries, and a sentence or two on what each covers. Don’t fully plan or design them yet.

**Example phase index** (appended to V2 spec):

```markdown
### Phase Plan

| # | File | Scope |
|---|------|-------|
| 1 | `docs/plans/phase-1-foundation.md` | Project scaffold, SDK integration, data ingestion |
| 2 | `docs/plans/phase-2-auth.md` | Auth, onboarding, seasonal leagues |
| 3 | `docs/plans/phase-3-dashboard.md` | dbt transforms, core dashboard views |
| 4 | `docs/plans/phase-4-rules.md` | Game rules, nominations, social features |
| 5 | `docs/plans/phase-5-orchestration.md` | Scheduling, PWA, push notifications |
| 6 | `docs/plans/phase-6-launch.md` | Landing page, performance, polish |
```

**Why phases work:** each doc doubles as a plan *and* an architecture reference. You can hand a single phase file to a fresh session and it has everything it needs — no context bleeding from previous work.

#### Step 4: Generate Phase Plans

Ask the AI to generate a markdown file for each phase. Keep them high-level at first — just enough structure to understand scope and sequence. Each file should open with a frontmatter-style header:

```markdown
# Phase 1 — Foundation

| Field | Value |
|-------|-------|
| **Scope** | Project scaffold, SDK integration, data ingestion |
| **Detail level** | High-level |
| **Status** | Planned |
```

Valid statuses: `Planned` → `In Progress` → `Complete`. Update the status as you work through each phase. The detail level starts as “High-level” and gets promoted to “Detailed” in Step 5 before implementation begins.

#### Step 5: Detail and Implement (Iterative)

Go through phases in order. For each phase:

1. **New session** — start fresh to avoid context bloat
2. **Add context** — attach the V2 spec and ask the AI to make the phase doc detailed
3. **Implement** — execute the detailed plan
4. **Update docs** — if anything drifted during implementation (bottlenecks, design changes, skipped features), update the phase doc so it always reflects reality. Update dependent phase docs if needed
5. **Repeat** — move to the next phase with a new session, adding the project spec and previous phase doc for context

You may find that you need to add more phases later. This is fine — proceed with the same pattern.

**Why this works:**

- Each phase is **independent enough** to be a clean conversation boundary — no context bleeding between sessions
- Phase plans capture **decisions made** during implementation, not just TODOs. Phase 4 can reference decisions from phase 2 without re-explaining them
- The spec doc is **living** — it gets updated as decisions are made, keeping it accurate as the source of truth

### The AGENTS.md Hierarchy

```
CLAUDE.md                      ← Entry point: "See @AGENTS.md for Project Conventions"
├── AGENTS.md                  ← Root: stack, directory map, key conventions
├── prisma/AGENTS.md           ← Prisma conventions (IDs, timestamps, schemas)
├── src/lib/AGENTS.md          ← src/lib directory structure
├── src/app/api/AGENTS.md      ← Route groups, auth methods
└── src/components/AGENTS.md   ← UI stack, component patterns
```

**Why this hierarchy:**

- **`CLAUDE.md`** is minimal (one line). AI tools read it first, then follow the pointer.
- **Root `AGENTS.md`** has everything that applies project-wide: stack, directory map, conventions. Keep it under 100 lines — it’s a map, not a manual.
- **Subdirectory `AGENTS.md` files** provide domain-specific context. When an AI tool is working in `src/lib/auth/`, it automatically picks up the auth conventions. This keeps the root file manageable while giving deep context where it matters.

**Root AGENTS.md must contain:**

1. One-line project description
2. Tech stack table
3. **Invariants** — non-negotiable rules (ID format, naming conventions, auth guard, import patterns)
4. Links to every sub-AGENTS.md with one-line descriptions
5. Testing section (framework, commands, setup location)

**Root AGENTS.md must NOT contain:** code examples, detailed how-tos, long prose. Those go in sub-files.

**Subdirectory AGENTS.md files should cover:**

- **Design decisions** — why this module is structured this way
- **Patterns** — the specific patterns used (e.g., namespace pattern, DI pattern, orchestrator pattern)
- **Testing notes** — how to mock this module’s dependencies
- **Gotchas** — domain-specific traps

**Reference docs** (`src/lib/references/`) are deep-dive documents with **checklists** for complex topics. Checklists make agents reliable — numbered step-by-step procedures for “How to add a new role”, “How to add a new page”, “How to create a v1 endpoint” mean agents follow them exactly instead of guessing.

**Documentation maintenance rule:** Every AGENTS.md includes a footer: _“When modifying [X], update the relevant section above.”_ — treat doc updates as part of the change, not an afterthought.

### Tool Permissions

**.claude/settings.local.json:**

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm lint)",
      "Bash(pnpm test)",
      "Bash(pnpm test:*)",
      "Bash(npx tsc --noEmit)",
      "Bash(pnpm prisma generate)",
      "Bash(npx shadcn@latest add chart --yes)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(pnpm prisma:*)",
      "Bash(npx vitest:*)",
      "Bash(gh run:*)",
      "Bash(gh pr:*)"
    ]
  }
}
```

This whitelists specific safe commands (lint, test, typecheck, prisma, git) so the AI tool can run them without prompting. Dangerous commands (rm, drop, force-push) are not listed, so the AI must ask for permission.

### Writing Effective AGENTS.md Files

The root `AGENTS.md` should cover:

- **Stack** — every major tool/library and its version
- **Directory map** — where things live and why
- **Conventions** — non-obvious patterns that the AI should follow (e.g., “never hardcode colors”, “use proxy.ts not middleware.ts”)
- **Domain-specific gotchas** — things unique to your project’s domain

### Skills (`.claude/skills/<name>/SKILL.md`)

Agent-invocable automations with YAML frontmatter:

```yaml
---
name: sync-readme
description: Ensures the readme is up to date with the repo file system
model: haiku
---
1. Check file structure defined in @README.md
2. Check actual file structure
3. Update readme to reflect the real structure
```

**Starter skills to create**: `sync-readme`, `new-endpoint`, `new-page`, `new-model`
