# Validation (Zod)

> **Skip this if:** your app doesn’t consume external APIs or accept complex user input
> **You need this if:** you consume external APIs, process webhooks, or need runtime type validation

### Purpose

Zod v4 validates data at runtime. Every response from an external API should be parsed through a Zod schema before your app touches it. This catches API changes, malformed data, and type mismatches before they cause bugs downstream. Zod is also used for validating user input in forms and API request bodies.

### Key Pattern

```typescript
import { z } from "zod/v4";

// Schema with coercion for string-typed numbers
const ProductSchema = z
  .object({
    id: z.number(),
    name: z.string(),
    price: z.number(),
    discount: z.coerce.number(), // Comes as "0.15" string — coerced to number
  })
  .passthrough(); // Allow unknown fields for forward compat

// Type inference
type Product = z.infer<typeof ProductSchema>;
```

### Patterns Used

| Pattern                             | When to Use                                                    |
| ----------------------------------- | -------------------------------------------------------------- |
| `z.coerce.number()`                 | API returns numbers as strings (`"3.2"` → `3.2`)               |
| `.passthrough()`                    | External APIs may add new fields — don’t break on unknown keys |
| `z.record(z.string(), z.unknown())` | Zod v4 requires two args for `z.record()`                      |
| `z.string().uuid()`                 | Validates strict RFC 4122 format                               |

### Gotchas & Conventions

- **Zod v4 breaking change:** `z.record()` needs two args. `z.record(z.unknown())` won’t compile — use `z.record(z.string(), z.unknown())`.
- **Always `.passthrough()`** on external API response objects. If the API adds a new field, your app shouldn’t crash.
- **Keep fixture files** with real API responses (`src/tests/fixtures/*.json`) — use these in schema tests to catch regressions.
- **Validate at the boundary**, not everywhere. Internal function calls between your own modules don’t need Zod validation.
