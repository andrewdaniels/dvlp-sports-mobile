import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_logo.dart';

/// First screen an unauthenticated user sees.
///
/// Two paths:
/// - **Create Account** — includes an invite-code step for those who
///   have one (invite is a sub-step of signup, not a top-level path)
/// - **Log In** — existing user
class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const Center(child: AppLogo(size: AppLogoSize.hero)),
              const SizedBox(height: AppSpacing.lg),
              const _EntryWordmark(),
              const Spacer(),
              AppButton(
                label: 'Create Account',
                variant: AppButtonVariant.primary,
                expand: true,
                onPressed: () => _notImplemented(context, 'Create Account'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Log In',
                variant: AppButtonVariant.outline,
                expand: true,
                onPressed: () => context.push(RouteNames.login),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// One-off wordmark used only on the entry screen — "DVLP" over
/// spaced-caps "SPORTS". Intentionally not extracted to a shared widget
/// because this is the only place it renders.
class _EntryWordmark extends StatelessWidget {
  const _EntryWordmark();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DVLP',
          style: AppTypography.anybody(
            fontSize: 64,
            color: colors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'SPORTS',
          style: AppTypography.titleMedium.copyWith(
            color: colors.secondary,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

void _notImplemented(BuildContext context, String flow) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$flow flow — coming next')),
  );
}
