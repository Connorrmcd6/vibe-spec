# Documentation Governance (Surface)

> **Skip this if:** the project is a tiny, slow-moving static site where two well-kept markdown files beat any apparatus
> **You need this if:** agents and humans read your docs and the code moves fast enough to drift — i.e. almost every project built with this workflow

### Purpose

Surface governs documentation **like code**. You anchor a sentence ("claim") to the
symbol it describes; when that symbol's *logic* changes, `surf check` fails until a human
re-reads the prose and re-seals it. It runs like a test — deterministic, no model, no
network, no API key.

This is the enforcement layer for the workflow's core rule: `/spec-implement` already
insists you "update the docs so the spec reflects reality — a stale spec is worse than no
spec," but that's a discipline with no gate. Surface *is* the gate. It catches the exact
failure mode where someone refactors a function, the tests stay green, the PR merges — and
the `AGENTS.md` / hub prose that every agent reads on every run silently goes false.
Nothing else in the stack catches that: tests assert behavior matches code; Surface asserts
prose still matches the code it describes.

> **What Surface does NOT do.** A green gate means "nothing anchored drifted since the last
> sign-off," **not** "the docs are true." It only watches spans you anchored, and it's not a
> retrieval system. It governs *trust* in the docs you already keep — it doesn't write them.

### Key Files

| File                            | Purpose                                                  |
| ------------------------------- | -------------------------------------------------------- |
| `surf.toml`                     | Config — the `hubs` glob (default `hubs/*.md`)           |
| `hubs/*.md`                     | The hubs — frontmatter claims + prose agents read        |
| `@gradient-tools/surface`       | The `surf` binary, a pnpm devDependency                  |
| `.githooks/pre-commit`          | Runs `surf check` as the gate (see [`15-pre-commit`](15-pre-commit.md)) |

### Install

A pnpm devDependency — no system prerequisite, no separate binary install. The shim pulls
the prebuilt binary for your platform via `optionalDependencies` (no postinstall download):

```sh
pnpm add -D @gradient-tools/surface
```

Prebuilt for **macOS (Apple Silicon)** and **Linux (x86_64)**; other Unix arches build from
source. **Windows is unsupported** (anchor paths are forward-slash only) — use WSL.

### The hub: anatomy and the verify loop

A hub is a markdown file whose frontmatter anchors claims to code:

```yaml
---
summary: How auth refresh rotation works.
anchors:
  - claim: refresh rotation is single-use; reuse triggers global logout
    at: src/auth/refresh.ts > rotateRefreshToken
    hash: 9b1c33ade8f1        # written by `surf verify`, never by hand
---

# Auth

Prose a human (or agent) reads to understand this domain.
```

- **`claim`** — one sentence stating an *invariant* (what must stay true), not a restatement
  of the implementation. A claim that mirrors the code rots as fast as a comment.
- **`at`** — the anchor. A file path then a `>`-separated symbol path:
  `src/service.ts > TokenService > rotate`. Use `>` for methods, **not** a dot. Disambiguate
  genuine name collisions with `@N` (1-based). Non-callables (exported consts, type aliases)
  anchor too.
- **`hash`** — the seal. Absent until you `surf verify`; the gate treats a hashless claim as
  *unverified*.

The loop:

```sh
pnpm exec surf init                 # writes surf.toml + creates hubs/
pnpm exec surf new auth             # scaffolds hubs/auth.md
pnpm exec surf suggest "src/**/*.ts" # lists undocumented public symbols as a starter hub
pnpm exec surf lint                 # does every anchor resolve to exactly one symbol?
pnpm exec surf check                # the gate — a new claim is "unverified" until sealed
pnpm exec surf verify               # YOU read the prose, confirmed it, and seal the hash
```

Change the *logic* of an anchored symbol and `surf check` reports `DIVERGED` and exits
non-zero. If the prose still holds, `surf verify` re-seals it; if it's now false, fix the
prose first. Reformatting, comments, and consistent renames do **not** fire — only logic does.

### AGENTS.md integration

Keep hubs and `AGENTS.md` **separate** (the recommended default). Don't copy hub prose into
`AGENTS.md`; give it a pointer block so agents read only the hub they need:

```markdown
<!-- surf:hubs -->
Context lives in [`hubs/`](./hubs/) — read only the hub(s) you need.
<!-- /surf:hubs -->
```

`surf lint` then verifies that block links the configured hubs directory and that it exists.
This dovetails with the `00-workflow` AGENTS.md hierarchy: declarative domain briefings live
in `hubs/`, imperative agent instructions stay in `AGENTS.md`.

### Gotchas & Conventions

- **Anchor the smallest symbol the sentence is actually about.** Under-anchoring lets real
  drift slip through; over-anchoring re-triggers verification on every incidental edit and
  trains people to rubber-stamp `verify` without reading — which defeats the tool. `surf lint`
  emits advisory nudges (near-whole-file span, too many anchors, uncovered public function).
- **`verify` is the human escape hatch, not an autopilot.** Verifying without reading the
  prose is the one failure mode the whole tool exists to prevent.
- **Copy-heavy span?** Set `ignore_literals: true` on the claim so string-literal *content*
  is excluded from the hash (logic edits still fire). Prefer a narrower anchor first.
- **Don't anchor `README.md`.** Pitch prose is too coarse and on GitHub the frontmatter
  renders as a table above your README. Anchor the code; let the README link to the docs.
- **Optional CI gate.** Beyond the pre-commit gate, you *can* add the GitHub Action
  (`Connorrmcd6/surface@v0.6.2` on `pull_request`). If you do, use a **plain
  `actions/checkout@v4` — do NOT set `fetch-depth: 0`** (the verdict hashes the working tree,
  not history).
