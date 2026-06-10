# Push Notifications

> **Skip this if:** your app doesn’t need real-time user notifications
> **You need this if:** you need to alert users about events when they’re not actively using the app

### Purpose

Web Push API notifications with VAPID keys. The service worker handles push events only (no caching, no offline support) to keep things simple.

**Important:** Since this is a web app (not a native app), you won’t get true push notifications on all platforms. On iOS Safari, users must install the app as a PWA (add to Home Screen) before push notifications will work. On Android and desktop browsers, notifications work without PWA installation but the user still needs to grant permission.

### Key Components

| Component                      | Purpose                                            |
| ------------------------------ | -------------------------------------------------- |
| `public/sw.js`                 | Service worker (push + notificationclick handlers) |
| `web-push` npm package         | Server-side push delivery                          |
| `PushSubscription` model       | Stores browser push endpoints                      |
| `NotificationPreference` model | Per-type opt-in/out                                |
| `Notification` model           | Delivery log with idempotency                      |

### Key Patterns

**Idempotency keys** prevent duplicate notifications. The `Notification` model has a `@@unique([userId, idempotencyKey])` constraint. Before sending, check if a notification with that key already exists.

**Preferences default to enabled** — users opt out, not in. The `NotificationPreference` model stores `pushEnabled: Boolean @default(true)` per notification type.

**Service worker** handles only push events — no caching, no fetch interception, no offline mode. This is intentional: a push-only service worker is trivial to debug and doesn’t interfere with Next.js’s own caching.

### Environment Variables

```env
VAPID_PUBLIC_KEY=     # Generate with: npx web-push generate-vapid-keys
VAPID_PRIVATE_KEY=
VAPID_SUBJECT=mailto:you@example.com
NEXT_PUBLIC_VAPID_PUBLIC_KEY=   # Same as VAPID_PUBLIC_KEY (exposed to client)
```

### Gotchas & Conventions

- **Generate VAPID keys once** with `npx web-push generate-vapid-keys` and store them permanently. Changing keys invalidates all existing subscriptions.
- **The `NEXT_PUBLIC_` prefix** exposes the public key to the client (needed for subscription). The private key stays server-only.
- **iOS Safari** supports Web Push but has quirks — the app must be installed as a PWA first.
- **Keep the service worker minimal.** Adding caching or fetch interception creates hard-to-debug issues with Next.js hot reload and routing.
