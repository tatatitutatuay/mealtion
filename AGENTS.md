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

## 6. Supabase

- **Project URL**: `https://ssiaxokyvoqxroaavurx.supabase.co`
- **Dashboard**: https://supabase.com/dashboard/project/ssiaxokyvoqxroaavurx
- **SQL Editor**: Dashboard → SQL Editor (run schema/RLS changes here)
- **Storage bucket**: `meal-photos` (public, owner-only upload/delete via RLS)
- **Migrations**: `supabase/migrations/001_schema.sql` (schema + bucket), `002_rls.sql` (RLS policies)
- **Key gotcha**: Kotlin incremental compilation must be disabled (`kotlin.incremental=false` in `gradle.properties`) because pub cache (C:) and project (D:) are on different drives
- **Profile auto-creation**: `authInitProvider` upserts a profile row on auth state change (no DB trigger needed)
- **Photo URLs**: `meal_photos.storage_path` stores the full public URL from `getPublicUrl()`, not the raw storage path
