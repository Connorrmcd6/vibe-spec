# Role-Based Access Control (RBAC)

> **Skip this if:** your app has no concept of user roles or permissions (all users see the same thing)
> **You need this if:** different users should see different pages, perform different actions, or access different API endpoints based on their role

### Purpose

RBAC controls what authenticated users can do. It works as a layer on top of authentication — auth determines _who_ you are, RBAC determines _what you can do_. This section covers the data model, server-side enforcement, client-side checks, and checklists for adding new roles and permissions.

### Key Files

| File                               | Purpose                             |
| ---------------------------------- | ----------------------------------- |
| `src/lib/rbac/roles.ts`            | Role and permission definitions     |
| `src/lib/rbac/permissions.ts`      | Permission checking functions       |
| `src/proxy.ts`                     | Route-level RBAC enforcement        |
| `src/hooks/useRbac.ts`             | Client-side permission checks       |
| `src/contexts/AuthContext.tsx`     | Auth + role state provider          |
| `src/lib/references/rbac-guide.md` | Deep-dive reference with checklists |

### Data Model

Roles are stored on the User model (or a junction table for multi-role systems):

```prisma
enum Role {
  ADMIN
  MANAGER
  USER
}

model User {
  id        String   @id @default(uuid()) @db.Uuid
  email     String   @unique
  role      Role     @default(USER)
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}
```

### Permission Definitions

Define permissions as a map from roles to allowed actions:

```typescript
// src/lib/rbac/roles.ts
export const ROLE_PERMISSIONS: Record<Role, string[]> = {
  ADMIN: [
    "users:read",
    "users:write",
    "users:delete",
    "settings:read",
    "settings:write",
    "reports:read",
  ],
  MANAGER: ["users:read", "users:write", "settings:read", "reports:read"],
  USER: ["settings:read"],
};

export function hasPermission(role: Role, permission: string): boolean {
  return ROLE_PERMISSIONS[role]?.includes(permission) ?? false;
}
```

### Server-Side Enforcement

**In `proxy.ts`** — route-level protection:

```typescript
// Define which routes require which roles
const routeRoleMap: Record<string, Role[]> = {
  "/admin": ["ADMIN"],
  "/management": ["ADMIN", "MANAGER"],
  "/dashboard": ["ADMIN", "MANAGER", "USER"],
};
```

The proxy checks the JWT payload’s `role` field against the route’s required roles. If the user’s role isn’t in the list, redirect to an unauthorized page.

**In API routes** — endpoint-level protection:

```typescript
// In any API route handler
const session = await getSessionFromRequest(request);
if (!session || !hasPermission(session.role, "users:write")) {
  return NextResponse.json({ error: "Forbidden" }, { status: 403 });
}
```

### Client-Side Checks

**`useRbac()` hook** for conditional UI rendering:

```typescript
// src/hooks/useRbac.ts
export function useRbac() {
  const { user } = useAuth();

  return {
    can: (permission: string) => hasPermission(user.role, permission),
    isRole: (role: Role) => user.role === role,
    isAdmin: user.role === "ADMIN",
  };
}

// Usage in components
const { can, isAdmin } = useRbac();

{can("users:write") && <EditUserButton />}
{isAdmin && <AdminPanel />}
```

### Checklists

**How to add a new role:**

1. Add the role to the `Role` enum in `prisma/schema.prisma`
2. Run `pnpm prisma migrate dev --name add_role_<name>`
3. Add permission mappings in `src/lib/rbac/roles.ts`
4. Add route access entries in `src/proxy.ts`
5. Update `prisma/AGENTS.md` with the new role
6. Update `src/lib/references/rbac-guide.md`

**How to add a new permission:**

1. Add the permission string to the relevant roles in `src/lib/rbac/roles.ts`
2. Add server-side checks where the permission is enforced
3. Add client-side `can()` checks for UI elements
4. Update `src/lib/references/rbac-guide.md`

**How to add a new protected page:**

1. Create the page component in `src/app/(dashboard)/`
2. Add the route pattern to `proxy.ts` with role requirements
3. Add navigation entry (conditionally rendered based on role)
4. Update `src/components/references/adding-a-page.md`

### Gotchas & Conventions

- **RBAC checks are always server-side first.** Client-side `useRbac()` is for UI convenience (hiding buttons), not security. The proxy and API routes are the real enforcement layer.
- **Keep the permission model flat** — `resource:action` format (e.g., `users:write`, `reports:read`) scales well and is easy to reason about.
- **Never check roles directly in components** — use `can(permission)` instead. This decouples UI from role definitions and makes it easy to change what a role can do without updating every component.
- **Impersonation** (admin acting as another user) should be logged and auditable. Include the impersonator’s ID in the session payload if you implement this.
