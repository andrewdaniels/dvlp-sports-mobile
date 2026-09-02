import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_text_field.dart';

/// Email + password login for existing users.
///
/// Submit is unwired: any tap drops the user into the shell so we can
/// build/browse the authed side of the app. Real credential validation
/// lands with the auth repository (task #28).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO(task #28): call auth repository sign-in; only navigate on success.
    context.go(RouteNames.passport);
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
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Password',
                placeholder: 'Your password',
                controller: _password,
                obscureText: true,
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
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
