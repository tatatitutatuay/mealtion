# Phase 1.5: Supabase Migration Plan

**Goal:** Replace custom Go backend with Supabase (auth, DB, storage). Flutter talks directly to Supabase.

**Architecture:** Flutter + Supabase only. No Go server. RLS enforces access control.

---

### Task 1: Add Supabase Flutter SDK

**Files:**
- Modify: `app/pubspec.yaml`
- Create: `app/lib/core/supabase/supabase_client.dart`

- [ ] Add `supabase_flutter` dependency to `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Create Supabase initialization provider

### Task 2: Rewrite Auth to use Supabase

**Files:**
- Modify: `app/lib/features/auth/providers/auth_provider.dart`
- Delete: `app/lib/core/api/api_client.dart`
- Delete: `app/lib/core/api/auth_api.dart`
- Delete: `app/lib/core/api/models/api_response.dart`
- Delete: `app/lib/core/storage/secure_storage.dart`

- [ ] Rewrite `AuthNotifier` to use `supabase.auth`
- [ ] Remove Dio/API client, secure storage, auth API
- [ ] Update screens to use Supabase auth methods

### Task 3: Create database schema

**Files:**
- Create: `supabase/migrations/001_schema.sql`

- [ ] Write full DB schema (profiles, meals, meal_foods, meal_photos, meal_tags, restaurants, branches, friends, likes, comments, bookmark_collections, bookmark_items, notifications)

### Task 4: RLS policies

**Files:**
- Create: `supabase/migrations/002_rls.sql`

- [ ] Enable RLS on all tables
- [ ] Write policies for meals, friends, likes, comments, bookmarks, notifications, storage

### Task 5: Remove Go backend

**Files:**
- Delete: `backend/` directory

- [ ] Remove `backend/` from version control

### Task 6: Update docs and commit

- [ ] Update design doc (already done)
- [ ] Commit all changes
