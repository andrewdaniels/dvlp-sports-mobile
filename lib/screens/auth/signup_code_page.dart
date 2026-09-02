import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';

/// First step after tapping "Create Account" on the entry screen.
///
/// Leads with invite code entry (the expected path for most signups
/// since the platform is invite-driven), with an escape hatch for
/// users without a code that routes to the type-selection screen.
class SignupCodePage extends StatefulWidget {
  const SignupCodePage({super.key});

  @override
  State<SignupCodePage> createState() => _SignupCodePageState();
}

class _SignupCodePageState extends State<SignupCodePage> {
  static const _codeLength = 6;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _complete => _controller.text.length == _codeLength;

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    // TODO(task #32): validate code via edge function, then push
    // /signup/details with prefill payload.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code ${_controller.text} — validation not wired')),
    );
  }

  void _continueWithoutCode() {
    HapticFeedback.lightImpact();
    context.push(RouteNames.signupType);
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
              AppOnboardingHeader(
                title: 'Enter Invite Code',
                subtitle:
                    'Enter the $_codeLength-character code from your invite email to get started.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              _CodeInput(
                controller: _controller,
                length: _codeLength,
                onChanged: (_) => setState(() {}),
                onCompleted: (_) => _submit(),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _continueWithoutCode,
                  child: Text(
                    "I don't have a code",
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.link,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              AppScreenFooter.single(
                primary: AppButton(
                  label: 'Continue',
                  variant: AppButtonVariant.primary,
                  onPressed: _complete ? _submit : null,
                ),
              ),
            ],
          ),
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
