## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Build & Verify Commands

Flutter is at `D:\flutter\bin`. Android SDK at `C:\Users\aitsa\AppData\Local\Android\Sdk`. Always prepend to PATH:
```powershell
$env:Path = "D:\flutter\bin;C:\Program Files\Android\Android Studio\jbr\bin;C:\Users\aitsa\AppData\Local\Android\Sdk\platform-tools;C:\Users\aitsa\AppData\Local\Android\Sdk\emulator;C:\Users\aitsa\AppData\Local\Android\Sdk\cmdline-tools\latest\bin;$env:Path"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_HOME = "C:\Users\aitsa\AppData\Local\Android\Sdk"
```

- **Analyze**: `flutter analyze` (from `app/` directory)
- **Run on Android emulator**: `flutter emulators --launch MealtionPixel` then `flutter run`
- **Run on Chrome**: `flutter run -d chrome`
- **Build web**: `flutter build web --debug`
- **Emulator**: `MealtionPixel` (Pixel 7, Android API 36, google_apis x86_64)

### macOS / iOS

Flutter installed via Homebrew (`/opt/homebrew/bin/flutter`, 3.44.4 stable). CocoaPods via Homebrew (1.16.2). Xcode 26.6. iOS project uses **Swift Package Manager** (not CocoaPods) — no Podfile needed.

- **Analyze**: `flutter analyze` (from `app/` directory)
- **Run on iOS simulator**:
  ```bash
  cd app
  xcrun simctl boot "iPhone 17" 2>/dev/null; open -a Simulator
  flutter run
  ```
  `flutter run` auto-detects the booted simulator. If none is booted, it prompts to pick one.
- **Simulator**: iPhone 17 (iOS 26.5, build 23F77). Device UDID: `B71ADFAD-F7A3-4B55-9C45-58E6D154422A`
- **Build iOS**: `flutter build ios --debug` (from `app/`)
- **One-time setup notes** (already done on this machine):
  - Accept Xcode license: `sudo xcodebuild -license accept`
  - Install iOS simulator runtime: `xcodebuild -downloadPlatform iOS` (downloads ~8.5 GB)
  - `app/.env` must exist with `SUPABASE_URL` + `SUPABASE_ANON_KEY` (gitignored, not in repo)
  - `ios/Runner/Info.plist` has `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription` (required for `image_picker`)

## 5b. SonarCloud (Code Quality)

- **Dashboard**: https://sonarcloud.io/project/overview?id=tatatitutatuay_mealtion
- **Config**: `sonar-project.properties` at repo root (organization: `tatatitutatuay`, projectKey: `tatatitutatuay_mealtion`)
- **CI**: `.github/workflows/sonarcloud.yml` runs on push/PR to master. Needs `SONAR_TOKEN` secret in GitHub repo settings.
- **Local scan**: `.\scripts\sonar-scan.ps1` (requires sonar-scanner in PATH + `$env:SONAR_TOKEN` set)
- **Setup steps** (one-time):
  1. Go to https://sonarcloud.io → Log in with GitHub
  2. Import the `tatatitutatuay/mealtion` repo
  3. Generate a token at My Account → Security
  4. Add `SONAR_TOKEN` as a secret in GitHub repo → Settings → Secrets and variables → Actions
- **Language**: Dart (SonarCloud has native Dart support — code smells, bugs, security hotspots, duplication)

## 6. Supabase

- **Project URL**: `https://ssiaxokyvoqxroaavurx.supabase.co`
- **Dashboard**: https://supabase.com/dashboard/project/ssiaxokyvoqxroaavurx
- **SQL Editor**: Dashboard → SQL Editor (run schema/RLS changes here)
- **Storage buckets**: `meal-photos` (public, owner-only upload/delete via RLS), `avatars` (public, owner-only upload/delete via RLS)
- **Migrations**: `supabase/migrations/001_schema.sql` (schema + bucket), `002_rls.sql` (RLS policies), `003_avatars_bucket.sql` (avatars bucket + RLS)
- **Key gotcha**: Kotlin incremental compilation must be disabled (`kotlin.incremental=false` in `gradle.properties`) because pub cache (C:) and project (D:) are on different drives
- **Profile auto-creation**: `authInitProvider` upserts a profile row on auth state change (no DB trigger needed)
- **Photo URLs**: `meal_photos.storage_path` stores the full public URL from `getPublicUrl()`, not the raw storage path

## 7. Feature Architecture

- **Onboarding**: 5-step flow in single `OnboardingScreen`. AuthGuard redirects to `/onboarding` if `profiles.onboarding_completed=false`. Router uses `_AuthRefreshListenable` to trigger redirect on auth state change.
- **Meal Detail**: `MealDetailSheet` — DraggableScrollableSheet with PageView photo carousel. Supports vertical swipe between meals (calendar mode via `mealIds` list). Bookmark + delete + edit actions in header. Shows price level badge (cheap/moderate/expensive) based on user thresholds.
- **Meal Edit**: `AddMealSheet` accepts optional `mealId`. When provided, loads meal from DB, downloads photos to temp files, pre-fills all fields. Save calls `updateMeal` instead of `createMeal`.
- **Notifications**: `notificationsProvider` fetches with actor join. `unreadNotificationCountProvider` wired to GreetingBar badge. Tap marks as read + opens meal detail if `meal_id` present.
- **Friend Requests**: `FriendRequestsScreen` with Received/Sent tabs. `acceptFriendRequest` creates reciprocal row. `cancelSentRequest` deletes pending row. Unread badge on mail icon in FriendsScreen.
- **Friend Profiles**: `FriendProfileScreen` uses `userProfileDataProvider` (parameterized) + `userGalleryProvider` (public meals only). Reuses gallery timeline/grid layout. Also used for "View Profile" on own profile.
- **Settings**: `SettingsScreen` — currency, price privacy, notification toggles, account deletion (cascades via profile delete), logout.
- **Bookmark Actions**: `BookmarkActions` provider (createCollection, renameCollection, deleteCollection, addMealToCollection, removeMealFromCollection). Collection selector bottom sheet in meal detail. Select mode in collections screen for batch delete + rename.
- **Profile Photo**: `EditProfileScreen` has tappable avatar with gallery/camera picker. Uploads to `avatars` bucket. Supports removing photo.
- **Restaurant Autocomplete**: `restaurantSearchProvider` + `branchSearchProvider` query DB for matches as user types (min 2 chars). Suggestion box shown below input.
- **Calendar Filters**: `CalendarWidget` filter chip cycles through Health/Heaviness/Feeling/Price modes. Dots colored accordingly (green/orange/red).
- **Draft Meals**: `draftProvider` saves drafts to `shared_preferences`. Resume via edit-note button in AddMealSheet header. Photos not persisted (paths only).
- **Tag Autocomplete**: `tagSuggestionsProvider` queries `meal_tags` table. ActionChips shown below tag input.
- **Price Level**: `PriceLevel` utility (`core/utils/price_level.dart`) calculates cheap/moderate/expensive from user's onboarding thresholds. Shown as colored badge in meal detail.

## 8. Known Gaps (Post-Implementation)

All critical and high-priority gaps from the original audit are now implemented. Remaining minor items:
- **Recent entries price level**: Recent meal cards show price but not the level badge (would require converting to ConsumerWidget) — *fixed: RecentEntries now shows price level badge*
- **Onboarding debug prints**: Debug prints still in `onboarding_screen.dart` `_finish()` method — should be removed after confirming redirect works — *fixed: debug prints removed*
