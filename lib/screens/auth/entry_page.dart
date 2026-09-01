import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_logo.dart';

/// First screen an unauthenticated user sees.
///
/// Three paths:
/// - **Create Account** — fresh signup, no invite context
/// - **I have an invite code** — redeem invite → create account with
///   prefilled/locked fields
/// - **Log In** — existing user
class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const Center(child: AppLogo(height: 96)),
              const Spacer(),
              AppButton(
                label: 'Create Account',
                variant: AppButtonVariant.primary,
                expand: true,
                onPressed: () => _notImplemented(context, 'Create Account'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'I have an invite code',
                variant: AppButtonVariant.outline,
                expand: true,
                onPressed: () => _notImplemented(context, 'Invite code'),
              ),
              const SizedBox(height: AppSpacing.xl),
              _LoginRow(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

void _notImplemented(BuildContext context, String flow) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$flow flow — coming next')),
  );
}

class _LoginRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(RouteNames.login);
          },
          child: Text(
            'Log In',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.link,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
