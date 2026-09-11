import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/auth_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_icon_button.dart';

/// Coach-side profile page. Placeholder — the athlete profile page
/// has a fully-populated info card + verified coaches sheet; the
/// coach equivalent gets designed and built separately. Log-out lives
/// here so coaches can sign out even before the real page lands.
class CoachProfilePage extends ConsumerWidget {
  const CoachProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppIconButton(
              icon: AppIcons.settings,
              size: AppIconButtonSize.large,
              onPressed: () => context.push(RouteNames.accountSettings),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Coach Profile\n(placeholder)',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Log Out',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.medium,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await ref.read(authRepositoryProvider).signOut();
                // Router redirect handles navigation to /entry on
                // auth-state change.
              },
            ),
          ],
        ),
      ),
    );
  }
}
