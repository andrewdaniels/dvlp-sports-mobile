import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_logo.dart';

enum _SignupType { player, coach }

/// "Welcome" screen — user picks Player or Coach when they don't
/// have an invite code. Type is what determines the fields on the
/// account creation form that follows.
///
/// GM signup is web-only (per product decision), so no GM option here.
class SignupTypePage extends StatefulWidget {
  const SignupTypePage({super.key});

  @override
  State<SignupTypePage> createState() => _SignupTypePageState();
}

class _SignupTypePageState extends State<SignupTypePage> {
  _SignupType? _selected;

  void _select(_SignupType type) {
    HapticFeedback.selectionClick();
    setState(() => _selected = type);
  }

  void _next() {
    HapticFeedback.mediumImpact();
    // TODO(task #31): push /signup/details with selected type.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Continuing as ${_selected!.name} — form not wired yet')),
    );
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
              const SizedBox(height: AppSpacing.md),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(size: AppLogoSize.header),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Welcome', style: AppTypography.headlineSmall.copyWith(color: colors.primaryText)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select your user type to begin creating your account.',
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
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
              AppButton(
                label: 'Next',
                variant: AppButtonVariant.primary,
                expand: true,
                onPressed: _selected == null ? null : _next,
              ),
              const SizedBox(height: 40),
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
          color: colors.secondaryBackground,
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
