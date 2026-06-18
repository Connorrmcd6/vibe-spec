# Prerequisites & Setup

> **Skip this if:** your machine already has Git, Node, and pnpm (run `/spec-doctor` to confirm)
> **You need this if:** you're setting up a new machine, or a command fails with "command not found"

### Purpose

The single source of truth for the external tools the stack can require — what each is
for, which references depend on it, how to detect it, and how to install it per OS. The
`/spec-setup`, `/spec-doctor`, and `/spec-troubleshoot` commands all read from this file
so tool knowledge lives in one place.

**Only install what your project needs.** A static site needs just Git + Node + pnpm; a
data-heavy app adds Docker and uv. Match the tool set to the references your project
actually uses (see the "what do I need?" table in `SKILL.md`).

### Tool matrix

| Tool                 | Needed for                                               | Detect                                                   | Required?                |
| -------------------- | -------------------------------------------------------- | -------------------------------------------------------- | ------------------------ |
| **Git**              | `00-workflow`, `14-ci-cd`, `15-pre-commit`, any repo     | `git --version`                                          | Always                   |
| **Node.js** (LTS)    | `01-scaffolding` and everything downstream               | `node --version`                                         | Any web app              |
| **pnpm**             | `01-scaffolding` (pnpm, **not** npm)                     | `pnpm --version`                                         | Any web app              |
| **Docker** + compose | `03-docker` local Postgres                               | `docker --version` · `docker compose version` · daemon   | Apps with a local DB     |
| **uv** (+ Python)    | `06-dbt` transforms                                      | `uv --version`                                           | Data pipelines only      |
| **GitHub CLI** (`gh`)| `14-ci-cd` convenience (PRs, secrets)                    | `gh --version`                                           | Optional                 |

The Docker **daemon must be running**, not just the binary installed — check with
`docker info` (exit 0 = daemon up).

**Surface** (`20-surface`, the doc-drift gate) is **not** a system prerequisite — it ships
as the `@gradient-tools/surface` pnpm devDependency (prebuilt binary via
`optionalDependencies`, no postinstall download), so it lands with `pnpm install` and needs
no separate detection in `/spec-doctor` or `/spec-setup`.

### Install methods

Pick **one** per tool. Prefer user-space installers (no `sudo`) where possible.

**Git**

| OS      | Command                                                                 |
| ------- | ----------------------------------------------------------------------- |
| macOS   | `xcode-select --install` (ships Git), or `brew install git`             |
| Linux   | `sudo apt install git` (Debian/Ubuntu) · `sudo dnf install git` (Fedora)|
| Windows | `winget install Git.Git`, or download from https://git-scm.com          |

**Node.js (LTS)** — install a version manager so you can match the project's Node:

| OS          | Command                                                                                  |
| ----------- | ---------------------------------------------------------------------------------------- |
| macOS/Linux | `curl -fsSL https://fnm.vercel.app/install \| bash` then `fnm install --lts` (fnm), **or** nvm: `nvm install --lts` |
| Windows     | `winget install Schniz.fnm` then `fnm install --lts`, **or** `winget install OpenJS.NodeJS.LTS` |

Use the **LTS** line — it supports the Next.js 16 toolchain in `01-scaffolding`. After
install, `node --version` should print `v20.x` or newer.

**pnpm** — preferred path is Corepack, which ships with Node and keeps pnpm aligned with
the project's `packageManager` field:

| Method                | Command                                                            |
| --------------------- | ----------------------------------------------------------------- |
| Corepack (preferred)  | `corepack enable && corepack prepare pnpm@latest --activate`       |
| Standalone (mac/linux)| `curl -fsSL https://get.pnpm.io/install.sh \| sh -`                |
| Standalone (Windows)  | `winget install pnpm.pnpm`                                         |
| npm fallback          | `npm install -g pnpm`                                              |

**Docker** — only needed for a local Postgres (`03-docker`). The daemon must run.

| OS      | Command / app                                                                        |
| ------- | ------------------------------------------------------------------------------------ |
| macOS   | Docker Desktop (https://docker.com), **or** lightweight: `brew install colima docker docker-compose` then `colima start` |
| Linux   | `curl -fsSL https://get.docker.com \| sh` (Docker Engine + compose plugin)           |
| Windows | `winget install Docker.DockerDesktop` (requires WSL2)                                 |

**uv (+ Python)** — only for `06-dbt`. uv manages its own Python, so a separate Python
install is usually unnecessary.

| OS          | Command                                                                |
| ----------- | --------------------------------------------------------------------- |
| macOS/Linux | `curl -LsSf https://astral.sh/uv/install.sh \| sh`                    |
| Windows     | `powershell -c "irm https://astral.sh/uv/install.ps1 \| iex"`         |

**GitHub CLI (`gh`)** — optional, eases `14-ci-cd` (PRs, repo secrets).

| OS      | Command                                          |
| ------- | ------------------------------------------------ |
| macOS   | `brew install gh`                                |
| Linux   | `sudo apt install gh` · `sudo dnf install gh`    |
| Windows | `winget install GitHub.cli`                      |

### Gotchas & Conventions

- **pnpm, not npm.** The lockfile is `pnpm-lock.yaml`. Installing with npm creates a
  conflicting `package-lock.json` — see `01-scaffolding`.
- **Corepack first.** Enabling Corepack avoids a globally-pinned pnpm drifting from the
  project's expected version. A standalone or npm-global pnpm works too, just pin it.
- **Docker daemon ≠ Docker binary.** `docker --version` can succeed while `docker info`
  fails because the daemon (Docker Desktop / Colima / `dockerd`) isn't started.
- **Version managers over system Node.** A system-packaged Node is hard to upgrade per
  project; fnm/nvm let you switch versions and avoid `sudo npm -g` permission issues.
- **uv ships Python.** Don't install Python separately for dbt unless a tool demands a
  specific interpreter — `uv` pins and manages it via `uv python`.
- **No `sudo` for JS tooling.** Anything under Node/pnpm should install in user space;
  reach for `sudo` only for OS package managers (`apt`, `dnf`) and Docker Engine on Linux.
