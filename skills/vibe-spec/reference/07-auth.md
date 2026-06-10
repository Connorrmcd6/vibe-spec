# Authentication

> **Skip this if:** your app has no user accounts (static sites, public APIs, internal tools with network-level auth)
> **You need this if:** your app needs user sign-in, session management, or protected routes

### Purpose

This section covers two authentication approaches. Choose the one that fits your project:

1. **OAuth (Auth.js)** — Third-party sign-in (Google, GitHub, etc.) with minimal setup. No email service required.
2. **OTP + JWT (jose)** — Email-based one-time password with custom session management. Requires an email service (SES, Resend, etc.) for production, but can use console logging for local dev.

**Why two options?** OAuth is simpler to set up and doesn’t require an email service, making it ideal for MVPs and consumer apps. OTP gives you full control over the auth flow and works well for internal tools and B2B apps where you need custom role assignment at sign-up. Standard email/password auth is not covered here because it requires an email service anyway (for verification and password resets), and OTP provides a better UX with the same infrastructure.

Route protection in both cases uses Next.js 16’s `proxy.ts` pattern (not the deprecated `middleware.ts`).

### Option A: OAuth (Auth.js)

#### Key Files

| File                      | Purpose                                        |
| ------------------------- | ---------------------------------------------- |
| `src/auth.ts`             | Auth.js config (providers, adapter, callbacks) |
| `src/proxy.ts`            | Route protection (cookie check + redirect)     |
| `src/app/providers.tsx`   | SessionProvider wrapper                        |
| `src/lib/auth/session.ts` | Server-side session verification               |

#### Configuration

**src/auth.ts** — Auth.js setup:

```typescript
import NextAuth from "next-auth";
import Google from "next-auth/providers/google";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { prisma } from "@/lib/db/client";

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma as never),
  providers: [Google],
  session: { strategy: "jwt" },
  pages: { signIn: "/sign-in" },
  trustHost: true,
  callbacks: {
    jwt({ token, user }) {
      if (user?.id) {
        token.sub = user.id;
      }
      return token;
    },
    session({ session, token }) {
      if (token.sub) {
        session.user.id = token.sub;
      }
      return session;
    },
  },
});
```

**src/proxy.ts** — Route protection (Next.js 16 pattern):

```typescript
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const protectedPatterns = [
  /^\/(dashboard)(.*)/,
  /^\/account(.*)/,
  /^\/settings(.*)/,
];

export default function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isProtected = protectedPatterns.some((pattern) =>
    pattern.test(pathname),
  );

  if (!isProtected) {
    return NextResponse.next();
  }

  const sessionToken =
    request.cookies.get("authjs.session-token") ??
    request.cookies.get("__Secure-authjs.session-token");

  if (!sessionToken) {
    const signInUrl = new URL("/sign-in", request.url);
    signInUrl.searchParams.set("callbackUrl", pathname);
    return NextResponse.redirect(signInUrl);
  }

  return NextResponse.next();
}
```

#### Environment Variables (OAuth)

```env
AUTH_SECRET=        # generate with: npx auth secret
AUTH_GOOGLE_ID=
AUTH_GOOGLE_SECRET=
AUTH_URL=http://localhost:3000
```

#### OAuth Gotchas

- **JWT strategy** (not database sessions) for performance. The `jwt` callback copies `user.id` to `token.sub`, the `session` callback copies it back.
- **`PrismaAdapter(prisma as never)`** — the `as never` cast is needed due to a Prisma adapter type mismatch when using `@prisma/adapter-pg`.
- **`trustHost: true`** is required for Vercel deployment.
- **Cookie names differ** between dev and prod: `authjs.session-token` (HTTP) vs `__Secure-authjs.session-token` (HTTPS). The proxy checks both.

### Option B: OTP + JWT (jose)

This approach uses email-based one-time passwords with custom JWT sessions via the `jose` library. It gives you full control over the auth flow and integrates naturally with RBAC (see [Section 9](08-rbac.md)).

#### Key Files

| File                            | Purpose                                           |
| ------------------------------- | ------------------------------------------------- |
| `src/lib/auth/otp.ts`           | OTP generation, validation, expiry                |
| `src/lib/auth/sessions.ts`      | JWT creation/verification with jose               |
| `src/lib/auth/email.ts`         | Email provider abstraction (console/SES)          |
| `src/proxy.ts`                  | Route protection (JWT cookie check + RBAC)        |
| `src/app/(auth)/login/page.tsx` | Login page with OTP form                          |
| `src/app/api/auth/`             | Auth API routes (request-otp, verify-otp, logout) |

#### OTP Flow

```
1. User enters email on login page
2. Server generates 6-digit OTP, stores hash in DB with expiry
3. Email sent via configured provider (console in dev, SES/Resend in prod)
4. User enters OTP on verification page
5. Server validates OTP hash and expiry
6. Server creates JWT session token (signed with jose, stored as httpOnly cookie)
7. Subsequent requests validated via proxy.ts (cookie → JWT verification)
```

#### Key Patterns

**OTP generation** (`src/lib/auth/otp.ts`):

- Generate a random 6-digit code
- Store a SHA-256 hash (never the raw code) in the database with an expiry timestamp
- Validate by hashing the submitted code and comparing
- Delete the OTP record after successful verification (single use)

**JWT sessions** (`src/lib/auth/sessions.ts`):

- Use `jose` library for JWT signing and verification
- Store the JWT as an `httpOnly`, `secure`, `sameSite: lax` cookie
- Include `userId`, `email`, and `role` in the JWT payload
- Session expiry configurable via `SESSION_SECRET` env var

**Email provider abstraction** (`src/lib/auth/email.ts`):

- `console` provider logs OTP to server console (local dev — no email service needed)
- `ses` or `resend` provider sends real emails in production
- Controlled by `EMAIL_PROVIDER` env var
- Mock auth mode (`NEXT_PUBLIC_ENABLE_MOCK_AUTH=true`) bypasses OTP entirely for development

#### Environment Variables (OTP)

```env
SESSION_SECRET="generate-a-random-64-char-hex-string"
OTP_EXPIRY_MINUTES=10
EMAIL_PROVIDER=console   # console | ses | resend
NEXT_PUBLIC_ENABLE_MOCK_AUTH=true   # Skip OTP in dev
```

#### OTP Gotchas

- **Never store raw OTP codes** — always hash before storing.
- **Mock auth mode** (`NEXT_PUBLIC_ENABLE_MOCK_AUTH=true`) is essential for local development and testing. It bypasses the OTP flow entirely. Never enable in production.
- **Console email provider** logs OTP codes to the server terminal — check your `next dev` output to find the code during local development.
- **Two-layer auth:** The proxy is an optimistic first check (fast, cookie-only). Server-side `getSessionFromRequest()` is the definitive check (validates the JWT).

### Shared Gotchas (Both Options)

- **Next.js 16 uses `proxy.ts`, NOT `middleware.ts`** — the middleware convention is deprecated. This is the single biggest gotcha when starting a new Next.js 16 project.
- **Two-layer auth:** The proxy is an optimistic first check (fast, cookie-only). Server-side session verification is the definitive check (validates the token, hits the DB if needed).
