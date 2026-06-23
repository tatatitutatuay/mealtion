# Mealtion — Master Implementation Plan

Updated: 2026-06-23 (post-audit)
Reference: `Mealtion Document.md` (MVP spec), `2026-06-21-mealtion-architecture-design.md`
Figma: UI Design page (1:3), Design System page (0:1)
Figma file: `AajKYbyFqmK1lJuNvFHcgP`

---

## Legend

- **[ ]** Not started
- **[~]** In progress
- **[x]** Complete

---

## Phase 0: Foundation (Done)

| # | Task | Status | Files |
|---|---|---|---|
| 0.1 | Project scaffold + Flutter init | [x] | `app/` |
| 0.2 | Supabase project + migrations + RLS policies | [x] | `supabase/migrations/001_schema.sql`, `002_rls.sql` |
| 0.3 | Auth screens (login, signup, verify, forgot-pw) | [x] | `features/auth/screens/` |
| 0.4 | Auth provider + redirect guard + auto-profile creation | [x] | `features/auth/providers/auth_provider.dart`, `core/router/auth_guard.dart` |
| 0.5 | Bottom nav shell + tab routing | [x] | `features/home/screens/main_shell.dart` |

---

## Phase 1: Theme + Design System (Done)

| # | Task | Status | Files |
|---|---|---|---|
| 1.1 | Figma palette in `colors.dart` | [x] | `core/theme/colors.dart` |
| 1.2 | Noto Sans Thai + Inter fonts | [x] | `pubspec.yaml`, `fonts/` |
| 1.3 | Figma typography scale in `app_theme.dart` | [x] | `core/theme/app_theme.dart` |
| 1.4 | Card shadow tokens, radius system | [x] | `core/theme/app_theme.dart` |

---

## Phase 2: Home Screen (Done — gaps in Phase 11)

| # | Task | Status | Files |
|---|---|---|---|
| 2.1 | Greeting bar with bell notification widget | [x] | `features/home/widgets/greeting_bar.dart` |
| 2.2 | Calendar widget (month nav, 7-col grid, dot indicators) | [x] | `features/home/widgets/calendar_widget.dart` |
| 2.3 | Emotion filter row (visual only) | [x] | `features/home/widgets/emotion_filters.dart` |
| 2.4 | Monthly Snapshot stat cards | [x] | `features/home/widgets/recap_cards.dart` |
| 2.5 | Recap cards (Monthly/Yearly Wrapped) | [x] | `features/home/widgets/recap_cards.dart` |
| 2.6 | Recent entries list | [x] | `features/home/widgets/recent_entries.dart` |
| 2.7 | Home screen wired together | [x] | `features/home/screens/home_screen.dart` |
| 2.8 | Home provider fetches calendar + stats + recent meals | [x] | `features/home/providers/home_provider.dart` |

---

## Phase 3: Add Meal (Done — gaps in Phase 11)

| # | Task | Status | Files |
|---|---|---|---|
| 3.1 | Run migrations + RLS policies in Supabase | [x] | `supabase/migrations/` |
| 3.2 | Meal insert flow works end-to-end | [x] | `features/add_meal/providers/meal_api_provider.dart` |
| 3.3 | Photo upload to Supabase Storage + public URL storage | [x] | `features/add_meal/providers/meal_api_provider.dart` |
| 3.4 | Unsaved-changes dialog + discard flow | [x] | `features/add_meal/screens/add_meal_sheet.dart` |
| 3.5 | Food chips submit on focus loss + Enter | [x] | `features/add_meal/widgets/food_chips.dart` |

---

## Phase 4: Friends System (Partially done — gaps in Phase 11)

### 4.1 Friends Feed (Figma 2-1)

| # | Task | Status | Files |
|---|---|---|---|
| 4.1.1 | Feed post widget (avatar+name+time, photo, food info, action bar) | [x] | `features/friends/screens/friends_screen.dart` |
| 4.1.2 | Feed provider: fetch friend meals with engagement data | [x] | `features/friends/providers/friends_providers.dart` |
| 4.1.3 | Feed tab with posts | [x] | `features/friends/screens/friends_screen.dart` |
| 4.1.4 | Like action (heart toggle + count) | [x] | `features/friends/providers/engagement_provider.dart` |
| 4.1.5 | Comment bottom sheet (Figma 2-2) | [x] | `features/friends/widgets/comment_sheet.dart` |
| 4.1.6 | Bookmark toggle on feed posts | [x] | `features/friends/providers/engagement_provider.dart` |

### 4.2 Friends List (Figma 2-3)

| # | Task | Status | Files |
|---|---|---|---|
| 4.2.1 | Friend list provider | [x] | `features/friends/providers/friends_providers.dart` |
| 4.2.2 | Friends tab with list rows | [x] | `features/friends/screens/friends_screen.dart` |
| 4.2.3 | Feed/Friends toggle tabs | [x] | `features/friends/screens/friends_screen.dart` |

### 4.3 Connect — Search (Figma 2-4, 2-5)

| # | Task | Status | Files |
|---|---|---|---|
| 4.3.1 | Connect screen with search bar | [x] | `features/friends/screens/connect_screen.dart` |
| 4.3.2 | User search by username | [x] | `features/friends/screens/user_search_screen.dart` |
| 4.3.3 | User profile card with Send Request button | [x] | `features/friends/screens/user_search_screen.dart` |
| 4.3.4 | Send friend request | [x] | `features/friends/providers/friends_providers.dart` |

---

## Phase 5: Profile (Partially done — gaps in Phase 11)

| # | Task | Status | Files |
|---|---|---|---|
| 5.1 | Profile header (avatar + username + bio) | [x] | `features/home/screens/profile_screen.dart` |
| 5.2 | Edit Profile / View Profile buttons | [x] | `features/home/screens/profile_screen.dart` |
| 5.3 | Edit profile screen (display name, username, bio) | [x] | `features/profile/screens/edit_profile_screen.dart` |
| 5.4 | Profile provider | [x] | `features/friends/providers/profile_provider.dart` |

---

## Phase 6: Gallery (Done — gaps in Phase 11)

| # | Task | Status | Files |
|---|---|---|---|
| 6.1 | Gallery provider: fetch meals by month | [x] | `features/home/providers/gallery_provider.dart` |
| 6.2 | Gallery header + bookmark icon nav | [x] | `features/home/screens/gallery_screen.dart` |
| 6.3 | Search bar → search screen | [x] | `features/home/screens/gallery_search_screen.dart` |
| 6.4 | Month navigation | [x] | `features/home/screens/gallery_screen.dart` |
| 6.5 | Timeline/Grid view toggle | [x] | `features/home/screens/gallery_screen.dart` |
| 6.6 | Timeline list with meal cards | [x] | `features/home/screens/gallery_screen.dart` |
| 6.7 | Grid view (3-column) | [x] | `features/home/screens/gallery_screen.dart` |
| 6.8 | Empty state | [x] | `features/home/screens/gallery_screen.dart` |
| 6.9 | Search provider + results grid | [x] | `features/home/providers/gallery_provider.dart` |
| 6.10 | Photo URL resolution (resolvePhotoUrl helper) | [x] | `core/supabase/supabase_client.dart` |

---

## Phase 7: Bookmarks (Partially done — gaps in Phase 11)

| # | Task | Status | Files |
|---|---|---|---|
| 7.1 | Bookmark collections screen | [x] | `features/bookmarks/screens/bookmark_collections_screen.dart` |
| 7.2 | Base bookmark detail (Place, Food) | [x] | `features/bookmarks/screens/base_bookmark_detail_screen.dart` |
| 7.3 | Custom collection detail | [x] | `features/bookmarks/screens/custom_collection_detail_screen.dart` |
| 7.4 | Bookmark provider | [x] | `features/bookmarks/providers/bookmark_provider.dart` |

---

## Phase 8: Notifications (Not started)

| # | Task | Priority | Files |
|---|---|---|---|
| 8.1 | Notification provider (fetch from Supabase) | High | `features/notifications/providers/notifications_provider.dart` |
| 8.2 | Notification list screen (friend requests, likes, comments) | High | `features/notifications/screens/notifications_screen.dart` |
| 8.3 | Mark as read functionality | Medium | `features/notifications/providers/notifications_provider.dart` |
| 8.4 | Wire bell icon badge count to greeting bar | High | `features/home/widgets/greeting_bar.dart` |

---

## Phase 9: Settings (Not started)

| # | Task | Priority | Files |
|---|---|---|---|
| 9.1 | Settings screen (currency, price privacy, notification prefs) | Medium | `features/profile/screens/settings_screen.dart` |
| 9.2 | Account deletion with password confirmation | Medium | `features/profile/screens/settings_screen.dart` |
| 9.3 | Wire Settings button in profile screen | Medium | `features/home/screens/profile_screen.dart` |

---

## Phase 10: Onboarding (Not started — CRITICAL)

5-step onboarding flow after email verification (MVP spec §4).

| # | Task | Priority | Files |
|---|---|---|---|
| 10.1 | Onboarding provider + state management | High | `features/auth/providers/onboarding_provider.dart` |
| 10.2 | Step 1: Profile Identity (display name, username) | High | `features/auth/screens/onboarding_profile_screen.dart` |
| 10.3 | Step 2: Profile Info (photo upload, bio) | High | `features/auth/screens/onboarding_info_screen.dart` |
| 10.4 | Step 3: Currency selection | High | `features/auth/screens/onboarding_currency_screen.dart` |
| 10.5 | Step 4: Price thresholds (two values) | High | `features/auth/screens/onboarding_thresholds_screen.dart` |
| 10.6 | Step 5: Permissions (photo library, camera, notifications) | Medium | `features/auth/screens/onboarding_permissions_screen.dart` |
| 10.7 | Update AuthGuard to redirect to onboarding if not completed | High | `core/router/auth_guard.dart` |
| 10.8 | Add `onboarding_completed` + `currency` + `price_threshold_low` + `price_threshold_high` columns to profiles table | High | `supabase/migrations/` |

---

## Phase 11: Gap Closure (Post-audit — CRITICAL)

Gaps identified by comparing Figma designs + spec against running app.

### 11.1 Meal Detail Popup (CRITICAL — used everywhere)

Reusable meal detail modal. Tapped from calendar, gallery, friends feed, bookmarks.

| # | Task | Priority | Files |
|---|---|---|---|
| 11.1.1 | Create meal detail provider (fetch single meal with photos, foods, restaurant, tags) | High | `features/home/providers/meal_detail_provider.dart` |
| 11.1.2 | Build meal detail bottom sheet (photo carousel with PageView + dot indicators, meal info, edit button) | High | `features/home/widgets/meal_detail_sheet.dart` |
| 11.1.3 | Wire tap handlers: gallery timeline cards → meal detail | High | `features/home/screens/gallery_screen.dart` |
| 11.1.4 | Wire tap handlers: gallery grid items → meal detail | High | `features/home/screens/gallery_screen.dart` |
| 11.1.5 | Wire tap handlers: friends feed posts → meal detail | High | `features/friends/screens/friends_screen.dart` |
| 11.1.6 | Wire tap handlers: recent entries → meal detail | High | `features/home/widgets/recent_entries.dart` |
| 11.1.7 | Calendar date tap → meal detail with vertical swipe (PageView vertical between meals of same date) | High | `features/home/widgets/calendar_widget.dart` |

### 11.2 Meal Edit + Delete (CRITICAL)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.2.1 | Add edit mode to AddMealSheet (accept optional mealId, pre-fill state) | High | `features/add_meal/screens/add_meal_sheet.dart` |
| 11.2.2 | Add updateMeal method to MealApi (update meal row + replace photos + foods + tags) | High | `features/add_meal/providers/meal_api_provider.dart` |
| 11.2.3 | Add deleteMeal method to MealApi (delete meal + cascade) | High | `features/add_meal/providers/meal_api_provider.dart` |
| 11.2.4 | Delete confirmation dialog | High | `features/home/widgets/meal_detail_sheet.dart` |
| 11.2.5 | Wire edit button in meal detail → open AddMealSheet in edit mode | High | `features/home/widgets/meal_detail_sheet.dart` |

### 11.3 Friend Request Management (CRITICAL)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.3.1 | Friend requests provider (fetch received + sent pending) | High | `features/friends/providers/friends_providers.dart` |
| 11.3.2 | Friend requests screen with two tabs (Received, Sent) | High | `features/friends/screens/friend_requests_screen.dart` |
| 11.3.3 | Accept/reject received request actions | High | `features/friends/providers/friends_providers.dart` |
| 11.3.4 | Cancel sent request action | High | `features/friends/providers/friends_providers.dart` |
| 11.3.5 | Wire friend requests button in friends screen | High | `features/friends/screens/friends_screen.dart` |
| 11.3.6 | Unread badge on Add Friend icon | Medium | `features/friends/screens/friends_screen.dart` |

### 11.4 Friend Profile Viewing (CRITICAL)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.4.1 | Profile statistics provider (meals count, foods count, places count, friends count) | High | `features/friends/providers/profile_provider.dart` |
| 11.4.2 | Friend profile screen (header + stats + timeline/grid + month nav) | High | `features/friends/screens/friend_profile_screen.dart` |
| 11.4.3 | Reuse gallery provider for friend's meals (parameterized by user_id) | High | `features/home/providers/gallery_provider.dart` |
| 11.4.4 | Wire friend list tap → friend profile | High | `features/friends/screens/friends_screen.dart` |
| 11.4.5 | Wire "View Profile" button in own profile | Medium | `features/home/screens/profile_screen.dart` |

### 11.5 Bookmark Actions (HIGH)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.5.1 | Bookmark action provider (save meal to collection, remove from collection) | High | `features/bookmarks/providers/bookmark_provider.dart` |
| 11.5.2 | Create collection dialog (name + cover image) | High | `features/bookmarks/widgets/create_collection_dialog.dart` |
| 11.5.3 | Collection selector bottom sheet (pick collection when bookmarking a meal) | High | `features/bookmarks/widgets/collection_selector.dart` |
| 11.5.4 | Wire bookmark icon on meal detail → collection selector | High | `features/home/widgets/meal_detail_sheet.dart` |
| 11.5.5 | Edit collection name functionality | Medium | `features/bookmarks/screens/custom_collection_detail_screen.dart` |
| 11.5.6 | Select items mode (multi-select + delete from collection) | Medium | `features/bookmarks/screens/custom_collection_detail_screen.dart` |

### 11.6 Profile Photo Upload (MEDIUM)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.6.1 | Add image picker to edit profile screen | Medium | `features/profile/screens/edit_profile_screen.dart` |
| 11.6.2 | Upload profile photo to Supabase Storage (`avatars` bucket) | Medium | `features/profile/providers/profile_provider.dart` |
| 11.6.3 | Create `avatars` storage bucket + RLS policies | Medium | `supabase/migrations/` |

### 11.7 Restaurant Search (MEDIUM)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.7.1 | Restaurant search provider (search by name, user-scoped) | Medium | `features/add_meal/providers/restaurant_provider.dart` |
| 11.7.2 | Autocomplete suggestions in restaurant search widget | Medium | `features/add_meal/widgets/restaurant_search.dart` |
| 11.7.3 | Branch search + creation for selected restaurant | Medium | `features/add_meal/widgets/restaurant_search.dart` |

### 11.8 Calendar Indicator Filters (MEDIUM)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.8.1 | Filter state in calendar widget (price/heaviness/feeling) | Medium | `features/home/widgets/calendar_widget.dart` |
| 11.8.2 | Color mapping for each filter type | Medium | `features/home/widgets/calendar_widget.dart` |
| 11.8.3 | Dropdown to switch between filter types | Medium | `features/home/widgets/calendar_widget.dart` |

### 11.9 Draft Meals (LOW)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.9.1 | Set up local storage (SharedPreferences or Hive) for draft persistence | Low | `features/add_meal/providers/draft_provider.dart` |
| 11.9.2 | Save draft on discard dialog "Save as Draft" | Low | `features/add_meal/screens/add_meal_sheet.dart` |
| 11.9.3 | Draft meals screen (grid of draft thumbnails) | Low | `features/add_meal/screens/draft_meals_screen.dart` |
| 11.9.4 | Wire drafts button in Add Meal header | Low | `features/add_meal/screens/add_meal_sheet.dart` |
| 11.9.5 | Resume draft → open AddMealSheet with draft data | Low | `features/add_meal/screens/add_meal_sheet.dart` |

### 11.10 Tag Autocomplete (LOW)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.10.1 | Tag provider (fetch user's tags, search) | Low | `features/add_meal/providers/tag_provider.dart` |
| 11.10.2 | Autocomplete suggestions in tag input | Low | `features/add_meal/widgets/tag_input.dart` |

### 11.11 Price Level Calculation (LOW — depends on onboarding)

| # | Task | Priority | Files |
|---|---|---|---|
| 11.11.1 | Calculate price level from user's thresholds (Affordable/Moderate/Expensive) | Low | `features/add_meal/widgets/price_input.dart` |
| 11.11.2 | Display price level indicator in Add Meal + meal detail | Low | `features/add_meal/widgets/price_input.dart` |

---

## Critical Path (Updated)

```
Phase 11.1 (Meal Detail Popup) → Phase 11.2 (Meal Edit/Delete) → Phase 10 (Onboarding) → Phase 8 (Notifications) → Phase 11.3 (Friend Requests) → Phase 11.4 (Friend Profiles) → Phase 9 (Settings) → Phase 11.5 (Bookmark Actions)
```

**Why this order:**
1. **Meal Detail Popup** first — single highest-leverage feature, used in 4+ screens
2. **Meal Edit/Delete** — extends Add Meal sheet, depends on meal detail for trigger
3. **Onboarding** — blocks new users from being useful (currency + thresholds needed)
4. **Notifications** — needed for social features to function
5. **Friend Requests** — completes friends loop
6. **Friend Profiles** — extends profile, reuses gallery components
7. **Settings** — currency, account deletion
8. **Bookmark Actions** — wire up bookmark icon, depends on meal detail for trigger

**Parallel tracks (can be done anytime):**
- Phase 11.6 (Profile Photo Upload)
- Phase 11.7 (Restaurant Search)
- Phase 11.8 (Calendar Filters)
- Phase 11.9 (Drafts)
- Phase 11.10 (Tag Autocomplete)
- Phase 11.11 (Price Level)
