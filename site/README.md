# Vibe-Spec site

The **Vibe-Spec landing page** — a static [Astro](https://astro.build) site,
styled à la [impeccable.style](https://impeccable.style). It explains what
Vibe-Spec is, shows the one-line install, the 5-step workflow, the 18 stack
references, and links out. The site is purely marketing: install happens through
the Claude Code plugin marketplace, so nothing depends on it existing.

## Stack & conventions

Reuses the Vibe-Spec static-site references (`01-scaffolding`, `11-ui`,
`15-pre-commit`), adapted for Astro:

- **pnpm** — package manager (`pnpm-lock.yaml`, `pnpm-workspace.yaml`).
- **Tailwind v4** via `@tailwindcss/vite`. Theme tokens are semantic CSS
  variables in `src/styles/global.css` (`@theme inline`) — never hardcode
  colours; use `bg-card`, `text-muted-foreground`, `border-border`, etc.
- **Path alias** `@/*` → `src/*`.
- **Pre-commit hook** (`../.githooks/pre-commit`) runs `astro check` when staged
  files touch `site/`. Configured by the `prepare` script on `pnpm install`.
- **Vercel** static output via `@astrojs/vercel`.

## Develop

```bash
cd site
pnpm install        # also wires up the git pre-commit hook
pnpm dev            # http://localhost:4321
pnpm check          # astro type check
pnpm build          # static build → dist/
pnpm preview        # preview the production build
```

## Structure

```
src/
  layouts/Base.astro        # html shell, meta/OG tags, global.css
  pages/index.astro         # composes the sections
  components/               # Hero, InstallBlock, Workflow, References, Projects, Footer
  styles/global.css         # Tailwind import + theme tokens
public/favicon.svg
```

## Deploy

Static output to Vercel (git integration auto-deploys). Once a real domain is
live, update `site` in `astro.config.mjs` and the `homepage` fields in
`../.claude-plugin/plugin.json` and `../.claude-plugin/marketplace.json`.
