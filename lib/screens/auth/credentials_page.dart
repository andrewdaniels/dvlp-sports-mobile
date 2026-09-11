import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/signup_flow_provider.dart';
import '../../features/auth/data/signup_context.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_text_field.dart';

/// Password (and, when no invite provided one, email) step in the
/// signup flow. Comes after either:
///   - validate-invite success (email known → hide email field)
///   - type selection (no invite → show email field)
///
/// On Next: persists email/password into [signupFlowProvider] and
/// routes to the role-specific account form.
class CredentialsPage extends ConsumerStatefulWidget {
  const CredentialsPage({super.key});

  @override
  ConsumerState<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends ConsumerState<CredentialsPage> {
  static const _minPasswordLength = 8;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Guard against direct-linking with no signup context — bounce home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = ref.read(signupFlowProvider);
      if (ctx == null) {
        context.go(RouteNames.entry);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    // Deliberately permissive — Supabase auth does the real validation.
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  void _submit(SignupContext ctx) {
    setState(() => _errorText = null);

    final needsEmail = ctx.email == null;
    final email = needsEmail ? _email.text.trim() : ctx.email!;
    final password = _password.text;
    final confirm = _confirm.text;

    if (needsEmail && !_isValidEmail(email)) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }
    if (password.length < _minPasswordLength) {
      setState(() => _errorText = 'Password must be at least $_minPasswordLength characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = 'Passwords don\'t match.');
      return;
    }

    ref.read(signupFlowProvider.notifier).state = ctx.copyWith(
      email: email,
      password: password,
    );

    switch (ctx.role) {
      case 'athlete':
        context.push(RouteNames.signupPlayerDetails);
      case 'coach':
        context.push(RouteNames.signupCoachDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = ref.watch(signupFlowProvider);
    if (ctx == null) {
      // Redirect fires from initState; render a placeholder while it's
      // in flight so we don't crash.
      return const Scaffold(body: SizedBox.shrink());
    }

    final colors = context.colors;
    final needsEmail = ctx.email == null;
    final hasError = _errorText != null;

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
                title: 'Almost There',
                subtitle: 'Create a password to secure your account.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (needsEmail) ...[
                AppTextField(
                  label: 'Email',
                  placeholder: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                label: 'Password',
                placeholder: 'At least $_minPasswordLength characters',
                controller: _password,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Confirm Password',
                placeholder: 'Re-enter your password',
                controller: _confirm,
                obscureText: true,
              ),
              if (hasError) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorText!,
                  style: AppTypography.bodyMedium.copyWith(color: colors.error),
                ),
              ],
              const Spacer(),
              AppScreenFooter.row(
                secondary: AppButton(
                  label: 'Back',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.pop(),
                ),
                primary: AppButton(
                  label: 'Next',
                  variant: AppButtonVariant.primary,
                  onPressed: () => _submit(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
