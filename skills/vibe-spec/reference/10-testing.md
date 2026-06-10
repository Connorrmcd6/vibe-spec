# Testing (Vitest)

> **Skip this if:** never (testing is not optional)
> **You need this if:** always

### Purpose

Vitest with mocked dependencies — no real database or network calls needed. Tests run fast, in isolation, and in CI.

### Key Files

| File                        | Purpose                               |
| --------------------------- | ------------------------------------- |
| `vitest.config.ts`          | Test runner config                    |
| `src/tests/setup.ts`        | Global mocks (Prisma, next/cache)     |
| `src/tests/fixtures/*.json` | Real API response fixtures            |
| `docs/testing.md`           | Full testing conventions and patterns |

### Configuration

**vitest.config.ts:**

```typescript
import { defineConfig } from "vitest/config";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    environment: "node",
    globals: false,
    setupFiles: ["./src/tests/setup.ts"],
    coverage: {
      provider: "v8",
      include: ["src/lib/**/*.ts"],
      exclude: ["src/lib/db/client.ts"],
    },
  },
});
```

**src/tests/setup.ts** — Global mocks:

```typescript
import { vi } from "vitest";

// Mock Next.js cache functions (used in server components/actions)
vi.mock("next/cache", () => ({
  unstable_cache: <T extends (...args: unknown[]) => unknown>(fn: T) => fn,
  revalidateTag: vi.fn(),
  revalidatePath: vi.fn(),
}));

// Mock Prisma with all model methods
const mockPrismaModel = () => ({
  create: vi.fn(),
  createMany: vi.fn(),
  update: vi.fn(),
  updateMany: vi.fn(),
  delete: vi.fn(),
  deleteMany: vi.fn(),
  findFirst: vi.fn(),
  findMany: vi.fn(),
  findUnique: vi.fn(),
  upsert: vi.fn(),
  count: vi.fn(),
});

// Add a mock for each of your Prisma models
vi.mock("@/lib/db/client", () => {
  return {
    prisma: {
      user: mockPrismaModel(),
      // ... add your models here
      $disconnect: vi.fn(),
      $transaction: vi.fn((fn: (tx: unknown) => unknown) =>
        fn({
          user: mockPrismaModel(),
          // ... mirror the models above
        }),
      ),
    },
  };
});
```

### Mock Patterns

| What to Mock      | How                                                                |
| ----------------- | ------------------------------------------------------------------ |
| **Prisma**        | Global setup file (above) — provides all model methods             |
| **HTTP calls**    | Mock `global.fetch` directly in the test file                      |
| **pg Pool**       | `vi.mock("@/lib/db/raw")` with `rawPool: { query: vi.fn() }`       |
| **S3 client**     | `vi.mock("@/lib/s3/client")` with individual function mocks        |
| **Auth**          | `vi.mock("@/auth")` with `auth: vi.fn()` returning session or null |
| **Next.js cache** | Handled in global setup (passthrough for `unstable_cache`)         |

### Gotchas & Conventions

- **`vite-tsconfig-paths` is required** for `@/*` path aliases to work in Vitest.
- **`globals: false`** — always `import { describe, it, expect, vi } from "vitest"` explicitly.
- **`vi.clearAllMocks()` in `beforeEach` wipes mock return values** set in `vi.mock()` factories. If you use `clearAllMocks`, you must re-set auth mocks in each `beforeEach`.
- **Use `as never`** (not `as any`) for mock return values that don’t match full Prisma types.
- **Fixture files** (`src/tests/fixtures/*.json`) contain real API responses. Use them in schema validation tests to catch regressions when APIs change.
- **Coverage excludes** files that are hard to test in isolation (DB client singletons). Set realistic thresholds — 100% is not the goal.
- **Colocate tests** — `otp.test.ts` lives next to `otp.ts`, not in a separate `__tests__` directory.
