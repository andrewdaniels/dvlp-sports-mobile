import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/invite_providers.dart';
import '../../features/auth/controllers/signup_flow_provider.dart';
import '../../features/auth/data/api_result.dart';
import '../../features/auth/data/signup_context.dart';
import '../../generated/api/validate_invite.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';

/// First step after tapping "Create Account" on the entry screen.
///
/// Invite-only for MVP — no escape hatch for users without a code.
/// If they don't have one, they can't sign up here.
class SignupCodePage extends ConsumerStatefulWidget {
  const SignupCodePage({super.key});

  @override
  ConsumerState<SignupCodePage> createState() => _SignupCodePageState();
}

class _SignupCodePageState extends ConsumerState<SignupCodePage> {
  static const _codeLength = 6;
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _complete => _controller.text.length == _codeLength;

  Future<void> _submit() async {
    if (!_complete || _submitting) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final result = await ref
        .read(inviteRepositoryProvider)
        .validateCode(_controller.text);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() => _submitting = false);
        ref.read(signupFlowProvider.notifier).state = SignupContext(
          role: _roleFromInvite(data.targetRole),
          email: data.email,
          firstName: data.firstName,
          lastName: data.lastName,
          inviteId: data.inviteId,
          invite: data,
        );
        context.push(RouteNames.signupCredentials);
      case Failure(:final message):
        setState(() {
          _submitting = false;
          _errorText = message;
        });
    }
  }

  /// Map the invite's TargetRole enum onto our string role ('athlete' /
  /// 'coach') for downstream screens. Non-athlete/coach roles (admin,
  /// managers, guardian) don't sign up via mobile — treat as athlete
  /// for now and let the server reject if needed.
  String _roleFromInvite(TargetRole target) {
    switch (target) {
      case TargetRole.COACH:
        return 'coach';
      case TargetRole.ATHLETE:
      case TargetRole.ADMIN:
      case TargetRole.ORGANIZATION_MANAGER:
      case TargetRole.TEAM_MANAGER:
      case TargetRole.GUARDIAN:
        return 'athlete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = _errorText != null;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      // Outer SafeArea handles top; footer owns bottom SafeArea +
      // horizontal padding + keyboard-hide.
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
                    const SizedBox(height: AppSpacing.lg),
                    AppOnboardingHeader(
                      title: 'Enter Invite Code',
                      subtitle:
                          'Enter the $_codeLength-character code from your invite email to get started.',
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _CodeInput(
                      controller: _controller,
                      length: _codeLength,
                      onChanged: (_) => setState(() {
                        if (_errorText != null) _errorText = null;
                      }),
                      onCompleted: (_) => _submit(),
                    ),
                    if (hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(color: colors.error),
                        ),
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ),
            AppScreenFooter.single(
              horizontalPadding: AppSpacing.xl,
              primary: AppButton(
                label: 'Continue',
                variant: AppButtonVariant.primary,
                loading: _submitting,
                onPressed: _complete ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeInput extends StatelessWidget {
  const _CodeInput({
    required this.controller,
    required this.length,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final base = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTypography.titleLarge.copyWith(color: colors.primaryText),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.alternate, width: 1),
      ),
    );

    return Pinput(
      controller: controller,
      length: length,
      onChanged: onChanged,
      onCompleted: onCompleted,
      autofocus: false,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        UpperCaseTextFormatter(),
      ],
      defaultPinTheme: base,
      focusedPinTheme: base.copyBorderWith(
        border: Border.all(color: colors.link, width: 2),
      ),
      submittedPinTheme: base.copyBorderWith(
        border: Border.all(color: colors.secondary, width: 1),
      ),
      showCursor: true,
      cursor: Container(
        width: 2,
        height: 24,
        color: colors.link,
      ),
      hapticFeedbackType: HapticFeedbackType.lightImpact,
    );
  }
}

/// Auto-uppercase formatter for the invite code input.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
