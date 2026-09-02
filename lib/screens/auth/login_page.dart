import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/auth_providers.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _errorText;

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
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      context.go(RouteNames.passport);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = authErrorMessage(e);
        _submitting = false;
      });
    }
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
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.entry),
        ),
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
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Password',
                placeholder: 'Your password',
                controller: _password,
                obscureText: true,
                errorText: _errorText,
                onChanged: (_) => setState(() {
                  if (_errorText != null) _errorText = null;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
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
              AppScreenFooter.single(
                primary: AppButton(
                  label: 'Log In',
                  variant: AppButtonVariant.primary,
                  loading: _submitting,
                  onPressed: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
