import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/controllers/profile_providers.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../auth/coach_account_page.dart';
import '../auth/guardian_account_page.dart';
import '../auth/player_account_page.dart';

/// Pencil-icon destination on the profile page. Reads the caller's role
/// and mounts the matching account form in edit mode. Purely a router
/// — all the actual editing lives in the reused form pages.
class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (_, _) => const Scaffold(body: SizedBox.shrink()),
      data: (profile) {
        if (profile == null) return const Scaffold(body: SizedBox.shrink());
        return switch (profile.roleTier) {
          RoleTier.ATHLETE => const PlayerAccountPage(isEdit: true),
          RoleTier.GUARDIAN => const GuardianAccountPage(isEdit: true),
          RoleTier.COACH => const CoachAccountPage(isEdit: true),
          _ => const Scaffold(
              body: Center(child: Text('Editing this profile type is coming soon.')),
            ),
        };
      },
    );
  }
}
