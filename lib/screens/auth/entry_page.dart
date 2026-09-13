import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_screen_footer.dart';

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
      // Outer SafeArea handles top (status bar / notch); footer owns
      // its own bottom SafeArea + horizontal padding + keyboard-hide.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
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
                  ],
                ),
              ),
            ),
            AppScreenFooter.stacked(
              horizontalPadding: AppSpacing.xl,
              primary: AppButton(
                label: 'Create Account',
                variant: AppButtonVariant.primary,
                onPressed: () => context.push(RouteNames.signupCode),
              ),
              secondary: AppButton(
                label: 'Log In',
                variant: AppButtonVariant.outline,
                onPressed: () => context.push(RouteNames.login),
              ),
            ),
          ],
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

