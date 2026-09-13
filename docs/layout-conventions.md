# Page & Sheet Layout Conventions

Consolidated rules for structuring pages, sheets, and the shared widgets that support them (`AppScreenFooter`, `AppSheetLayout`, `AppDetailAppBar`, `KeyboardDismissible`). Follow these to avoid the padding, keyboard, and safe-area foot-guns we've re-learned a few times.

## 1. Standard page structure

Any page with a fixed-bottom CTA and scrollable content:

```dart
Scaffold(
  appBar: AppDetailAppBar(title: 'Page Title'),  // or AppBar for main-nav pages
  body: SafeArea(
    bottom: false,                                // footer owns bottom SafeArea
    child: KeyboardDismissible(                   // if the page has any inputs
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: AppPageInsets.padding,     // vertical + horizontal
              children: [ ...content ],
            ),
          ),
          AppScreenFooter.single(primary: AppButton(...)),
        ],
      ),
    ),
  ),
)
```

**Rules:**
- Outer `SafeArea` handles the top inset (status bar / notch). Pass `bottom: false` — `AppScreenFooter` handles the bottom SafeArea itself.
- Footer sits as a **sibling** of the scrollable content inside a `Column`, not in `Scaffold.bottomNavigationBar` (which wraps its slot in a MediaQuery filter that blocks the footer's keyboard-visibility detection).
- Wrap the body in `KeyboardDismissible` whenever the page has text inputs — tap outside → keyboard dismisses.

## 2. Content padding

Two conventions in the codebase:

| Surface | Horizontal | Constant |
|---|---|---|
| Main-app pages (passport, team, feedback, coach games, etc.) | 16 | `AppPageInsets.horizontal` (aka `AppSpacing.md`) |
| Auth / onboarding pages | 32 | `AppSpacing.xl` |

Apply via the `ListView(padding: ...)` prop when content is scrollable, or `Padding(horizontal: X)` around a `Column` when it's a fixed layout.

## 3. `AppScreenFooter`

Owns four concerns so callers don't have to:

1. **CTA layout** — factories: `single`, `row`, `stacked`.
2. **Horizontal padding** — defaults to `AppPageInsets.horizontal`. Override via `horizontalPadding:` param (auth pages pass `AppSpacing.xl`).
3. **Bottom SafeArea** — always applied; nested SafeAreas are safe (Flutter consumes the outer, inner sees zero).
4. **Keyboard visibility** — footer collapses to zero height via `AnimatedSize` when the keyboard is up. Opt out with `hideOnKeyboard: false` if a screen needs the CTA visible during typing (e.g., a send-message composer).

**Placement rules:**
- Body Column sibling. Never `Scaffold.bottomNavigationBar` — Scaffold's slot wrapping blocks keyboard detection.
- Don't wrap it in extra `Padding` — it owns its own horizontal via the `horizontalPadding` prop.
- Don't wrap it in extra `SafeArea` — it owns its own bottom safe area.

**Keyboard detection under the hood:** uses `WidgetsBindingObserver.didChangeMetrics()` + `View.of(context).viewInsets` (raw engine insets). This bypasses Scaffold's `resizeToAvoidBottomInset` MediaQuery filter that would otherwise report the keyboard hidden.

## 4. Sheets

Use `AppSheetLayout` for any sheet opened via `showAppSheet`:

```dart
AppSheetLayout(
  title: 'Sheet Title',
  subtitle: 'Optional supporting copy',
  footer: AppScreenFooter.row(
    primary: AppButton(...),
    secondary: AppButton(...),
  ),
  child: Column(children: [ ...form fields ]),
)
```

The layout renders `AppSheetHeader` + a scrollable body + your footer. `AppScreenFooter` behaves identically inside a sheet as it does on a page — the same SafeArea, keyboard-hide, and horizontal padding apply.

## 5. Horizontal carousel (edge-bleed) pattern

When a section inside a padded vertical list needs to scroll horizontally and *bleed to the screen edge* (App Store cards, Netflix tiles, our Upcoming games row):

```dart
ListView(
  // Vertical-only padding on the outer scroll.
  padding: const EdgeInsets.only(
    top: AppPageInsets.top,
    bottom: AppPageInsets.bottom,
  ),
  children: [
    // Each vertical section wraps itself in horizontal padding.
    _PaddedSection(child: _SectionHeader(label: 'Upcoming')),
    const SizedBox(height: AppSpacing.sm),

    // Horizontal scroller does NOT wrap in horizontal padding.
    // Its own `padding: horizontal:` gives the first/last cards
    // the same gutter; scroll extends beyond that inset so cards
    // flow to the screen edge.
    SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppPageInsets.horizontal,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => SomeCard(item: items[i]),
      ),
    ),
  ],
)
```

**Why not put horizontal padding on the outer `ListView`?** Then the horizontal scroller is constrained to the padded area — cards can never bleed to the screen edge. This is the pattern App Store, Netflix, and Spotify use for their horizontal rails.

## 6. `KeyboardDismissible`

Standard iOS pattern: tap anywhere outside a focused input to dismiss the keyboard. Wrap page bodies with form inputs:

```dart
body: KeyboardDismissible(
  child: ListView(...),
)
```

Small wrapper around a `GestureDetector` that calls `FocusScope.of(context).unfocus()` on tap.

## 7. `AppDetailAppBar`

Detail / drill-down pages (not main-nav tabs). Ghost back-button leading, centered title, `titleMedium` typography.

Pass optional `subtitle:` for a secondary line below the title (bar grows +16px to accommodate). Use for game metadata (date · location), assessment context (coach · team), etc. — anything you'd otherwise render as a body-level subheader is a candidate for promotion to the app bar.

## 8. Provider fetch + cache lifecycle

Established pattern (see `gamesProvider`, `assessmentsProvider`, `skillProgressProvider`, etc.):

```dart
final gamesProvider =
    AsyncNotifierProvider.family<GamesNotifier, GetGamesData?, String>(
  GamesNotifier.new,
);

class GamesNotifier extends FamilyAsyncNotifier<GetGamesData?, String> {
  @override
  Future<GetGamesData?> build(String teamId) async {
    // Session-guarded lazy fetch.
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;
    final result = await ref.read(gamesRepositoryProvider).getGames(teamId: teamId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async { ... }        // pull-to-refresh
  void replaceGame(update_game.Game g) { ... } // after a mutation
}
```

**Lifecycle:**
- **Lazy fetch.** First `ref.watch(gamesProvider(teamId))` from any widget triggers `build()`. Nothing pre-fetches on login/entry.
- **Session-lifetime cache.** No TTL. The `family` variant keeps a separate entry per keyed argument (e.g., per team id).
- **Refresh via `.refresh()`** — pull-to-refresh action calls this. Sets `AsyncLoading` then refetches.
- **Targeted mutation via `.replaceGame()` / `.prepend()` / similar** — after a successful edge-function call, mutate the cached list in place with the server-returned canonical row. Avoids a full refetch. Server response is the source of truth for the mutated row.
- **Sign-out invalidation.** `profileAuthSyncProvider` listens to `Supabase.auth.onAuthStateChange`. On `signedOut`, it calls `ref.invalidate(gamesProvider)` and every sibling family provider. A different user signing in next starts with fresh caches.

**Mutation flow pattern (pessimistic wait-then-replace):**
```dart
setState(() { _saving = true; _error = null; });
final result = await ref.read(gamesRepositoryProvider).updateGame(...);
if (!mounted) return;
switch (result) {
  case Success(:final data):
    ref.read(gamesProvider(teamId).notifier).replaceGame(data.game);
    context.pop();
  case Failure(:final message):
    setState(() { _saving = false; _error = message; });
}
```

Wait for the server, mutate the cache with the returned canonical row, pop on success / show inline error on failure. Never mutate the cache from local form values — the server may normalize (trim whitespace, set attribution fields, etc.).
