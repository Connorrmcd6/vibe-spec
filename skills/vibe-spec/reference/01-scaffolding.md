# Project Scaffolding

> **Skip this if:** you’re not building a web app (this is Next.js-specific)
> **You need this if:** you’re building any web application — this is the foundation

### Purpose

Next.js 16 App Router with TypeScript strict mode, pnpm package management, Tailwind CSS v4, and ESLint flat config. This is the base layer everything else builds on.

**Important:** Always generate boilerplate code with official CLI/init commands wherever possible. Use `pnpm create next-app`, `pnpm prisma init`, and `pnpm dlx shadcn@latest init` rather than hand-writing config files. The CLI output will match the current version’s expectations and avoid subtle misconfigurations.

### Key Files

| File                  | Purpose                             |
| --------------------- | ----------------------------------- |
| `package.json`        | Dependencies, scripts, build config |
| `tsconfig.json`       | TypeScript compiler options         |
| `postcss.config.mjs`  | Tailwind v4 PostCSS plugin          |
| `eslint.config.mjs`   | ESLint flat config                  |
| `pnpm-workspace.yaml` | pnpm build optimizations            |

### Configuration

**package.json** — Core dependencies and scripts:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "prisma generate && prisma migrate deploy && next build",
    "start": "next start",
    "lint": "eslint",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "docs:check": "surf check",
    "docs:verify": "surf verify",
    "prepare": "git config core.hooksPath .githooks"
  },
  "dependencies": {
    "next": "16.2.1",
    "react": "19.2.3",
    "react-dom": "19.2.3",
    "typescript": "^5",
    "tailwindcss": "^4",
    "zod": "^4.3.6"
  },
  "devDependencies": {
    "@tailwindcss/postcss": "^4",
    "eslint": "^9",
    "eslint-config-next": "16.2.1",
    "vitest": "^4.1.0",
    "tsx": "^4.21.0",
    "vite-tsconfig-paths": "^6.1.1",
    "@gradient-tools/surface": "^0.6.2"
  }
}
```

> **Note:** The `build` script includes `prisma generate && prisma migrate deploy` before `next build`. Remove these if you don’t use Prisma. The `prepare` script sets up git hooks — see [Section 16](15-pre-commit.md).
The `docs:check` / `docs:verify` scripts drive the Surface doc-drift gate — see
[`20-surface`](20-surface.md); drop them (and the `@gradient-tools/surface` devDependency) if
the project doesn’t govern docs.

**tsconfig.json** — Strict TypeScript with path aliases:

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "strict": true,
    "noEmit": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    ".next/dev/types/**/*.ts",
    "**/*.mts"
  ],
  "exclude": ["node_modules"]
}
```

**postcss.config.mjs** — Tailwind v4 (no `tailwind.config.js` needed):

```javascript
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
```

**eslint.config.mjs** — Modern flat config (ESLint 9+):

```javascript
import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  globalIgnores([
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    "src/generated/**",
  ]),
]);

export default eslintConfig;
```

**pnpm-workspace.yaml** — Build optimizations:

```yaml
packages:
  - "."
ignoredBuiltDependencies:
  - sharp
  - unrs-resolver
onlyBuiltDependencies:
  - "@prisma/engines"
  - esbuild
  - prisma
```

### Gotchas & Conventions

- **pnpm, not npm.** The lockfile is `pnpm-lock.yaml`. Run `pnpm install`, `pnpm dev`, `pnpm test`, etc.
- **Tailwind v4** uses `@tailwindcss/postcss` — there is no `tailwind.config.js` file. CSS variables and theme config live directly in `globals.css` using `@theme inline`.
- **Path aliases** use `@/*` mapping to `./src/*`. Always import as `@/lib/...`, `@/components/...`, never relative paths across directories.
- **`src/generated/**`** is in both `.gitignore` and ESLint ignores — this is where Prisma generates its client. If you don’t use Prisma, remove this ignore.
- **`tsx`** is used for running TypeScript scripts directly (e.g., `tsx scripts/seed.ts`). Useful for any CLI tooling you need.
