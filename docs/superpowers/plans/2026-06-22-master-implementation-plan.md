# Mealtion — Master Implementation Plan

Updated: 2026-06-23 (post-audit, post-implementation)
Reference: `Mealtion Document.md` (MVP spec), `2026-06-21-mealtion-architecture-design.md`
Figma: UI Design page (1:3), Design System page (0:1)
Figma file: `AajKYbyFqmK1lJuNvFHcgP`

## Status Summary

**Completed phases:** 0 (Foundation), 1 (Theme), 2 (Home), 3 (Add Meal), 4 (Friends), 5 (Profile), 6 (Gallery), 7 (Bookmarks), 8 (Notifications), 9 (Settings), 10 (Onboarding), 11.1 (Meal Detail), 11.2 (Meal Delete — partial), 11.3 (Friend Requests), 11.4 (Friend Profiles), 11.5 (Bookmark Actions — partial)

**Remaining:** 11.2.1/11.2.5 (Meal edit mode), 11.3.6 (Unread badge), 11.4.5 (View Profile button), 11.5.5-11.5.6 (Collection edit/select), 11.6 (Profile photo upload), 11.7 (Restaurant search), 11.8 (Calendar filters), 11.9 (Drafts), 11.10 (Tag autocomplete), 11.11 (Price level calc)

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

## Phase 8: Notifications (DONE)

| # | Task | Status | Files |
|---|---|---|---|
| 8.1 | Notification provider (fetch from Supabase) | [x] | `features/notifications/providers/notifications_provider.dart` |
| 8.2 | Notification list screen (friend requests, likes, comments) | [x] | `features/notifications/screens/notifications_screen.dart` |
| 8.3 | Mark as read functionality | [x] | `features/notifications/screens/notifications_screen.dart` |
| 8.4 | Wire bell icon badge count to greeting bar | [x] | `features/home/screens/home_screen.dart` |

---

## Phase 9: Settings (DONE)

| # | Task | Status | Files |
|---|---|---|---|
| 9.1 | Settings screen (currency, price privacy, notification prefs) | [x] | `features/profile/screens/settings_screen.dart` |
| 9.2 | Account deletion with confirmation | [x] | `features/profile/screens/settings_screen.dart` |
| 9.3 | Wire Settings button in profile screen | [x] | `features/home/screens/profile_screen.dart` |

---

## Phase 10: Onboarding (DONE)

5-step onboarding flow after email verification (MVP spec §4).

| # | Task | Status | Files |
|---|---|---|---|
| 10.1 | Onboarding screen with 5 steps (single screen) | [x] | `features/auth/screens/onboarding_screen.dart` |
| 10.2 | Step 1: Profile Identity (display name, username) | [x] | — |
| 10.3 | Step 2: Profile Info (bio) | [x] | — |
| 10.4 | Step 3: Currency selection | [x] | — |
| 10.5 | Step 4: Price thresholds | [x] | — |
| 10.6 | Step 5: Permissions | [x] | — |
| 10.7 | AuthGuard redirects to /onboarding if not completed | [x] | `core/router/auth_guard.dart` |
| 10.8 | Router refreshListenable triggers redirect on auth state change | [x] | `core/router/app_router.dart` |

---

## Phase 11: Gap Closure (Post-audit — CRITICAL)

Gaps identified by comparing Figma designs + spec against running app.

### 11.1 Meal Detail Popup (DONE)

| # | Task | Status | Files |
|---|---|---|---|
| 11.1.1 | Meal detail provider (single meal + meals by date) | [x] | `features/home/providers/meal_detail_provider.dart` |
| 11.1.2 | Meal detail bottom sheet (photo carousel + vertical swipe) | [x] | `features/home/widgets/meal_detail_sheet.dart` |
| 11.1.3 | Gallery timeline cards → meal detail | [x] | `features/home/screens/gallery_screen.dart` |
| 11.1.4 | Gallery grid items → meal detail | [x] | `features/home/screens/gallery_screen.dart` |
| 11.1.5 | Friends feed posts → meal detail | [x] | `features/friends/screens/friends_screen.dart` |
| 11.1.6 | Recent entries → meal detail | [x] | `features/home/widgets/recent_entries.dart` |
| 11.1.7 | Calendar date tap → meal detail with vertical swipe | [x] | `features/home/widgets/calendar_widget.dart` |

### 11.2 Meal Edit + Delete (PARTIAL)

| # | Task | Status | Files |
|---|---|---|---|
| 11.2.1 | Add edit mode to AddMealSheet (accept optional mealId) | [ ] | `features/add_meal/screens/add_meal_sheet.dart` |
| 11.2.2 | updateMeal method in MealApi | [x] | `features/add_meal/providers/meal_api_provider.dart` |
| 11.2.3 | deleteMeal method in MealApi | [x] | `features/add_meal/providers/meal_api_provider.dart` |
| 11.2.4 | Delete confirmation dialog | [x] | `features/home/widgets/meal_detail_sheet.dart` |
| 11.2.5 | Wire edit button → AddMealSheet edit mode | [ ] | Needs photo URL→File handling |

### 11.3 Friend Request Management (DONE)

| # | Task | Status | Files |
|---|---|---|---|
| 11.3.1 | Friend requests provider (received + sent) | [x] | `features/friends/providers/friends_providers.dart` |
| 11.3.2 | Friend requests screen (Received/Sent tabs) | [x] | `features/friends/screens/friend_requests_screen.dart` |
| 11.3.3 | Accept/reject received requests | [x] | `features/friends/providers/friends_providers.dart` |
| 11.3.4 | Cancel sent request | [x] | `features/friends/providers/friends_providers.dart` |
| 11.3.5 | Friend requests button in friends screen | [x] | `features/friends/screens/friends_screen.dart` |
| 11.3.6 | Unread badge on Add Friend icon | [ ] | `features/friends/screens/friends_screen.dart` |

### 11.4 Friend Profile Viewing (DONE)

| # | Task | Status | Files |
|---|---|---|---|
| 11.4.1 | Profile statistics provider | [x] | `features/friends/providers/profile_provider.dart` |
| 11.4.2 | Friend profile screen (header + stats + timeline/grid) | [x] | `features/friends/screens/friend_profile_screen.dart` |
| 11.4.3 | Parameterized gallery provider (userGalleryProvider) | [x] | `features/home/providers/gallery_provider.dart` |
| 11.4.4 | Friend list tap → friend profile | [x] | `features/friends/screens/friends_screen.dart` |
| 11.4.5 | Wire "View Profile" button in own profile | [ ] | `features/home/screens/profile_screen.dart` |

### 11.5 Bookmark Actions (PARTIAL)

| # | Task | Status | Files |
|---|---|---|---|
| 11.5.1 | Bookmark action provider (add/remove meal) | [x] | `features/bookmarks/providers/bookmark_provider.dart` |
| 11.5.2 | Create collection dialog | [x] | `features/home/widgets/meal_detail_sheet.dart` |
| 11.5.3 | Collection selector bottom sheet | [x] | `features/home/widgets/meal_detail_sheet.dart` |
| 11.5.4 | Bookmark icon on meal detail → collection selector | [x] | `features/home/widgets/meal_detail_sheet.dart` |
| 11.5.5 | Edit collection name | [ ] | `features/bookmarks/screens/custom_collection_detail_screen.dart` |
| 11.5.6 | Select items mode (multi-select + delete) | [ ] | `features/bookmarks/screens/custom_collection_detail_screen.dart` |

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
[DONE] 11.1 Meal Detail → [DONE] 11.2 Meal Delete → [DONE] 10 Onboarding → [DONE] 8 Notifications → [DONE] 11.3 Friend Requests → [DONE] 11.4 Friend Profiles → [DONE] 9 Settings → [DONE] 11.5 Bookmark Actions
```

**Remaining work (priority order):**
1. 11.2.1/11.2.5 — Meal edit mode (needs photo URL→File download)
2. 11.6 — Profile photo upload (image picker + avatars bucket)
3. 11.7 — Restaurant search autocomplete
4. 11.8 — Calendar indicator filters
5. 11.9 — Draft meals (local storage)
6. 11.10 — Tag autocomplete
7. 11.11 — Price level calculation
8. 11.3.6 — Unread badge on Add Friend icon
9. 11.4.5 — View Profile button in own profile
10. 11.5.5-11.5.6 — Collection edit/select mode
