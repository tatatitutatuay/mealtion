# Mealtion — Master Implementation Plan

Updated: 2026-06-22
Reference: `Mealtion Document.md` (MVP spec), `2026-06-21-mealtion-architecture-design.md`
Figma: UI Design page (1:3), Design System page (0:1)

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
| 0.2 | Supabase project + migrations | [x] | `supabase/migrations/001_schema.sql`, `002_rls.sql` |
| 0.3 | Auth screens (login, signup, verify, forgot-pw) | [x] | `features/auth/screens/` |
| 0.4 | Auth provider + redirect guard | [x] | `features/auth/providers/auth_provider.dart`, `core/router/auth_guard.dart` |
| 0.5 | Bottom nav shell + tab routing | [x] | `features/home/screens/main_shell.dart` |

---

## Phase 1: Theme + Design System Alignment

Apply Figma design tokens to Flutter theme. Must be done first so all screens use the correct colors/typography.

| # | Task | Priority | Files |
|---|---|---|---|
| 1.1 | Update `colors.dart` with Figma palette (Primary `#F5A891`, Foundation greys, Semantic colors) | High | `core/theme/colors.dart` |
| 1.2 | Configure Noto Sans Thai + Inter fonts in `pubspec.yaml` + add font assets | High | `pubspec.yaml`, `fonts/` |
| 1.3 | Rewrite `app_theme.dart` with Figma typography scale (H4-H5, S1-S2, B1-B6, Button sizes) using `TextTheme` | High | `core/theme/app_theme.dart` |
| 1.4 | Apply card shadow tokens, radius system to theme | Medium | `core/theme/app_theme.dart` |

---

## Phase 2: Home Screen (Figma 1-1)

Build the full home screen matching the Figma design.

| # | Task | Priority | Files |
|---|---|---|---|
| 2.1 | Create greeting bar with bell notification widget | High | `features/home/widgets/greeting_bar.dart` |
| 2.2 | Build calendar widget (month header with nav, 7-col grid, dot indicators, filter dropdown) | High | `features/home/widgets/meal_calendar.dart` |
| 2.3 | Create emotion filter row (Like/Neutral/Dislike) | Medium | `features/home/widgets/emotion_filter.dart` |
| 2.4 | Build Monthly Snapshot stat cards (4 stats row) | High | `features/home/widgets/monthly_snapshot.dart` |
| 2.5 | Build Recap cards (Monthly Wrapped + Yearly Wrapped) | Medium | `features/home/widgets/recap_cards.dart` |
| 2.6 | Build Recent entries list (3 cards with photo, name, location, price, tags, feeling, bookmark) | High | `features/home/widgets/recent_meal_card.dart` |
| 2.7 | Wire home screen sections together in `home_screen.dart` | High | `features/home/screens/home_screen.dart` |
| 2.8 | Create home provider to fetch calendar data, snapshot stats, and recent meals from Supabase | High | `features/home/providers/home_provider.dart` |

---

## Phase 3: Add Meal — Test & Ship

Add Meal is fully coded but untested. Need to run migrations and verify.

| # | Task | Priority | Files |
|---|---|---|---|
| 3.1 | **Run migrations** in Supabase SQL editor (001 + 002) | **BLOCKER** | `supabase/migrations/` |
| 3.2 | Verify `meal_api_provider.dart` insert flow works end-to-end | High | `features/add_meal/providers/meal_api_provider.dart` |
| 3.3 | Fix any issues with photo upload, date/time format, restaurant/branch upsert | High | `features/add_meal/` |
| 3.4 | Test unsaved-changes dialog + discard flow | Medium | `features/add_meal/screens/add_meal_sheet.dart` |
| 3.5 | Save draft on close (Isar integration) | Low | `features/add_meal/providers/` |
| 3.6 | Wire "Drafts" button in sheet header | Medium | `features/add_meal/sheets/` |

---

## Phase 4: Friends System

### 4.1 Friends Feed (Figma 2-1)

| # | Task | Priority | Files |
|---|---|---|---|
| 4.1.1 | Create feed post widget (avatar+name+time, photo, food info, tags, caption, action bar) | High | `features/friends/widgets/feed_post.dart` |
| 4.1.2 | Create feed provider: fetch friend meals from Supabase with pagination (20 per batch) | High | `features/friends/providers/feed_provider.dart` |
| 4.1.3 | Build Feed tab in friends screen with infinite scroll | High | `features/friends/screens/feed_screen.dart` |
| 4.1.4 | Implement like action (heart toggle + count) | Medium | `features/friends/providers/like_provider.dart` |
| 4.1.5 | Implement comment UI (list + add) | Medium | `features/friends/widgets/comment_section.dart` |
| 4.1.6 | Build feed detail screen (tap post) | Low | `features/friends/screens/feed_detail_screen.dart` |

### 4.2 Friends List (Figma 2-3)

| # | Task | Priority | Files |
|---|---|---|---|
| 4.2.1 | Create friend list provider: fetch accepted friends from Supabase | High | `features/friends/providers/friend_list_provider.dart` |
| 4.2.2 | Build Friends tab with list rows (avatar, name, bio, "Friends" tag, unfriend) | High | `features/friends/screens/friend_list_screen.dart` |
| 4.2.3 | Wire Feed/Friends toggle tabs | High | `features/friends/screens/friends_home_screen.dart` |

### 4.3 Connect — Search + Pending (Figma 2-4, 2-5)

| # | Task | Priority | Files |
|---|---|---|---|
| 4.3.1 | Build Connect screen: back arrow, "Connect" title, search bar | High | `features/friends/screens/connect_screen.dart` |
| 4.3.2 | Implement user search by exact username via Supabase | High | `features/friends/providers/search_provider.dart` |
| 4.3.3 | Build "Recent" and "Pending" sections | Medium | `features/friends/widgets/` |
| 4.3.4 | Build user profile card result (Figma 2-5) with "Send Request" button | High | `features/friends/widgets/user_search_card.dart` |
| 4.3.5 | Implement friend request send/accept/reject/cancel | High | `features/friends/providers/friend_request_provider.dart` |

---

## Phase 5: Profile (Figma 5-1)

| # | Task | Priority | Files |
|---|---|---|---|
| 5.1 | Build profile header: cover image + avatar overlap + username + bio | High | `features/profile/widgets/profile_header.dart` |
| 5.2 | Add "Edit Profile" / "View Profile" buttons | Medium | `features/profile/widgets/` |
| 5.3 | Build stats row (Meals, Foods, Place) | Medium | `features/profile/widgets/profile_stats.dart` |
| 5.4 | Create profile provider to fetch user data + stats from Supabase | High | `features/profile/providers/profile_provider.dart` |
| 5.5 | Build Edit Profile screen (display name, username, bio, photo, currency, thresholds) | Medium | `features/profile/screens/edit_profile_screen.dart` |
| 5.6 | Wire friend profile view (view friend's profile via feed) | Low | `features/profile/screens/` |

---

## Phase 6: Gallery (Figma — MVP spec §20)

| # | Task | Priority | Files |
|---|---|---|---|
| 6.1 | Build gallery provider: fetch all user meals with photos | High | `features/gallery/providers/gallery_provider.dart` |
| 6.2 | Implement Grid view (3-column photo grid) | High | `features/gallery/screens/gallery_grid.dart` |
| 6.3 | Implement Timeline view (chronological list) | Medium | `features/gallery/screens/gallery_timeline.dart` |
| 6.4 | Add view toggle (Grid/Timeline) | Medium | `features/gallery/widgets/view_toggle.dart` |
| 6.5 | Add search/filter by food name, restaurant, tag | Medium | `features/gallery/providers/` |

---

## Phase 7: Bookmarks (MVP spec §21-23)

| # | Task | Priority | Files |
|---|---|---|---|
| 7.1 | Create bookmark provider (Base: Place/Food, Custom Collections) | Low | `features/bookmarks/providers/` |
| 7.2 | Build bookmark collection list screen | Low | `features/bookmarks/screens/` |
| 7.3 | Implement add/remove bookmark on meals | Low | `features/bookmarks/providers/` |

---

## Phase 8: Notifications (MVP spec §27)

| # | Task | Priority | Files |
|---|---|---|---|
| 8.1 | Create notification provider (fetch from Supabase `notifications` table) | Low | `features/notifications/providers/` |
| 8.2 | Build notification list screen | Low | `features/notifications/screens/` |
| 8.3 | Wire bell icon badge count to Home greeting bar | Low | `features/home/widgets/greeting_bar.dart` |

---

## Phase 9: Settings (MVP spec §28)

| # | Task | Priority | Files |
|---|---|---|---|
| 9.1 | Build settings screen (password change, currency, thresholds, delete account, logout) | Low | `features/settings/screens/settings_screen.dart` |

---

## Phase 10: Edge Cases + Polish (MVP spec §29-33)

| # | Task | Priority | Files |
|---|---|---|---|
| 10.1 | Loading/error/empty states on all screens (AsyncValue.when) | Medium | All screens |
| 10.2 | Meal popup/detail screen (general meal card popup) | Low | `features/feed/screens/meal_detail_screen.dart` |
| 10.3 | Edit/delete meal flow | Low | `features/add_meal/providers/` |
| 10.4 | Offline handling + retry logic | Low | Cross-cutting |

---

## Critical Path (Recommended Order)

```
Phase 1 (Theme) → Phase 3 (Add Meal) → Phase 2 (Home) → Phase 4 (Friends) → Phase 5 (Profile)
```

Phase 1 first because all screens depend on correct colors/typography.
Phase 3 next because code is already written (just need migrations).
Phase 2 after because Home is the landing screen.
Phases 4-5 are the remaining primary tab screens.
Phases 6-10 are secondary features.
