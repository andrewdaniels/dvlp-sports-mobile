import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_profile.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controllers/auth_providers.dart';
import '../../controllers/profile_providers.dart';

/// Guardians temporarily share the athlete shell (same bottom nav)
/// while we defer the real guardian → athlete data-access work. Each
/// athlete tab wraps its body in this widget: when the signed-in
/// user is a guardian, we render a "coming soon" placeholder instead
/// of the athlete UI (which would show wrong/missing data for a
/// guardian's own profile).
///
/// **Remove this widget** — and unwrap all four call sites — once the
/// guardian → athlete access edge fn work ships and the guardian
/// home / athlete-switcher is real UI.
class GuardianGate extends ConsumerWidget {
  const GuardianGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile?.roleTier == RoleTier.GUARDIAN) {
      return const _GuardianPlaceholder();
    }
    return child;
  }
}

class _GuardianPlaceholder extends ConsumerWidget {
  const _GuardianPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Guardian view coming soon',
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Sign-out affordance lives here (not on the profile
                // tab) because every athlete tab is gated for
                // guardians — a per-tab log-out button on the profile
                // page would be unreachable. Remove alongside
                // GuardianGate when guardian → athlete access ships
                // and the real guardian profile page owns log-out.
                AppButton(
                  label: 'Log Out',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.medium,
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(authRepositoryProvider).signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
