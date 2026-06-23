# Mealtion — Master Implementation Plan

Updated: 2026-06-23
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

## Phase 3: Add Meal — Test & Ship (Figma 3-1)

Add Meal is fully coded but untested. Need to run migrations and verify.
Figma 3-1 (node 98:5844) shows the full form: photo upload, date, time, meal name, source, tags, restaurant, branch, price, price indicator, heaviness, feeling.

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
| 4.1.5 | Implement comment bottom sheet (Figma 2-2: drag handle, comment list with avatar+name+time, input bar) | Medium | `features/friends/widgets/comment_sheet.dart` |
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

## Phase 6: Gallery (Figma 4-1, 4-2, 4-3 — MVP spec §18-19)

Gallery is Bottom Nav item 4. Figma section 4 includes Gallery + Bookmarks as one flow (bookmark icon in Gallery header → Bookmark collections).

### 6.1 Gallery Timeline (Figma 4-1, node 98:7908)

| # | Task | Priority | Files |
|---|---|---|---|
| 6.1.1 | Build gallery provider: fetch user meals by month from Supabase | High | `features/gallery/providers/gallery_provider.dart` |
| 6.1.2 | Gallery header: "Gallery" title + bookmark icon (navigates to Phase 7) | High | `features/gallery/widgets/gallery_header.dart` |
| 6.1.3 | Search bar ("Search meal") — taps to open search mode (6.3) | High | `features/gallery/widgets/gallery_search_bar.dart` |
| 6.1.4 | Month navigation (arrows + month/year label, taps for month picker popup) | High | `features/gallery/widgets/month_nav.dart` |
| 6.1.5 | Timeline/Grid view toggle (align-justify vs table icons) | Medium | `features/gallery/widgets/view_toggle.dart` |
| 6.1.6 | Timeline list: date labels with vertical line, meal cards (photo, name, restaurant+branch, price chip, heaviness chip, feeling chip, bookmark icon) | High | `features/gallery/widgets/timeline_meal_card.dart` |
| 6.1.7 | Empty state when no meals in selected month | Medium | `features/gallery/screens/gallery_screen.dart` |

### 6.2 Gallery Grid (Figma 4-2, node 111:10321)

| # | Task | Priority | Files |
|---|---|---|---|
| 6.2.1 | 3-column photo grid (square ~105px thumbnails, rounded corners) | High | `features/gallery/widgets/photo_grid.dart` |
| 6.2.2 | Multi-photo indicator icon on grid items | Medium | `features/gallery/widgets/photo_grid.dart` |
| 6.2.3 | Tap grid item → open Meal Popup (left/right photo nav only, no vertical) | High | `features/gallery/screens/gallery_screen.dart` |

### 6.3 Gallery Search (Figma 4-3, node 111:10654)

| # | Task | Priority | Files |
|---|---|---|---|
| 6.3.1 | Search mode: back arrow + search bar (no Gallery title/month nav) | High | `features/gallery/screens/gallery_search_screen.dart` |
| 6.3.2 | Search provider: partial text match on food name, restaurant, branch, tags | High | `features/gallery/providers/search_provider.dart` |
| 6.3.3 | Results: 3-column photo grid, newest first | High | `features/gallery/widgets/photo_grid.dart` (reuse) |

---

## Phase 7: Bookmarks (Figma 4-4, 4-5, 4-6 — MVP spec §20-22)

Accessed from bookmark icon in Gallery header. Figma shows 3 screens.

### 7.1 Bookmark Collections List (Figma 4-4, node 111:10896)

| # | Task | Priority | Files |
|---|---|---|---|
| 7.1.1 | Bookmark provider: fetch Base collections (Place, Food) + Custom collections | High | `features/bookmarks/providers/bookmark_provider.dart` |
| 7.1.2 | Screen: back arrow + plus icon + "Bookmark" title | High | `features/bookmarks/screens/bookmark_collections_screen.dart` |
| 7.1.3 | "Base" section: 2 cards (Place, Food) with cover + title + subtitle | High | `features/bookmarks/widgets/base_collection_card.dart` |
| 7.1.4 | "Your" section: custom collection cards (same layout) | High | `features/bookmarks/widgets/custom_collection_card.dart` |
| 7.1.5 | Plus icon → create collection dialog (name + cover image) | Medium | `features/bookmarks/widgets/create_collection_dialog.dart` |

### 7.2 Base Bookmark Detail (Figma 4-5, node 111:11190)

| # | Task | Priority | Files |
|---|---|---|---|
| 7.2.1 | Screen: back arrow + more-horiz + "Bookmark" title + category label + count | High | `features/bookmarks/screens/base_bookmark_detail_screen.dart` |
| 7.2.2 | Alphabetical list grouped by first letter (letter headers + divider lines) | High | `features/bookmarks/widgets/alphabetical_list.dart` |
| 7.2.3 | Each item: thumbnail + name (Place: restaurant+branch, Food: food name) | High | `features/bookmarks/widgets/bookmark_item_row.dart` |
| 7.2.4 | Tap item → 3-column grid of related meals (reuse photo grid) | Medium | `features/bookmarks/screens/bookmark_meal_grid.dart` |
| 7.2.5 | More-horiz menu: edit icon (change item icon/photo) | Low | `features/bookmarks/widgets/` |

### 7.3 Custom Collection Detail (Figma 4-6, node 111:11514)

| # | Task | Priority | Files |
|---|---|---|---|
| 7.3.1 | Screen: back arrow + more-horiz + "Bookmark" title + collection name + count | High | `features/bookmarks/screens/custom_collection_detail_screen.dart` |
| 7.3.2 | 3-column photo grid (reuse from gallery), sorted by most recently saved | High | `features/bookmarks/widgets/` (reuse photo grid) |
| 7.3.3 | More-horiz menu: Edit Collection, Select Items, Remove items, Delete Collection | Medium | `features/bookmarks/widgets/collection_menu.dart` |
| 7.3.4 | Delete collection confirmation dialog | Medium | `features/bookmarks/widgets/` |
| 7.3.5 | Add meal to collection: bookmark icon on meal → collection selection popup | Medium | `features/bookmarks/widgets/collection_selector.dart` |

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
Phase 1 (Theme) → Phase 3 (Add Meal) → Phase 2 (Home) → Phase 4 (Friends) → Phase 5 (Profile) → Phase 6 (Gallery) → Phase 7 (Bookmarks)
```

Phase 1 first because all screens depend on correct colors/typography.
Phase 3 next because code is already written (just need migrations).
Phase 2 after because Home is the landing screen.
Phases 4-5 are the remaining primary tab screens.
Phase 6-7 (Gallery + Bookmarks) are the 4th bottom nav tab — one navigation flow in Figma (section 4).
Phases 8-10 are secondary features.
