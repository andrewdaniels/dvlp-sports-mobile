import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/auth/controllers/signup_flow_provider.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';

/// Coach account creation form.
///
/// Only reachable after a valid invite (invite-only signup for coaches
/// in MVP — the "no invite" path is deferred). Fields per design:
/// avatar upload + first/last name + phone. Team, role, and website
/// are omitted for MVP — team + role come from the invite; website
/// is deferred.
///
/// Submit is intentionally disabled until we finalize the avatar
/// upload architecture (client-side upload before create-profile vs
/// bundled base64 in the edge fn) and wire the coach path through
/// create-profile. See in-session discussion + follow-up task.
class CoachAccountPage extends ConsumerStatefulWidget {
  const CoachAccountPage({super.key});

  @override
  ConsumerState<CoachAccountPage> createState() => _CoachAccountPageState();
}

class _CoachAccountPageState extends ConsumerState<CoachAccountPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill name from the invite if present (same pattern as the
    // player form). Coach signup requires an invite for MVP, so the
    // context should always be here — guard defensively anyway.
    final ctx = ref.read(signupFlowProvider);
    if (ctx != null) {
      if (ctx.firstName != null) _first.text = ctx.firstName!;
      if (ctx.lastName != null) _last.text = ctx.lastName!;
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// Placeholder until image_picker + storage upload lands.
  void _uploadPhoto() {
    AppSnackBar.show(context, message: 'Photo upload — coming later');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                    const AppOnboardingHeader(
                      title: 'Your Account',
                      subtitle: 'Enter the information below to create your account',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        // Falls back to initials from the invite-prefilled
                        // name until the avatar upload flow is wired up.
                        // Both the avatar itself and the pill button trigger
                        // the same upload action for a wider tap target.
                        AppAvatar(
                          firstName: _first.text,
                          lastName: _last.text,
                          size: AppAvatarSize.large,
                          onTap: _uploadPhoto,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: 'Upload Profile Picture',
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.medium,
                            expand: true,
                            onPressed: _uploadPhoto,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'First Name',
                      placeholder: 'Enter first name',
                      controller: _first,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Last Name',
                      placeholder: 'Enter last name',
                      controller: _last,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Phone Number',
                      placeholder: 'Enter phone number',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            AppScreenFooter.row(
              horizontalPadding: AppSpacing.xl,
              secondary: AppButton(
                label: 'Back',
                variant: AppButtonVariant.outline,
                onPressed: () => context.pop(),
              ),
              // Disabled until the create-profile coach path +
              // avatar upload architecture is wired up. Passing
              // null onPressed puts the button in its disabled
              // state per AppButton's contract.
              primary: const AppButton(
                label: 'Next',
                variant: AppButtonVariant.primary,
                onPressed: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

