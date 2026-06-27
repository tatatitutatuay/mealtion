# Full App Figma Alignment Design

**Date:** 2026-06-27
**Figma file:** `AajKYbyFqmK1lJuNvFHcgP` (Mealtion Project - Copy)
**Scope:** Theme tokens + all screens (Home, Gallery, Friends, Profile, Notifications)

## Goal

Align the entire app's visual design and features to the Figma design, including theme system updates.

## Theme Changes

### Font
- Switch from NotoSansThai to **IBM Plex Sans Thai** (Regular 400, Medium 500, SemiBold 600)
- Font files added to `assets/fonts/`
- Update `pubspec.yaml` font family entries
- Update `typography.dart` `_noto` constant to `_plex` = `'IBMPlexSansThai'`

### Spacing (`spacing.dart`)
- `layoutMargin`: 24 → **30**
- Add `radiusCard` = **20** (calendar card, recap cards)
- Add `radiusButton` = **7.5** (month nav, filter pills)
- Add `radiusPill` = **100** (day cells, tag pills)
- Add `radiusPhoto` = **10** (recent entry photos)
- Keep `radiusXs` = 8, `radiusTiny` = 6 for backward compat

### Colors (`colors.dart`)
- Add `tagGreen` = `Color(0xFFBDFFC1)` — price + healthy tags
- Add `tagYellow` = `Color(0xFFF0F8B0)` — neutral tag
- Add `tagRed` = `Color(0xFFFFAEAE)` — dislike tag + notification badge
- Add `photoPlaceholder` = `Color(0xFFD9D9D9)`
- Add `border` = `Color(0xFF000000)` — for outlined card borders
- Add `textFaded` = `Color(0x80000000)` — rgba(0,0,0,0.5) for "View All"

### Borders (add to `spacing.dart`)
- `static const cardBorder = BorderSide(color: AppColors.border, width: 0.5)`

## Widget Changes

### GreetingBar
- **Remove CircleAvatar** — text only per Figma
- "Hello, $name!" → 20px Medium (was 18px)
- "How was your meal?" → 12px Regular (was 14px)
- Bell button: 37×37 circular with 0.5px black border (was plain IconButton)
- Badge: `tagRed` bg `#ffaeae` (was `AppColors.error` red)

### CalendarWidget
- Wrap in Container: 0.5px black border, radius 20, vertical padding 15
- Month nav: bordered pill buttons (radius 7.5px, 0.5px border) instead of IconButtons
- Filter pill: bordered button matching same style
- Day cells: 23×23px, fully rounded (radius 100) instead of 32×32 with 8px radius
- Day headers: M T W T F S S, gap 22px, 12px font
- Disabled days (outside month): rgba(0,0,0,0.2) text color

### MonthlySnapshot
- Each stat in a bordered box (0.5px black border, flex 1) instead of plain text
- Label "Spent" → "Spent (฿)" per Figma
- Values: 18px Medium, labels: 12px Regular

### RecapCards
- Section header "Recap" (was no header)
- Bordered cards (0.5px black, radius 20) instead of shadow cards
- Keep existing icons (Figma has image placeholders, no real images to use)

### RecentEntries
- Section header: "Recent" + "View All" link (10px, textFaded color)
- Meal cards: 90×90 photo (radius 10 left corners), 0.5px black border, no shadow
- Tags: pill-shaped (radius 100) with bg colors:
  - Price tag: `tagGreen` bg
  - Healthy tag: `tagGreen` bg
  - Neutral tag: `tagYellow` bg
- Pin icon before restaurant name
- Bookmark icon in top-right corner (absolute positioned)

### EmotionFilters
- Keep as-is (matches Figma already)

## What Stays the Same
- All data providers, models, business logic
- Screen structure (SingleChildScrollView + Column)
- Navigation, routing
- MainShell / bottom nav

## Verification
- `flutter analyze` passes with no errors
- Home screen renders without layout errors
- All existing functionality intact (calendar tap, notification tap, meal detail, bookmark)

## Home Screen — Functional Gaps Found & Fixed

### 1. "View All" link not clickable
- **Was:** Static text, no tap handler
- **Fixed:** GestureDetector navigates to GalleryScreen

### 2. Bookmark icon opens meal detail instead of bookmark action
- **Was:** Static icon, whole card tap opens MealDetailSheet
- **Fixed:** Bookmark icon is now a separate GestureDetector that calls `MealDetailSheet.showCollectionSelector()` — opens the collection selector bottom sheet directly
- **Added:** New public static method `MealDetailSheet.showCollectionSelector(context, ref, mealId)` extracted from the private `_showCollectionSelector` state method

### 3. RecapCards not tappable
- **Was:** Static containers, no tap handler
- **Fixed:** GestureDetector shows "Recap coming soon!" snackbar (no recap screen exists yet)

---

## Gallery Screen (Page-Gallery-1, node `98:8683`)
*Status: Pending Figma pull*

## Friends Screen (Page-Friend-1, node `98:8553`)
*Status: Pending Figma pull*

## Profile Screen (Page-Profile-1, node `98:8881`)
*Status: Pending Figma pull*

## Notifications Screen (node `98:5993` — frame 3-1)
*Status: Pending Figma pull*
