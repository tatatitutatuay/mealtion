# Mealtion — Architecture Design Document

Date: 2026-06-22
Status: Updated — Figma design system + screen map
MVP Spec: `Mealtion Document.md`

---

## 1. Project Structure

```
mealtion/
├── app/                          # Flutter app (only code)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── supabase/         # Supabase client provider
│   │   │   ├── router/           # GoRouter + auth guard
│   │   │   └── theme/            # App theme (Figma tokens)
│   │   └── features/
│   │       ├── auth/             # Login, signup, verify, forgot-pw
│   │       ├── home/             # Tab shell, Home screen (calendar, stats)
│   │       ├── add_meal/         # Bottom sheet form + draft system
│   │       ├── friends/          # Feed, Friends list, Connect, Search
│   │       ├── feed/             # Friends feed detail (future)
│   │       ├── gallery/          # Grid/timeline views
│   │       ├── profile/          # Owner + friend profiles
│   │       ├── bookmarks/        # Base + custom collections
│   │       ├── notifications/    # In-app notification list
│   │       └── settings/         # App settings
│   ├── pubspec.yaml
│   └── test/
├── supabase/                     # Supabase config
│   ├── migrations/
│   │   ├── 001_schema.sql        # All tables
│   │   └── 002_rls.sql           # Row Level Security
│   └── seed.sql
├── docs/
│   └── superpowers/
│       ├── specs/                # Architecture, design docs
│       └── plans/                # Phase implementation plans
├── opencode.json
└── Mealtion Document.md          # Full MVP functional spec
```

---

## 2. Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Mobile Framework | Flutter (Dart) | Cross-platform iOS + Android + Web |
| State Management | Riverpod | Compile-safe, testable, `AsyncValue` for loading/error/data |
| Navigation | GoRouter | Deep linking, auth redirect guards |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) | All-in-one BaaS |
| Database | PostgreSQL (managed by Supabase) | Relational, RLS for access control |
| Photo Storage | Supabase Storage (S3-compatible) | CDN, RLS-protected |
| Auth | Supabase Auth (email/password) | Built-in JWT, refresh, email verification |
| Push | Supabase Realtime + FCM | Future: real-time notifications |
| Local Drafts | Isar (planned) | Offline draft persistence |

---

## 3. Flutter State Management — Riverpod

Data flow: `Widget → ref.watch(provider) → Supabase SDK → Supabase cloud`

- `StateProvider` for simple state (auth state)
- `StateNotifierProvider` for complex form state (add meal)
- `Provider` for API services and singletons (supabase client)
- `FutureProvider` / `AsyncNotifierProvider` for data fetching from Supabase

No custom REST API. All reads/writes use Supabase SDK directly.

---

## 4. Figma Design System — Theme Tokens

Source: Figma page "Design System" (0:1)

### 4.1 Color Palette

| Token | Hex | Usage |
|---|---|---|
| Primary/Normal | `#F5A891` | Primary actions, selected tab, FAB |
| Primary/... | Coral scale | Pressed, disabled variants |
| Neutral/... | Greys | Backgrounds, dividers, text |
| Foundation/Grey/grey-50 | `#F8F8F8` | Screen background |
| Foundation/Grey/grey-100 | `#EAEAEA` | Divider, border |
| Foundation/Grey/grey-500 | `#BBBBBB` | Disabled text |
| Foundation/Grey/grey-900 | `#4F4F4F` | Secondary text |
| Black & White/900 | `#000000` | Primary text |
| Black & White/100 | `#FFFFFF` | Surface white |
| Success/700 | `#0EC760` | Positive/heavy indicators |
| Warning/700 | `#FFAA0F` | Warning/moderate indicators |
| Error/700 | `#FF3D00` | Error/danger indicators |

### 4.2 Typography

| Token | Family | Weight | Size | Line H | Usage |
|---|---|---|---|---|---|
| H4 | Noto Sans Thai | SemiBold 600 | 28 | 34 | Page headers |
| H5 | Noto Sans Thai | SemiBold 600 | 24 | 28 | Section titles |
| S1 | Noto Sans Thai | SemiBold 600 | 18 | 28 | Card titles |
| S2 | Noto Sans Thai | SemiBold 600 | 16 | 24 | Subsection titles |
| B1 | Noto Sans Thai | Regular 400 | 16 | 24 | Body text |
| B2 | Noto Sans Thai | Medium 500 | 16 | 24 | Body emphasis |
| B3 | Noto Sans Thai | Regular 400 | 14 | 20 | Small body |
| B4 | Noto Sans Thai | Medium 500 | 14 | 20 | Small emphasis |
| B5 | Noto Sans Thai | Regular 400 | 12 | 16 | Captions |
| B6 | Noto Sans Thai | Medium 500 | 12 | 16 | Caption emphasis |
| C1-C3 | Noto Sans Thai | Medium 500 | 10-14 | 14-20 | Chips, badges |
| Button/Giant | Inter | SemiBold 600 | 18 | 24 | Primary CTA |
| Button/Large | Inter | SemiBold 600 | 16 | 20 | Buttons |
| Button/Medium | Inter | SemiBold 600 | 14 | 16 | Small buttons |
| Button/Small | Inter | SemiBold 600 | 12 | 16 | Tiny buttons |

### 4.3 Spacing & Radius

| Token | Value | Usage |
|---|---|---|
| radius-xs | 8 | Card corners, button radius |
| Button/Tiny radius | 6 | Small buttons |
| Layout margin | 24 | Screen edge padding |
| Card gap | 16 | Between cards/sections |

### 4.4 Shadows

Card shadow: `DropShadow(color: #1319271A offset: (0,10) radius: 32 spread: -4)` + `DropShadow(#1319271F offset: (0,6) radius: 14 spread: -6)`

---

## 5. Figma Screen → Code Map

| Figma Frame | Screen ID | Code File | Status |
|---|---|---|---|
| 1-1 (Page-Home-1) | 98:4545 | `home_screen.dart` | Built |
| 2-1 (Page-Friend-1) | 98:7588 | `friends/screens/friends_screen.dart` | Built |
| 2-3 (Page-Friend-2) | 106:9508 | `friends/screens/friends_screen.dart` | Built (Friends tab) |
| 2-4 (Page-Friend-3) | 106:9881 | `friends/screens/connect_screen.dart` | Built |
| 2-5 (Page-Friend-4) | 106:10053 | `friends/screens/user_search_screen.dart` | Built |
| 5-1 (Page-Profile-1) | 98:8228 | `profile_screen.dart` | Built |
| Add Meal (bottom sheet) | — | `add_meal_sheet.dart` | Built, untested |
| Auth screens | — | `login/signup/verify/forgot` | Done |
| Main shell (bottom nav) | 98:6316 | `main_shell.dart` | Built |

### 5.1 Home (1-1) Sections

1. **Greeting bar**: "Hello, Meow!" + "How was your meal" + bell notification icon (badge "5")
2. **Calendar widget**: Scrollable month (March 2026), 7-column grid with date cells, dot indicators on days with meals, month navigation arrows, "Health" filter dropdown
3. **Emotion filters**: Like / Neutral / Dislike — colored dots with labels, horizontal row
4. **Monthly Snapshot**: 4 stats — Meals (42), Foods (30), Place (18), Spent (8,150฿)
5. **Recap cards**: Monthly Wrapped (April 2026) + Yearly Wrapped (2026) — rounded cards with icon
6. **Recent entries**: 3 meal cards — each with photo thumbnail, food name, restaurant + location, price + tags + feeling, bookmark icon

### 5.2 Friends - Feed (2-1)

- "Friends" header + add-user icon with notification badge
- Feed/Friends toggle tabs
- Feed posts: avatar + name + timestamp, meal photo (full width), food name, location, price + tags + feeling, caption text
- Like (heart, count) + Comment (bubble, count) + Bookmark icons
- Comment preview rows: avatar + name + "time ago" + comment text

### 5.3 Friends - List (2-3)

- Back arrow + "Friends" title + add-user icon
- Feed/Friends toggle (Friends tab active)
- Friend list rows: avatar + name + bio, "Friends" tag + cancel button

### 5.4 Friends - Connect (2-4)

- Back arrow + "Connect" title
- Search bar with magnifying glass icon + "Search ID" placeholder
- "Recent" section with recent search result (avatar + name + bio, check + cancel buttons)
- "Pending" section with request rows + "Send Request" button

### 5.5 Friends - User Search (2-5)

- Back arrow + "Connect" title
- Search bar with username text
- Profile card: centered large avatar, username, bio, "Send Request" button

### 5.6 Profile (5-1)

- Cover image (rounded rectangle top)
- Avatar (circle, centered on cover overlap)
- Username + bio
- Edit Profile / View Profile buttons
- Stats row: Meals, Foods, Place — centered below buttons

---

## 6. Supabase Database Schema

Tables: `profiles`, `restaurants`, `branches`, `meals`, `meal_foods`, `meal_photos`, `meal_tags`, `friends`, `likes`, `comments`, `bookmark_collections`, `bookmark_items`, `notifications`

Full schema in `supabase/migrations/001_schema.sql`. RLS in `002_rls.sql`.

Auth: Supabase's built-in `auth.users` table. Profile data in public `profiles` table.

---

## 7. Auth Flow

- `StateProvider<AuthState?>` initialized to null
- `authInitProvider` syncs current Supabase session on startup + listens to `onAuthStateChange`
- Auth guard reads `ref.read(authProvider) != null` to determine login state
- Login/signup screens explicitly set auth provider after success
- Logout navigates to `/auth/login`

---

## 8. Photo Handling

- Path: `{user_id}/{meal_id}/{sort_order}.{ext}`
- Upload via `supabase.storage.from('meal-photos').upload()`
- Serve via `getPublicUrl()` or signed URLs for private meals
- RLS on storage bucket: owner upload, owner+fri

---

## 9. Offline & Drafts

- Drafts stored locally via Isar (not yet implemented)
- Draft saved on sheet close if data exists
- On publish failure, auto-save as draft

---

## 10. Notifications (Future)

- Edge Function triggers on INSERT to `notifications` table
- Flutter listens via Realtime channel for badge updates

---

## 11. Error & Loading States

All async data uses Riverpod `AsyncValue.when()` pattern for loading/error/data states per MVP spec §31.

---

## 12. Privacy & Access Rules

All enforced via Supabase RLS:
- Own meals always visible
- Friend meals visible only if not private + friendship accepted
- Deleted meals hidden automatically
- No public discovery
