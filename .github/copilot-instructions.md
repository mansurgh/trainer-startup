# Trainer App - AI Fitness Coach

## Project Overview
Flutter 3.16+ cross-platform AI fitness app with Supabase backend and OpenAI GPT-4o integration. Russian-first UI with English localization support.

**Package name**: `pulsefit_pro` (Trainer branding, internal package name retained for import stability)

## Architecture

### State Management (Riverpod)
- **Providers**: `lib/providers/` — `StateNotifier<T>` pattern for reactive state
- **State objects**: `lib/state/` — immutable state containers with `copyWith()`
- **Key pattern**: `ProfileNotifier` in [profile_provider.dart](lib/providers/profile_provider.dart) exemplifies auth-synced state

```dart
// Provider pattern example
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) => ...);
```

### Data Layer
- **Services** (`lib/services/`): Business logic, API calls, local storage
- **Repositories** (`lib/repositories/`): Supabase data access with retry logic and caching
- **Models** (`lib/models/`): Immutable data classes with `toJson()`/`fromJson()`

### Auth Flow
`AuthService` (singleton) → listens to `onAuthStateChange` → loads/clears profile via `UserRepository`
- Credentials stored in `secrets.json` (bundled asset, gitignored in production)
- Token storage via `flutter_secure_storage`

## Design System — "Noir Glass" (Strict Monochrome)

### Theme Files
- [noir_theme.dart](lib/theme/noir_theme.dart) — color palette, spacing constants (`kSpace*`, `kRadius*`)
- [design_tokens.dart](lib/core/design_tokens.dart) — "Liquid Glass" gradients and typography
- [noir_glass_components.dart](lib/widgets/noir_glass_components.dart) — reusable glass containers

### Typography (Manrope)
All typography uses **Manrope** font via `google_fonts` package:
```dart
// Theme applies Manrope globally
GoogleFonts.manropeTextTheme(base.textTheme)

// Text styles (letter-spacing ≥ 0, no negative values)
kNoirDisplayGiant  // 72px, w800
kNoirTitleLarge    // 28px, w700
kNoirBodyMedium    // 14px, w400
kNoirCaption       // 12px, w400
```

### Color Conventions
```dart
// Surface hierarchy (luminance-based, NO color hues)
kNoirBlack → kNoirCarbon → kNoirGraphite → kNoirSteel
// Content hierarchy
kContentHigh (white) → kContentMedium → kContentLow
// Exception: Trend indicators only
const Color(0xFF4ADE80)  // Green — positive trend
const Color(0xFFF87171)  // Red — negative trend
```

### UI Components
Always use `NoirGlassContainer` instead of raw `Container`/`Card`. Use `BackdropFilter` for glass effects.

**Key Components:**
- `NoirGlassContainer` — Base glass panel with blur
- `NoirPrimaryButton` — Solid white button, black text
- `NoirSecondaryButton` — Outline button
- `NoirWeightPicker` — iOS drum picker with trend arrows
- `NoirToast` — Toast notifications (`NoirToast.success()`, `NoirToast.error()`)

### Navigation System
- **Provider**: `navigationProvider` in [navigation_provider.dart](lib/providers/navigation_provider.dart) — Riverpod `StateNotifier` for tab index
- **FloatingNavBar**: [floating_nav_bar.dart](lib/widgets/navigation/floating_nav_bar.dart) — Glassmorphism oval bar
- **NoirGlassScaffold**: [noir_glass_scaffold.dart](lib/widgets/navigation/noir_glass_scaffold.dart) — Wrapper scaffold with `extendBody: true`

```dart
// Use NoirGlassTabScaffold for tabbed screens
const NoirGlassTabScaffold(tabs: [WorkoutScreen(), NutritionScreen(), ProfileScreen()])

// Add SliverNavBarSpacer at end of CustomScrollView to prevent content hiding
const SliverNavBarSpacer()

// Or use extension for regular ScrollView padding
SizedBox(height: NoirGlassScrollPadding.navBarPadding(context).bottom)
```

## Key Commands

```bash
# Development
flutter pub get
flutter run -d windows --dart-define-from-file=secrets.json

# Build release (uses scripts/build_release.ps1)
flutter build apk --release
flutter build windows --release

# Tests
flutter test
flutter analyze
```

## Database (Supabase)
- Schema: [supabase_complete_schema.sql](supabase_complete_schema.sql) — run in SQL Editor
- All tables have RLS enabled; policies enforce `auth.uid() = user_id`
- Tables: `profiles`, `workout_sessions`, `exercise_logs`, `meal_logs`, `nutrition_entries`

## File Conventions

| Directory | Purpose | Example |
|-----------|---------|---------|
| `lib/screens/` | Full-page widgets | `home_screen.dart`, `profile_screen.dart` |
| `lib/screens/tabs/` | Tab content | `nutrition_screen_v2.dart` |
| `lib/widgets/` | Reusable components | `noir_glass_components.dart` |
| `lib/widgets/muscle_heatmap/` | Muscle visualization | `muscle_heatmap_widget.dart` |
| `lib/services/` | Business logic | `ai_service.dart`, `auth_service.dart`, `translation_service.dart` |
| `lib/state/` | State containers | `user_state.dart`, `meal_schedule_state.dart` |
| `lib/models/` | Data classes | `form_check_result.dart`, `user_model.dart` |

## Muscle Heatmap System
- **Widget**: `MuscleHeatmapWidget` in [muscle_heatmap_widget.dart](lib/widgets/muscle_heatmap/muscle_heatmap_widget.dart)
- **Provider**: `muscleFatigueProvider` in [muscle_fatigue_provider.dart](lib/providers/muscle_fatigue_provider.dart)
- **Strict Monochrome**: Fatigue 0.0 = transparent, 1.0 = white opacity (NO colors)
- **SVG Assets**: `assets/muscles/` (male) and `assets/muscles/female/`

```dart
// Usage example
MuscleHeatmapWidget(
  fatigueMap: {MuscleId.chest: 0.7, MuscleId.abs: 0.3},
  gender: BodyGender.male,
  onMuscleTap: (muscle) => showMuscleDetailSheet(context, muscle: muscle),
)
```

## AI Integration
- `AIService` in [ai_service.dart](lib/services/ai_service.dart) wraps OpenAI API
- Falls back to mock responses when `OPENAI_API_KEY` is missing or `demo-key`
- Supports image analysis (food recognition, form check)

### AI Form Check System
Video-based exercise technique analysis:
- **Camera Screen**: [form_check_camera_screen.dart](lib/screens/form_check_camera_screen.dart) — 3/5/10s countdown, 15s max recording, front/back toggle
- **Feedback Screen**: [form_feedback_screen.dart](lib/screens/form_feedback_screen.dart) — Score card, errors (orange), corrections (green), YouTube button
- **Model**: [form_check_result.dart](lib/models/form_check_result.dart) — `FormCheckResult.mock()` for demo mode
- **Entry Points**: 
  - [workout_screen.dart](lib/screens/workout_screen.dart) — "Check Form" button
  - [workout_screen_improved.dart](lib/screens/workout_screen_improved.dart) — "Check Form" button

```dart
// Navigate to form check (both screens use this pattern)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => FormCheckCameraScreen(
    exerciseName: TranslationService.translateExercise(exerciseName, context),
    exerciseId: exercise.id,
  ),
));
```

## Weight Picker with Trend Arrows
iOS-style drum picker showing progress direction:
- **Widget**: [noir_weight_picker.dart](lib/widgets/noir_weight_picker.dart)
- **Trend Logic**: Compares current vs previous weight relative to goal
- **Visual**: Green arrow (towards goal), Red arrow (away from goal)

### Profile Weight Card
- **Location**: `_QuickStatCard` in [profile_screen.dart](lib/screens/profile_screen.dart)
- **Trend Display**: `+X.X` / `-X.X` with colored icon when data exists, `—` (gray, no icon) when no history
- **Data Source**: `StatsService.getWeightChange()` from `body_measurements` table

```dart
// Show weight picker with trend
final newWeight = await NoirWeightPicker.show(
  context,
  initialWeightKg: currentWeight,
  previousWeightKg: lastWeight,
  targetWeightKg: goalWeight,
  goal: 'lose_weight', // or 'gain_muscle', 'maintain'
);
```

## Unit System
- **Provider**: `unitSystemProvider` in [unit_system_provider.dart](lib/providers/unit_system_provider.dart)
- **Conversion**: `UnitConverter.convertWeightFromMetric()`, `UnitConverter.weightUnit()`
- **Storage**: All weights stored in kg (metric), displayed in user's preferred unit

## Workout Schedule System
- **Screen**: [workout_schedule_screen.dart](lib/screens/workout_schedule/workout_schedule_screen.dart)
- **Day Selector**: [day_selector.dart](lib/screens/workout_schedule/widgets/day_selector.dart) — week calendar with golden checkmarks
- **Completion Logic**: `_loadCompletedDays()` checks both:
  - Local SharedPreferences flags (`workout_completed_{userId}_{date}`)
  - `StorageService.getWorkoutSessions()` with `completed == 1`
- **Visual**: Golden checkmark (✓) on any day with completed workout

## RPG Stats (Gamification)
- **Provider**: `statsProvider` in [stats_provider.dart](lib/providers/stats_provider.dart)
- **Service**: [stats_service.dart](lib/services/stats_service.dart) — `getCharacteristics()`
- **Formula**: 
  - Discipline = streak_days / 10
  - Strength = total_workouts * 0.1
  - All stats start at 0 for new users

## Localization
- Config: `l10n.yaml`, translations in `lib/l10n/`
- **STRICT RULE**: All UI text must use `AppLocalizations.of(context)!`
- Access: `final l10n = AppLocalizations.of(context)!;` then `l10n.someKey`
- Primary: Russian (`ru`), secondary: English (`en`)
- Auto-detection: RU/BY/KZ/UA regions → Russian, others → English
- Use `ref.watch(isRussianProvider)` for locale-specific formatting

### TranslationService (Database Strings)
- **Service**: [translation_service.dart](lib/services/translation_service.dart) — client-side dictionary
- **Purpose**: Translate English DB values (exercises, days, meal types) to localized UI
- **Usage**:
```dart
TranslationService.translateExercise('bench press', context) // → 'Жим лёжа'
TranslationService.translateDayLong('Monday', context)        // → 'Понедельник'
TranslationService.translate(anyDbString, context)            // Universal
```

```dart
// CORRECT — Always use AppLocalizations
Text(l10n.welcome)
Text(l10n.tellUsAboutYourself)

// WRONG — Never hardcode strings or use inline checks
Text(isRussian ? 'Привет' : 'Hello')  // ❌ BAD
Text('Hello')                          // ❌ BAD
```

## Toast Notifications
Use `NoirToast` for all user feedback:

```dart
// Success notification
NoirToast.success(context, 'Профиль обновлён');

// Error notification
NoirToast.error(context, 'Не удалось сохранить');

// Info notification
NoirToast.info(context, 'Новая тренировка доступна');
```

## Critical Patterns

1. **Singleton services**: `AuthService`, `StorageService` use `factory` constructor
2. **Error handling**: `ErrorService.logError()` for consistent logging
3. **Offline-first**: `UserRepository` returns cached data immediately, fetches fresh in background
4. **Animation**: Use `flutter_animate` extension methods (`.animate().fadeIn()`)
5. **Haptics**: Use `HapticFeedback.lightImpact()` for user interactions

## Key Dependencies
```yaml
flutter_riverpod: ^2.5.1    # State management
supabase_flutter: ^2.8.0    # Backend
camera: ^0.11.0+2           # Video recording
video_player: ^2.8.6        # Video playback
url_launcher: ^6.2.2        # External links
flutter_animate: ^4.5.0     # Animations
permission_handler: ^11.3.1 # Runtime permissions
```

## Environment Setup
Create `secrets.json` in project root:
```json
{
  "SUPABASE_URL": "https://xxx.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key",
  "OPENAI_API_KEY": "sk-..."
}
```
