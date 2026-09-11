import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/services/supabase_service.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_logo.dart';

/// Role gate rendered at `/`. Reached only when the caller has a
/// valid local session — the router's `redirect` handles the
/// no-session case by bouncing to /entry before splash even mounts.
///
/// Splash's only job here is to determine role and route to the
/// correct shell:
///
///   - profile loaded  → athlete or coach shell (per role_tier)
///   - error / null    → stale local session that failed server-side
///                       auth. Clear it (signOut) and bounce to /entry
///                       so the user can sign in fresh.
///   - loading         → keep the logo on screen
///
/// Uses `ref.watch` so the widget rebuilds on the provider's state
/// transitions.
///
/// Why this pattern instead of role logic inside `redirect`:
/// [go_router]'s redirect callback is a synchronous function that
/// only has access to the raw session (via [SupabaseService]) — it
/// can't read Riverpod providers without container plumbing. Keeping
/// role resolution here lets us react naturally to profile state.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(currentProfileProvider);

    if (async.isLoading) return _logo();

    // Server-side auth failed OR profile resolved to null despite a
    // local session — the persisted JWT is stale. Clear it and route
    // to entry so the user can sign in fresh. signOut is fire-and-
    // forget; the auth listener will pick up the state change.
    if (async.hasError || async.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await SupabaseService.client.auth.signOut();
        if (context.mounted) context.go(RouteNames.entry);
      });
      return _logo();
    }

    final profile = async.value!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(_landingFor(profile.roleTier));
    });
    return _logo();
  }

  Widget _logo() => const Scaffold(
        body: SafeArea(child: Center(child: AppLogo(size: AppLogoSize.hero))),
      );

  static String _landingFor(RoleTier role) => switch (role) {
        RoleTier.COACH => RouteNames.coachHome,
        // Everyone else lands on the athlete shell for now (admin /
        // manager / team_manager surfaces don't exist yet).
        _ => RouteNames.athletePassport,
      };
}
