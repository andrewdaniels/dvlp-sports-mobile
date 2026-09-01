# DVLP Sports — Mobile Development Rules

Read this before writing any Flutter code in this repo. These rules are load-bearing — they exist because we've felt the pain of not having them.

## The three-layer separation (non-negotiable)

Every piece of code lives in exactly one layer. Never mix them.

### 1. Repository layer (`lib/features/<feature>/data/`)
- Talks to backend (Supabase) and/or local storage. Nothing else.
- Returns domain models (Dart classes), not raw JSON or `PostgrestResponse`.
- Knows nothing about Riverpod, `WidgetRef`, `BuildContext`, or UI.
- Naming: `AthleteRepository`, `AssessmentRepository`, `AuthRepository`.
- One repository per bounded domain. Not one per screen.

### 2. Controller layer (`lib/features/<feature>/controllers/` or `providers/`)
- Riverpod notifiers/providers. Business logic + state.
- Calls repositories, transforms data, exposes `AsyncValue<T>` (or plain `T`) to the UI.
- Naming: `AthleteProfileController`, `assessmentListProvider`.
- Prefer `AsyncNotifier` / `AsyncNotifierProvider` for anything that fetches or mutates async data.
- Use `riverpod_annotation` + code generation (`@riverpod`) for consistency.

### 3. UI layer (`lib/features/<feature>/ui/` or just page files)
- Widgets only. Consumes providers via `ref.watch` / `ref.read`.
- **Never** calls repositories directly. **Never** contains business logic.
- Build methods are pure — describe what to render based on current state.
- Side effects (mutations, navigation triggered by data changes) go through `ref.listen` in `HookConsumerWidget` or `ConsumerWidget`.

### Violation examples (do not do)

```dart
// ❌ UI calling repository directly
class PassportPage extends ConsumerWidget {
  Widget build(context, ref) {
    final athlete = ref.read(supabaseServiceProvider).from('profiles')...; // NO
  }
}

// ❌ Business logic in build
class ScoreBadge extends StatelessWidget {
  Widget build(context) {
    final band = score < 3 ? 'beginner' : score < 8 ? 'bronze' : ...; // NO — belongs in controller
  }
}

// ❌ Repository returning raw JSON
class AthleteRepository {
  Future<Map<String, dynamic>> getAthlete(String id) async { ... } // NO — return AthleteProfile model
}
```

## Folder structure

```
lib/
  main.dart
  app.dart

  core/                        # cross-cutting infrastructure
    theme/  routing/  env/  services/  providers/
    domain/                    # (later) shared enums / base types used across features

  screens/                     # routable pages — one file per destination
    shell/app_shell.dart       # bottom nav shell
    passport/passport_page.dart
    dvlp/dvlp_page.dart
    team/team_page.dart
    profile/profile_page.dart
    dev/                       # debug-only screens (design system, components ref)

  features/                    # DOMAIN features
    <feature>/                 # e.g. assessments, teams, invites, auth
      data/                    # repositories + models
        <feature>_repository.dart
        <feature>_models.dart
      controllers/             # Riverpod providers / notifiers
        <feature>_controller.dart
      ui/widgets/              # feature-specific widgets (composed by screens)

  shared/                      # cross-cutting UI primitives — no domain knowledge
    widgets/                   # AppButton, AppCard, AppAvatar, etc.
    hooks/                     # (later) custom Flutter hooks
    utils/                     # (later) pure functions
```

### The distinction

- **`screens/`** = routable destinations. Each file is a page in the router. Composes from features/ and shared/.
- **`features/`** = domain areas. Contains data layer, controllers, and feature-specific widgets. Screens compose from features.
- **`shared/`** = truly cross-cutting UI primitives with no domain knowledge (buttons, cards, avatars, badges).

### Where does a widget go?

- Used by only one feature → `features/<feature>/ui/widgets/`
- Used by multiple features → `shared/widgets/` (with display-oriented primitive props, not domain models)
- Used only by a specific screen → `screens/<screen>/widgets/` (rare — usually promote to a feature)

If in doubt, start in the feature folder. Moving to shared/ when a second feature needs it is cheap.

## Shared widget rules

### Before creating a new widget, audit existing ones

1. Does a widget in `shared/widgets/` already do this?
2. Can an existing widget be extended (new prop, variant enum, composable child) instead of duplicating?
3. Is what you're about to write feature-specific or genuinely shared? Put it in `features/<feature>/ui/widgets/` unless it's used elsewhere.

### Hoisting to shared

When the same widget shows up in 2+ features:
1. Move it to `lib/shared/widgets/`
2. Rename if the original name was feature-specific
3. Update imports
4. Note it in a code comment: `// hoisted from <feature> — used by X, Y`

### Naming shared widgets

Prefix with `App` for clarity: `AppButton`, `AppTextField`, `AppBadge`, `AppBottomNav`. This makes them scannable and distinguishes them from Material widgets.

## Design system usage

### Always via tokens

**Never hardcode:**
- Colors → `context.colors.primary`, never `Color(0xFF0C3260)`
- Text styles → `AppTypography.bodyMedium`, never `TextStyle(fontSize: 14, ...)`
- Spacing → `AppSpacing.md`, never `16` (unless it's genuinely one-off arbitrary)
- Radius → `AppRadius.sm`, never `4`
- Sizes → `AppSizes.medium`, never `48`

### Extending the design system

If you need a value not in the tokens:
1. Check the Figma design first — often the value IS in the design system, you just haven't imported it (or you're looking at the wrong layer)
2. If it maps to an existing token you'd forgotten, use the token (e.g., `#9F7200` is `tertiary` — don't hardcode)
3. If it's genuinely needed and reusable across ≥2 surfaces, add to the appropriate token file (`app_colors.dart`, `app_spacing.dart`, etc.), then use it via the token
4. If it's truly one-off (single widget uses it, doesn't fit any semantic bucket), keep it local — see rules below

### One-off exceptions — the strict version

You may hardcode a value ONLY when both of these are true:
- The value doesn't map to any existing token (checked all of `app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_sizes.dart`)
- The value is used in exactly one widget and doesn't semantically belong in the design system (e.g., a composite gradient made of two tokens, a bespoke shader value, a specific animation timing)

**Every one-off must:**
1. Live in a shared widget (`lib/shared/widgets/`) or a well-scoped feature widget — never in an ad-hoc page
2. Have a `// one-off:` prefix comment stating WHY it can't be a token and the trigger condition for hoisting

Example (good):
```dart
// one-off: composite gradient of two tokens (tertiary → secondary).
// Individual colors ARE tokens; the composite is what's local.
// Hoist to AppGradients if used by any other surface.
gradient: LinearGradient(
  colors: [colors.tertiary, colors.secondary],
  ...
),
```

Example (BAD — this fails audit):
```dart
color: Color(0xFF0C3260), // this is `primary` — use context.colors.primary
padding: EdgeInsets.all(16), // this is AppSpacing.md
borderRadius: BorderRadius.circular(20), // this is AppRadius.xxl
```

### Auditing

Before merging any widget with hardcoded values, run through:
1. Does this exact value exist in tokens? → Use the token
2. Is this value used anywhere else? → Hoist to tokens
3. Is this a composite of tokens? → Compose from tokens (don't hardcode the composite parts even if the composite itself is local)
4. Does it have a `// one-off:` comment explaining why? → Required for any surviving hardcoded value

Log significant hardcoded exceptions in `../design-decisions.md` so future contributors can find them.

### Theme extensions

Access colors via `context.colors.foo` (extension on `BuildContext`) — cleaner than `Theme.of(context).extension<AppColors>()!.foo`.

### One import for all tokens

Always use the barrel: `import '../../core/theme/theme.dart';` — one line gives you `AppColors` (+ `context.colors` extension), `AppTypography`, `AppSpacing`, `AppRadius`, `AppSizes`, `AppGradients`, and `AppTheme`. Do not import individual token files in feature code.

## State management (Riverpod)

- Use `hooks_riverpod` + `flutter_hooks`. `HookConsumerWidget` is the default.
- Prefer `@riverpod` codegen over manual `Provider(...)` — less boilerplate, better types.
- `AsyncNotifierProvider` for anything with loading/error states (which is almost everything with a repository).
- Providers live in the feature's `controllers/` folder. Global-ish providers (auth state, current user) live in `core/providers/`.
- Never call `ref.read` from `build` — use `ref.watch`. `ref.read` is for callbacks/event handlers.

## Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (Dart convention, not `SCREAMING_CASE`)
- Providers: `camelCase` ending in `Provider` (e.g., `currentUserProvider`)
- Repositories: `<Domain>Repository`
- Controllers/notifiers: `<Domain>Controller` or `<Domain>Notifier`
- Pages: `<Name>Page`
- Shared widgets: `App<Name>`

## Anti-patterns to avoid

- **Passing `BuildContext` to non-UI code.** Context belongs in widgets.
- **Global mutable state.** Everything goes through Riverpod.
- **Business logic in `build`.** Compute in controllers, render in widgets.
- **`StatefulWidget` for anything Riverpod can handle.** Use `HookConsumerWidget` + `useState` / providers.
- **Silent catch-all exception handling.** Errors surface as `AsyncError` — let the UI decide how to render.
- **Hardcoded strings for enum-like values.** Use TypeScript-style constants (`const status = 'submitted'` → prefer a Dart enum).
- **Direct navigation with `Navigator.push`.** Use `context.go` / `context.push` from go_router (typed via `RouteNames`).

## Haptic feedback

**Every interactive tap in the app gets haptic feedback.** No silent taps. This is a first-class UX rule.

Intensity picked based on the *priority* of the action:

| Intensity | Use for | Flutter call |
|---|---|---|
| **Light** | Navigation, subtle acknowledgment, tab switches, checkbox/toggle, secondary actions | `HapticFeedback.lightImpact()` |
| **Medium** | Standard primary buttons, submitting a request, confirming a selection, tapping a card that leads to a screen | `HapticFeedback.mediumImpact()` |
| **Heavy** | Significant / committed actions (submit assessment, complete formal, delete, sign out, destructive confirmations) | `HapticFeedback.heavyImpact()` |

Also worth knowing:
- `HapticFeedback.selectionClick()` — subtle "tick" for scrolling through options (like picker/wheel). Use for continuous selection UIs (sliders picking value, ruler picker) but not for one-shot taps.
- `HapticFeedback.vibrate()` — long buzz. Reserve for critical alerts/errors only.

Import: `import 'package:flutter/services.dart';`

Rule of thumb for choosing intensity when adding a new interaction: **ask "what's the consequence?"** — the more real-world weight the action has (money, data, submitting to the backend, navigating away from work), the heavier the haptic. Tab switches and filter toggles are light. Signing out is heavy.

## Icons

- **Source**: Untitled UI Icons (free, 1173 SVG set from `github.com/untitleduico/icons`). Same library the Figma designs use. License at `assets/icons/untitled/LICENSE`.
- **Storage**: Full library bundled at `assets/icons/untitled/<name>.svg`. No need to fetch anything at runtime.
- **Rendering**: use `AppIcon` from `lib/shared/widgets/app_icon.dart`. Never use raw `SvgPicture.asset` in feature code — always through `AppIcon` so we get consistent sizing and color handling.
- **Registration**: add a constant to `AppIcons` in `app_icon.dart` for every icon we ship. Feature code references `AppIcons.navPassport`, never raw asset paths — one place to audit + rename.
- **Adding a new icon**:
  1. Find its Untitled UI name via Figma (icon layer name) or browse `untitledui.com/free-icons`
  2. Verify the SVG exists at `assets/icons/untitled/<name>.svg` (it should — we have the full free set)
  3. Add a `static const String` to `AppIcons`
  4. Use `AppIcon(AppIcons.yourNewIcon, size: 24, color: ...)` in widgets
- **Tinting**: `AppIcon` uses `ColorFilter.mode(color, BlendMode.srcIn)` — works for solid-fill Untitled UI icons. For icons that need multi-color or gradient fills, we'll add a variant then.
- **Bundle size**: ~4.6MB for all 1173 icons. Non-issue vs typical Flutter binary. If we ever want to trim: run a build script that copies only referenced SVGs to a slim folder.

## Backend and data contracts

- Supabase types are generated (later — via `supabase gen types`) into `lib/core/gen/` and imported by repositories.
- Repositories map generated types → domain models. UI never sees `PostgrestResponse` or generated types.
- Enums from the DB (e.g., `assessment_type`, `coach_type`) become Dart enums in `lib/core/domain/enums.dart`. Keep the values in sync with the DB.

## When adding a new feature

1. Create `lib/features/<feature>/` with `data/`, `controllers/`, `ui/` subfolders.
2. Write the repository first (data shape lives here).
3. Write the controller(s) next (state + business logic).
4. Write the UI last, consuming controllers.
5. If any widget in the UI could reasonably be reused, promote it to `shared/widgets/` and update this pattern.

## When touching an existing feature

1. Read the feature's existing structure — don't invent parallel patterns.
2. If you find a violation of these rules in existing code, either fix it as part of your work OR log it in a code comment `// TODO(agents-md): violates layer separation, refactor when touching X`.

---

## Meta

- These rules apply to code in `mobile/` only. `backend/` and `web/` will have their own `AGENTS.md` when we scaffold them.
- Design token source of truth: `../design-tokens.json` and `../design-system.md` (project root).
- Schema source of truth: `../schema-plan.md` (project root).
- Product decisions & compromises: `../design-decisions.md` (project root).

Update this file whenever we lock in a new convention or catch a recurring anti-pattern.
