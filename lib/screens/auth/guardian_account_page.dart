import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/auth_providers.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/auth/controllers/signup_flow_provider.dart';
import '../../features/auth/data/api_result.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_select_trigger.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_wheel_picker.dart';

/// Guardian signup form. Reached from the credentials screen when the
/// invite's target_role is `guardian` (routed there by signup_code_page).
///
/// Fields kept intentionally minimal — guardians link to an athlete
/// they didn't need to fill out sport-specific data for. last_name and
/// phone are optional; DOB is required for the server-side adult
/// (18+) gate.
class GuardianAccountPage extends ConsumerStatefulWidget {
  const GuardianAccountPage({super.key});

  @override
  ConsumerState<GuardianAccountPage> createState() => _GuardianAccountPageState();
}

class _GuardianAccountPageState extends ConsumerState<GuardianAccountPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();

  DateTime? _dob;
  bool _agreed = false;
  bool _submitting = false;
  String? _errorText;

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    // Seed name fields from the invite if we have them. Invite may
    // carry a first_name/last_name the athlete filled in, but for
    // guardian invites those are usually null — safe to no-op.
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

  Future<void> _pickDob() async {
    final now = DateTime.now();
    // Guardians are adults — DOB picker capped so the wheel can't
    // land on a value that would fail the server's 18+ gate. Default
    // starts at 40yo — arbitrary common-case for guardians.
    final result = await showAppDatePicker(
      context: context,
      title: 'Date of Birth',
      initialDate: _dob ?? DateTime(now.year - 40, 6, 15),
      minimumDate: DateTime(now.year - 100),
      maximumDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (result != null && mounted) setState(() => _dob = result);
  }

  String _formatDob(DateTime d) => '${_monthLabels[d.month - 1]} ${d.day}, ${d.year}';

  void _uploadPhoto() {
    HapticFeedback.lightImpact();
    AppSnackBar.show(context, message: 'Photo upload — coming later');
  }

  void _back() {
    HapticFeedback.lightImpact();
    context.pop();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final ctx = ref.read(signupFlowProvider);
    if (ctx == null) {
      context.go(RouteNames.entry);
      return;
    }

    final firstName = _first.text.trim();
    final lastName = _last.text.trim();
    final phone = _phone.text.trim();
    // All profile fields required for guardian accounts (avatar is
    // still deferred). Server also validates first_name non-empty
    // via zod, so this is a UX guard.
    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }
    if (_dob == null) {
      setState(() => _errorText = 'Please select your date of birth.');
      return;
    }
    if (!_agreed) {
      // Should never trigger — Submit is disabled until _agreed —
      // but guard anyway.
      setState(() => _errorText = 'Please agree to the Terms of Service and Privacy Policy.');
      return;
    }
    if (ctx.email == null || ctx.password == null || ctx.inviteId == null) {
      setState(() => _errorText = 'Signup context missing — please go back and try again.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final result = await ref.read(profileRepositoryProvider).createGuardian(
          email: ctx.email!,
          password: ctx.password!,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          dateOfBirth: _formatIsoDate(_dob!),
          inviteId: ctx.inviteId!,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        ref.read(currentProfileProvider.notifier).optimisticSetFromCreate(data);

        // create-profile ran under service_role — no mobile session
        // yet. Sign in with the credentials we just collected.
        try {
          await ref.read(authRepositoryProvider).signInWithPassword(
                email: ctx.email!,
                password: ctx.password!,
              );
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _errorText = 'Account created. Please sign in.';
          });
          return;
        }

        ref.read(signupFlowProvider.notifier).state = null;

        if (!mounted) return;
        await ref.read(currentProfileProvider.notifier).refresh();
        if (!mounted) return;
        final profile = ref.read(currentProfileProvider).value;
        context.go(_landingFor(profile?.roleTier));

      case Failure(:final message):
        setState(() {
          _submitting = false;
          _errorText = message;
        });
    }
  }

  /// Guardians land in the athlete shell (with a _GuardianGate on each
  /// tab rendering a "coming soon" placeholder). Falls back to splash
  /// on unknown role — the splash gate will resolve or bounce.
  static String _landingFor(RoleTier? role) => switch (role) {
        RoleTier.COACH => RouteNames.coachHome,
        null => RouteNames.splash,
        _ => RouteNames.athletePassport,
      };

  static String _formatIsoDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  /// Placeholder for the Terms / Privacy links. Real URLs haven't
  /// been provided yet — swap to `url_launcher` (add the dep + import)
  /// once the docs are hosted. Snackbar avoids adding a new dep for a
  /// placeholder that would immediately churn.
  void _openLegal(BuildContext context, String docName) {
    AppSnackBar.show(context, message: '$docName — coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  // Stretch so AppOnboardingHeader (MainAxisSize.min
                  // internally) fills width instead of shrinking to
                  // its subtitle length and getting centered by the
                  // Column's default crossAxisAlignment. Otherwise
                  // shorter-subtitle pages read as "inset."
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const AppOnboardingHeader(
                      title: 'Your Account',
                      subtitle: 'A few details to set up your guardian account.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PhotoRow(
                              firstName: _first.text,
                              lastName: _last.text,
                              onUpload: _uploadPhoto,
                            ),
                            const SizedBox(height: AppSpacing.lg),
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
                              label: 'Phone',
                              placeholder: 'Enter phone number',
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppSelectTrigger(
                              label: 'Date of Birth',
                              placeholder: 'Select date',
                              value: _dob == null ? null : _formatDob(_dob!),
                              onTap: _pickDob,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _ConsentCheckbox(
                              value: _agreed,
                              onChanged: (v) => setState(() => _agreed = v),
                              onTermsTap: () => _openLegal(context, 'Terms of Service'),
                              onPrivacyTap: () => _openLegal(context, 'Privacy Policy'),
                            ),
                            if (_errorText != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _errorText!,
                                style: AppTypography.bodyMedium.copyWith(color: colors.error),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppScreenFooter.row(
              horizontalPadding: AppSpacing.xl,
              secondary: AppButton(
                label: 'Back',
                variant: AppButtonVariant.outline,
                onPressed: _submitting ? null : _back,
              ),
              primary: AppButton(
                label: 'Submit',
                variant: AppButtonVariant.primary,
                loading: _submitting,
                // Gate: consent required. Field-level required checks
                // fire in _submit() itself with useful error messages
                // (rather than a silent-disabled button that doesn't
                // tell the user WHY).
                onPressed: _agreed ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline consent widget: box (visually matches [AppCheckbox]) + a
/// rich-text label where "Terms of Service" and "Privacy Policy"
/// are tappable spans.
///
/// One-off — kept local rather than extending AppCheckbox's plain-
/// text label API. If a second consent lands, promote both the box
/// styling and the rich-text pattern into a shared widget.
class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  static const double _box = 22;
  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final linkStyle = AppTypography.bodyMedium.copyWith(
      color: colors.link,
      decoration: TextDecoration.underline,
      decorationColor: colors.link,
    );
    final baseStyle = AppTypography.bodyMedium.copyWith(color: colors.primaryText);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Toggle target — the box alone. Text spans have their own
        // TapGestureRecognizers so tapping "Terms of Service" opens
        // the doc without toggling the checkbox.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(!value);
          },
          child: Container(
            width: _box,
            height: _box,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? colors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: value
                  ? null
                  : Border.all(color: colors.primaryText70, width: 1.5),
            ),
            child: value
                ? AppIcon(AppIcons.check, size: _iconSize, color: colors.persistDark)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: baseStyle,
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.firstName,
    required this.lastName,
    required this.onUpload,
  });

  final String firstName;
  final String lastName;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          firstName: firstName,
          lastName: lastName,
          size: AppAvatarSize.large,
          onTap: onUpload,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            label: 'Upload Profile Picture',
            variant: AppButtonVariant.outline,
            size: AppButtonSize.medium,
            expand: true,
            onPressed: onUpload,
          ),
        ),
      ],
    );
  }
}
