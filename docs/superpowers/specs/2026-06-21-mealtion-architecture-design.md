# Mealtion — Architecture Design Document

Date: 2026-06-21
Status: Draft — updated for Supabase-only architecture
MVP Spec: `Mealtion Document.md`

---

## 1. Project Structure

```
mealtion/
├── app/                      # Flutter app (only code)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── supabase/     # Supabase client, providers
│   │   │   ├── router/       # GoRouter
│   │   │   └── theme/        # App theme
│   │   └── features/
│   │       ├── auth/
│   │       │   ├── screens/
│   │       │   ├── providers/
│   │       │   ├── models/
│   │       │   └── widgets/
│   │       ├── home/
│   │       ├── add_meal/
│   │       ├── friends/
│   │       ├── feed/
│   │       ├── gallery/
│   │       ├── bookmarks/
│   │       ├── profile/
│   │       ├── notifications/
│   │       └── settings/
│   ├── pubspec.yaml
│   └── test/
│
├── supabase/                 # Supabase config
│   ├── migrations/           # SQL migrations (schema)
│   └── seed.sql              # Seed data
│
├── docker-compose.yml        # Supabase local dev
├── docs/superpowers/specs/
└── README.md
```

---

## 2. Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Mobile Framework | Flutter | Cross-platform iOS + Android |
| State Management | Riverpod | Compile-safe, testable, `AsyncValue` handles all states per spec §31 |
| Navigation | GoRouter | Deep linking, auth redirect guards |
| Local Storage | Isar | Offline drafts and cache |
| Backend | **Supabase** (PostgreSQL + Auth + Storage + Realtime) | All-in-one BaaS — no custom server |
| Database | PostgreSQL (managed by Supabase) | Relational, RLS for access control |
| Photo Storage | Supabase Storage (S3-compatible) | CDN, image resizing, RLS-protected |
| Auth | Supabase Auth (email/password) | Built-in, handles JWTs, refresh, email verification |
| Push | Supabase Realtime + FCM | Real-time notifications |
| Hosting | Supabase (backend) + Flutter (mobile) | Deploy independently |

---

## 3. Flutter State Management — Riverpod

Same as before — each feature owns focused providers. No change from the original design.

Data flow: Widget → Provider → Supabase SDK → Supabase cloud

No custom REST API. All reads/writes go through:
- `supabase.from('meals').select(...)` for queries
- `supabase.auth.signUp(...)` / `supabase.auth.signIn(...)` for auth
- `supabase.storage.from('photos').upload(...)` for photos
- Row Level Security enforces access rules server-side

---

## 4. Supabase Database Schema (PostgreSQL)

Same domain models from the original design, but managed via Supabase migrations.

**Tables:** users (managed by Supabase Auth), meals, meal_foods, meal_photos, meal_tags, restaurants, branches, friends, likes, comments, bookmark_collections, bookmark_items, notifications

Auth users table is Supabase's built-in `auth.users`. Our profile data in a public `profiles` table.

---

## 5. Row Level Security (Access Control)

RLS replaces the Go backend's middleware/service layer:

| Table | Policy | Logic |
|---|---|---|
| `profiles` | Read own profile + friends | `auth.uid() = id OR id IN (friend_ids)` |
| `meals` | Read own + friend non-private | `auth.uid() = user_id OR (is_private = false AND user_id IN (accepted_friend_ids))` |
| `meals` | Insert/Update/Delete | Only `auth.uid() = user_id` |
| `meal_photos` | Same as meals | Cascade from meal |
| `friends` | Only involved users | `auth.uid() = user_id OR auth.uid() = friend_user_id` |
| `likes` | Read if meal accessible | Check meal access |
| `comments` | Delete own or own meal | `auth.uid() = user_id OR meal owner` |
| `bookmarks` | Own collections + items | `auth.uid() = user_id` |
| `notifications` | Own notifications | `auth.uid() = user_id` |
| Storage `photos` | Upload own meals, read accessible | Match meal ownership + access |

---

## 6. Auth Flow (Supabase Auth)

Supabase Auth replaces the custom Go auth:

- **Sign up:** `supabase.auth.signUp(email, password)` — sends confirmation email automatically
- **Verify email:** User clicks link → Supabase marks email verified
- **Login:** `supabase.auth.signIn(email, password)` — returns session with tokens
- **Token refresh:** Automatic via `supabase.auth.onAuthStateChange`
- **Forgot password:** `supabase.auth.resetPasswordForEmail(email)`
- **Delete account:** Admin API via Supabase dashboard, or custom edge function
- **Session persistence:** Supabase stores tokens automatically

Flutter `AuthNotifier` listens to `supabase.auth.onAuthStateChange` to react to login/logout.

---

## 7. Photo Handling (Supabase Storage)

- Upload: `supabase.storage.from('meal-photos').upload(path, file)`
- Path: `{user_id}/{meal_id}/{sort_order}.{ext}`
- Serve: `supabase.storage.from('meal-photos').getPublicUrl(path)` — or signed URLs for private photos
- RLS on storage bucket: only meal owner can upload, friends can read

---

## 8. Offline & Drafts (same logic, different implementation)

- Drafts stored in Isar locally, never sent to Supabase until publish
- On publish failure → auto-save as draft, show offline toast
- On edit failure → keep edit screen open, show error, no auto-draft

---

## 9. Notifications (Supabase Realtime + Edge Functions)

- Supabase Edge Function triggers on INSERT to `notifications` table
- Sends push via FCM
- Flutter listens via `supabase.channel('notifications')` for real-time badge updates

---

## 10. Error & Loading States

Unchanged from original design — `AsyncValue.when()` on all Riverpod providers.

---

## 11. Currency & Price

Business logic (price level calculation, threshold checking) moves to the Flutter client side or a Supabase Edge Function if logic is complex.

---

## 12. Privacy & Access Rules

All enforced via RLS — no custom backend code needed. The `meals` table RLS ensures:
- Own meals always visible to owner
- Friend meals visible only if not private + friendship active
- Deleted/privatized meals auto-hidden
