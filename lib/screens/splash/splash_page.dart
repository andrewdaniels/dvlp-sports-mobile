import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_loading_indicator.dart';

/// Role gate rendered at `/`. Watches [currentProfileProvider] and,
/// once the profile resolves, redirects to the appropriate shell's
/// landing tab. Renders a spinner in the meantime.
///
/// Why this pattern instead of role logic inside `redirect`:
/// [go_router]'s redirect callback is a synchronous function that
/// only has access to the raw session (via [SupabaseService]) — it
/// can't read Riverpod providers without container plumbing. Putting
/// the branch in a widget keeps the router simple and lets us react
/// naturally to profile state via [ConsumerWidget].
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<GetProfileData?>>(currentProfileProvider, (previous, next) {
      final profile = next.value;
      if (profile == null) return;
      final target = _landingFor(profile.roleTier);
      // Post-frame guard: goRouter doesn't like being kicked while a
      // build is running.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(target);
      });
    });

    // First build might already have the profile cached from a prior
    // session; drive the same redirect eagerly without waiting for a
    // change notification.
    final async = ref.read(currentProfileProvider);
    final cached = async.value;
    if (cached != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(_landingFor(cached.roleTier));
      });
    }

    return const Scaffold(
      body: Center(child: AppLoadingIndicator()),
    );
  }

  static String _landingFor(RoleTier role) => switch (role) {
        RoleTier.COACH => RouteNames.coachHome,
        // Everyone else lands on the athlete shell for now (admin /
        // manager / team_manager surfaces don't exist yet).
        _ => RouteNames.athletePassport,
      };
}
