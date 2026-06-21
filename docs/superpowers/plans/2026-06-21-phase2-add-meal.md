# Phase 2: Add Meal Implementation Plan

**STATUS: 📝 Planned**

**Goal:** Users can create, save as draft, and publish meals with photos, foods, source, price, heaviness, feeling, tags, notes, and privacy toggle.

**Architecture:** Flutter → Supabase Data API (meals table) + Storage (photos) + Isar (drafts).

---

### Task 1: Add Meal data models

**Files:**
- Create: `app/lib/features/add_meal/models/add_meal_state.dart`
- Create: `app/lib/features/add_meal/models/meal_draft.dart`

- [ ] Create `AddMealState` — form state with all fields (photos, date, time, foods, source, restaurant, branch, price, heaviness, feeling, tags, note, isPrivate)
- [ ] Create `MealDraft` class for local Isar storage
- [ ] Create `Restaurant` and `Branch` models

### Task 2: Create Supabase meal API

**Files:**
- Create: `app/lib/features/add_meal/providers/meal_api_provider.dart`

- [ ] Create functions: createMeal, updateMeal, deleteMeal, uploadPhotos
- [ ] Use `supabase.from('meals').insert()` and `supabase.storage.from('meal-photos').upload()`

### Task 3: Add Meal form screen

**Files:**
- Create: `app/lib/features/add_meal/screens/add_meal_sheet.dart`
- Create: `app/lib/features/add_meal/widgets/photo_picker.dart`
- Create: `app/lib/features/add_meal/widgets/food_chips.dart`
- Create: `app/lib/features/add_meal/widgets/source_selector.dart`
- Create: `app/lib/features/add_meal/widgets/price_input.dart`
- Create: `app/lib/features/add_meal/widgets/heaviness_feeling_selector.dart`
- Create: `app/lib/features/add_meal/widgets/restaurant_search.dart`
- Create: `app/lib/features/add_meal/widgets/tag_input.dart`
- Create: `app/lib/features/add_meal/providers/add_meal_provider.dart`

- [ ] Build bottom sheet with all required fields
- [ ] Photo picker (camera + library, 1-10, reorderable)
- [ ] Meal names as editable chips
- [ ] Source selector (Restaurant/Delivery/Home)
- [ ] Restaurant search + create
- [ ] Branch search + create
- [ ] Tag input (search existing, create new)
- [ ] Price input + hidden level calculation
- [ ] Heaviness selector (Light/Satisfying/Heavy)
- [ ] Feeling selector (Like/Neutral/Dislike)
- [ ] Note text field
- [ ] Private meal toggle

### Task 4: Draft Meals system

- [ ] Add `isar` and `isar_generator` to pubspec
- [ ] Create Draft model for Isar
- [ ] Save incomplete meal as draft on close
- [ ] Draft list screen (grid, 3 columns)
- [ ] Multi-select delete

### Task 5: Meal publish

- [ ] Validation (1+ photo, 1+ food name, valid date/time, source required)
- [ ] Publish to Supabase
- [ ] Offline auto-save as draft
- [ ] Success: navigate to home/calendar

### Task 6: Integrate bottom nav and route for Add Meal

- [ ] Add Add Meal as center action in bottom nav
- [ ] Opens as bottom sheet from any screen

---

## Spec Sections Covered

- **7.1** Add Meal Header: title, close, draft button
- **7.2** Meal Photos: 1-10, camera/library, reorder, cover
- **7.3** Date and Time: from photo metadata, editable, no future
- **7.4** Meal Names: chips, add/edit/remove, min 1
- **7.5** Source: Restaurant/Delivery/Home
- **7.6** Restaurant and Branch: search, create
- **7.7** Tags: search, create, unique per meal
- **7.8** Price: total per meal, auto-calculate level
- **7.9** Heaviness: optional single
- **7.10** Feeling: optional single
- **7.11** Note: optional plain text
- **7.12** Private Meal: toggle, default off
- **7.13** Publishing: validation, online/offline handling
- **7.14** Closing: discard/draft/cancel confirmation
- **8** Draft Meals: grid, multi-select delete
- **9** Edit and Delete
