# Mealtion — Architecture Design Document

Date: 2026-06-21
Status: Draft
MVP Spec: `Mealtion Document.md`

---

## 1. Project Structure (Monorepo)

```
mealtion/
├── backend/                  # Go API server
│   ├── cmd/server/           # Entry point
│   ├── internal/
│   │   ├── handler/          # HTTP handlers (per feature)
│   │   ├── service/          # Business logic
│   │   ├── repository/       # DB access
│   │   ├── middleware/       # Auth, logging, CORS
│   │   ├── model/            # Domain types
│   │   └── config/           # Env config
│   ├── migrations/           # SQL migrations
│   └── go.mod
│
├── app/                      # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── api/          # HTTP client, interceptors, models
│   │   │   ├── router/       # GoRouter
│   │   │   ├── theme/        # App theme
│   │   │   └── storage/      # Local Isar DB
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
├── docs/superpowers/specs/
└── README.md
```

---

## 2. Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Mobile Framework | Flutter | Cross-platform iOS + Android |
| State Management | Riverpod | Compile-safe, testable, `AsyncValue` handles loading/error/data per spec §31 |
| Navigation | GoRouter | Deep linking, auth redirect guards |
| Local Storage | Isar | Offline drafts and cache |
| Backend | Go + Chi | Lightweight, idiomatic, fast |
| Database | PostgreSQL | Relational, mature, fits the data model |
| Photo Storage | S3-compatible (MinIO/S3/R2) | Blob storage with pre-signed URLs |
| Auth | JWT (access + refresh tokens) | Stateless, standard |
| Push | FCM | Cross-platform push notifications |

---

## 3. Flutter State Management — Riverpod

Each feature owns focused providers:

- `StateNotifierProvider` — mutable form state (add meal, edit profile)
- `FutureProvider.family` — read-only async data keyed by ID (meal detail, friend profile)
- `StreamProvider` — real-time (notifications badge count)
- `NotifierProvider` — simple mutable state (calendar filter selection)

Data flow: Widget → Provider → Repository (core/api/) → HTTP → Go Backend

Repositories return typed model objects. Auth token stored in `flutter_secure_storage`, injected via API interceptor. `AsyncValue.when()` handles loading/error/data uniformly across all screens.

---

## 4. Go Backend — Handler → Service → Repository

Chi router with middleware (JWT auth, CORS, rate limiting, request logging).

**Feature modules** (each with handler, service, and repository layers):

- `auth` — register, login, verify email, forgot/reset password, delete account
- `meal` — CRUD, draft save/publish, privacy toggle, photo management, calendar data
- `friend` — exact-username search, send/accept/cancel/unfriend
- `feed` — paginated friend meals, sorted by meal date
- `like` — toggle like per user per meal, grouped notifications
- `comment` — add (plain text), delete (owner or meal owner)
- `bookmark` — auto-generated Place & Food categories, custom collections
- `notification` — create event, list paginated, mark all read, push dispatch
- `profile` — get/update, statistics calculation (monthly, visibility-aware)
- `settings` — update currency/thresholds/notification prefs
- `search` — partial-match across food names, restaurant, branch, tags

---

## 5. Domain Models (Key Entities)

```
User: id, email, password_hash, display_name, username, bio, photo_url,
      primary_currency, price_threshold_low, price_threshold_high,
      price_display_privacy, created_at

Meal: id, user_id, date, time, source, restaurant_id, branch_id,
      is_private, is_draft, price_amount, price_currency, price_converted,
      exchange_rate, exchange_rate_date, note, created_at, updated_at

MealFood: id, meal_id, food_name, sort_order

MealPhoto: id, meal_id, storage_key, sort_order

MealTag: id, meal_id, tag_name

Restaurant: id, user_id, name

Branch: id, restaurant_id, user_id, name

Friend: id, user_id, friend_user_id, status, action_user_id, created_at

Like: id, user_id, meal_id, created_at

Comment: id, user_id, meal_id, body, created_at

BookmarkCollection: id, user_id, name, cover_type, cover_key, created_at

BookmarkItem: id, collection_id, meal_id, user_id, created_at

Notification: id, user_id, type, actor_id, meal_id, group_count,
              is_read, created_at
```

---

## 6. API Design — RESTful JSON

**Auth:**
- POST `/api/v1/auth/signup`
- POST `/api/v1/auth/verify-email`
- POST `/api/v1/auth/login` → access_token (1h) + refresh_token (30d)
- POST `/api/v1/auth/refresh`
- POST `/api/v1/auth/forgot-password`
- DELETE `/api/v1/auth/account`

**Meals:**
- GET `/api/v1/meals` — paginated with filters (month, year, search, bookmark)
- POST `/api/v1/meals` — multipart (photos + JSON fields)
- GET `/api/v1/meals/:id`
- PUT `/api/v1/meals/:id`
- DELETE `/api/v1/meals/:id`
- GET `/api/v1/meals/calendar` — dot data by month/year/filter

**Friends:**
- GET `/api/v1/friends`
- POST `/api/v1/friends/search`
- POST `/api/v1/friends/request` → send
- PUT `/api/v1/friends/request/:id/accept`
- DELETE `/api/v1/friends/request/:id` → cancel/delete

**Feed:**
- GET `/api/v1/feed?cursor=&limit=20`

**Likes:**
- POST `/api/v1/meals/:id/like` → toggle

**Comments:**
- GET `/api/v1/meals/:id/comments`
- POST `/api/v1/meals/:id/comments`
- DELETE `/api/v1/comments/:id`

**Bookmarks:**
- GET `/api/v1/bookmarks/place`
- GET `/api/v1/bookmarks/food`
- GET `/api/v1/bookmarks/collections`
- POST `/api/v1/bookmarks/collections`
- PUT `/api/v1/bookmarks/collections/:id`
- DELETE `/api/v1/bookmarks/collections/:id`
- POST `/api/v1/bookmarks/items` → save meal to collection
- DELETE `/api/v1/bookmarks/items/:id`

**Notifications:**
- GET `/api/v1/notifications?cursor=&limit=20`
- PUT `/api/v1/notifications/read-all`

**Profile:**
- GET `/api/v1/profile/:username`
- PUT `/api/v1/profile`
- GET `/api/v1/profile/statistics?month=&friend_id=`

**Settings:**
- PUT `/api/v1/settings`

Pagination: cursor-based for feed/notifications, offset-based for search/meal lists.

---

## 7. Photo Handling

- Upload as `multipart/form-data` with meal create/update
- Validation: type check, max 10MB per photo
- Storage: `users/{user_id}/meals/{meal_id}/{sort_order}.{ext}`
- Serve via pre-signed S3 URLs with 1h TTL
- Flutter caches with `cached_network_image`
- First photo by `sort_order` = cover
- Reorderable via `ReorderableListView` client-side before upload

---

## 8. Offline & Drafts

- Drafts stored locally in Isar DB, not synced to server
- On publish failure (offline) → auto-save as draft, show offline toast
- On edit failure (offline) → keep edit screen open, show error toast, no auto-draft
- No auto-publish on reconnect — user must manually publish from Drafts

---

## 9. Notifications

Types: Friend Request (received/accepted), Like (grouped per meal), Comment.

Backend inserts notification on event. Like grouping: first like creates notification, subsequent likes update `group_count`. Push via FCM (firebase-admin SDK).

In-app: cursor-paginated list, "Mark All as Read", 90-day retention. Badge counts unread only.

---

## 10. Error & Loading States

Every screen follows the pattern from spec §31:
- `AsyncValue.when(data: ..., loading: ..., error: ...)` covers all states
- Error state includes retry button → `ref.invalidate(provider)`
- Empty state returned as data with boolean flag, checked before `.when`
- Empty states are per-screen (see spec: "No friends", "No meals shared yet", etc.)

Duplicate submission prevention: button disabled on tap + state guard + optional idempotency keys for critical mutations.

---

## 11. Currency & Price (spec §24, §25, §26)

- Two user-set thresholds define Affordable/Moderate/Expensive levels
- Price level recalculated on threshold change (updates stored calculation)
- Original price + currency + exchange rate + rate date + converted amount stored per meal
- Exchange rate provider abstracted behind an interface (Frankfurter-compatible recommended)
- On primary currency change: re-convert historical meals using current rates
- Friend price display: account-level setting (Actual Price or Price Level)

---

## 12. Privacy & Access Rules (spec §30)

- Meal accessible only when: accepted friends + not private + still exists
- On access loss: hide from Feed, Friend Profile, Custom Bookmark UI
- Show "This meal is no longer available" for direct links
- Backend may retain references for potential restoration
- When access restored (re-friend + meal still shareable), previously saved bookmarks become visible again
