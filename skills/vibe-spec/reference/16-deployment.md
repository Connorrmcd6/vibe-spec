# Deployment

> **Skip this if:** you’re only running locally
> **You need this if:** you’re deploying to production

### Purpose

Vercel deployment with Prisma client generation and migration in the build step. Neon Postgres for the production database. Security headers configured in `next.config.ts`.

### Key Files

| File                          | Purpose                                                  |
| ----------------------------- | -------------------------------------------------------- |
| `package.json` `build` script | `prisma generate && prisma migrate deploy && next build` |
| `next.config.ts`              | Security headers (CSP, HSTS, X-Frame-Options)            |
| `.env.example`                | Complete env var reference                               |

### Build Script

```json
{
  "build": "prisma generate && prisma migrate deploy && next build"
}
```

- `prisma generate` — generates TypeScript types from the schema
- `prisma migrate deploy` — applies any pending migrations (safe for production — only applies, never creates)
- `next build` — builds the Next.js app

### Security Headers

**next.config.ts:**

```typescript
import type { NextConfig } from "next";

const isDev = process.env.NODE_ENV === "development";

const cspDirectives = [
  "default-src 'self'",
  `script-src 'self' 'unsafe-inline'${isDev ? " 'unsafe-eval'" : ""}`,
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data: blob:",
  "connect-src 'self'",
  "worker-src 'self'",
  "frame-ancestors 'none'",
  "form-action 'self'",
  "base-uri 'self'",
];

const securityHeaders = [
  { key: "Content-Security-Policy", value: cspDirectives.join("; ") },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "X-Frame-Options", value: "DENY" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  {
    key: "Strict-Transport-Security",
    value: "max-age=31536000; includeSubDomains; preload",
  },
  {
    key: "Permissions-Policy",
    value: "camera=(), microphone=(), geolocation=()",
  },
];

const nextConfig: NextConfig = {
  devIndicators: false,
  async headers() {
    return [{ source: "/(.*)", headers: securityHeaders }];
  },
};

export default nextConfig;
```

> **Note:** Add external domains to CSP directives as needed — S3 buckets in `img-src` and `connect-src`, push notification services in `connect-src`, OAuth providers, etc. Missing a domain causes silent failures.

### Environment Variable Checklist

```env
# Database
DATABASE_URL="postgresql://user:pass@host:5432/dbname?schema=public"

# Auth (choose one approach)
# OAuth:
AUTH_SECRET=
AUTH_GOOGLE_ID=
AUTH_GOOGLE_SECRET=
AUTH_URL=https://your-domain.com
# OTP:
SESSION_SECRET=
OTP_EXPIRY_MINUTES=10
EMAIL_PROVIDER=console

# App
NEXT_PUBLIC_APP_NAME="YourApp"

# Pipeline (API key for GitHub Actions, if applicable)
PIPELINE_API_KEY=    # generate with: openssl rand -hex 32

# Web Push (if applicable)
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
VAPID_SUBJECT=mailto:you@example.com
NEXT_PUBLIC_VAPID_PUBLIC_KEY=

# S3 (if applicable)
S3_BUCKET_NAME=
S3_REGION=eu-west-2
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
```

### Gotchas & Conventions

- **CSP must include all external domains** your app talks to — S3 buckets, push notification services, OAuth providers, etc. Missing a domain = silent failures.
- **`'unsafe-eval'` in dev only** — needed for Next.js hot reload. Never in production.
- **`devIndicators: false`** suppresses the Next.js dev mode badge.
- **Neon Postgres** is the production database (serverless Postgres). The Prisma client uses `@prisma/adapter-pg` for connection.
- **Decoupled NestJS backend** (see [Section 3](02-nestjs.md)) does **not** deploy to Vercel — it’s a long-running server that belongs on a container host (Railway / Fly.io / Render / AWS ECS). When you split the backend out, the frontend still deploys to Vercel, and the two origins need CORS configuration plus a shared auth secret.
