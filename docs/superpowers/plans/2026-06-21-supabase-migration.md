# Phase 1.5: Supabase Migration Plan

**Goal:** Replace custom Go backend with Supabase (auth, DB, storage). Flutter talks directly to Supabase.

**Architecture:** Flutter + Supabase only. No Go server. RLS enforces access control.

---

**STATUS: ✅ COMPLETE** (committed at `20e0cac`)

### Task 1: Add Supabase Flutter SDK

- [x] Add `supabase_flutter` dependency to `pubspec.yaml`
- [x] Run `flutter pub get`
- [x] Create Supabase initialization provider

### Task 2: Rewrite Auth to use Supabase

- [x] Rewrite auth provider to StreamProvider wrapping `supabase.auth.onAuthStateChange`
- [x] Remove Dio/API client, secure storage, auth API
- [x] Update screens to use Supabase auth methods

### Task 3: Create database schema

- [x] Write full DB schema (profiles, meals, meal_foods, meal_photos, meal_tags, restaurants, branches, friends, likes, comments, bookmark_collections, bookmark_items, notifications)

### Task 4: RLS policies

- [x] Enable RLS on all tables
- [x] Write policies for meals, friends, likes, comments, bookmarks, notifications, storage

### Task 5: Remove Go backend

- [x] Remove `backend/` from version control

### Task 6: Update docs and commit

- [x] Update design doc
- [x] Commit all changes
