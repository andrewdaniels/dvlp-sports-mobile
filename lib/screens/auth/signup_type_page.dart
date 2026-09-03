import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/signup_flow_provider.dart';
import '../../features/auth/data/signup_context.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';

enum _SignupType { player, coach }

/// "Welcome" screen — user picks Player or Coach when they don't
/// have an invite code. Type is what determines the fields on the
/// account creation form that follows.
///
/// GM signup is web-only (per product decision), so no GM option here.
class SignupTypePage extends ConsumerStatefulWidget {
  const SignupTypePage({super.key});

  @override
  ConsumerState<SignupTypePage> createState() => _SignupTypePageState();
}

class _SignupTypePageState extends ConsumerState<SignupTypePage> {
  _SignupType? _selected;

  void _select(_SignupType type) {
    HapticFeedback.selectionClick();
    setState(() => _selected = type);
  }

  void _next() {
    HapticFeedback.mediumImpact();
    final role = _selected! == _SignupType.player ? 'athlete' : 'coach';
    ref.read(signupFlowProvider.notifier).state = SignupContext(role: role);
    context.push(RouteNames.signupCredentials);
  }

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
              const SizedBox(height: AppSpacing.lg),
              const AppOnboardingHeader(
                title: 'Welcome',
                subtitle: 'Select your user type to begin creating your account.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              _TypeOption(
                label: 'I am a player',
                selected: _selected == _SignupType.player,
                onTap: () => _select(_SignupType.player),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TypeOption(
                label: 'I am a coach',
                selected: _selected == _SignupType.coach,
                onTap: () => _select(_SignupType.coach),
              ),
              const Spacer(),
              AppScreenFooter.single(
                primary: AppButton(
                  label: 'Next',
                  variant: AppButtonVariant.primary,
                  onPressed: _selected == null ? null : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.accent2Tint : colors.secondaryBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? colors.secondary : colors.alternate,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
