import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

/// Email + password login for existing users.
///
/// Submit is stubbed until auth repository lands (task #28).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      _email.text.trim().isNotEmpty &&
      _password.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _submitting = true;
    });
    HapticFeedback.mediumImpact();
    // TODO(task #28): call auth repository sign-in.
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auth repository not wired yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Log In'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Email',
                placeholder: 'you@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Password',
                placeholder: 'Your password',
                controller: _password,
                obscureText: true,
                errorText: _passwordError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password — coming later')),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.link,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Log In',
                variant: AppButtonVariant.primary,
                expand: true,
                onPressed: _canSubmit ? _submit : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
