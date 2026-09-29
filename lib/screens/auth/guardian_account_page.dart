import 'dart:io';

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
import '../../shared/util/avatar_picker.dart';
import '../../shared/util/phone.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_select_trigger.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_wheel_picker.dart';

/// Guardian account form. Two modes:
///
///  - Signup ([isEdit] false): fields blank (or invite-prefilled),
///    submit calls create-profile + signs in + routes to landing.
///  - Edit ([isEdit] true): fields seeded from currentProfileProvider,
///    submit calls update-profile + pops. ToS checkbox is signup-only.
class GuardianAccountPage extends ConsumerStatefulWidget {
  const GuardianAccountPage({super.key, this.isEdit = false});

  final bool isEdit;

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
  File? _avatarFile;
  String? _avatarBase64;
  String? _existingAvatarUrl;

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _seedFromProfile();
    } else {
      _seedFromSignupContext();
    }
    _first.addListener(_onFieldChanged);
    _last.addListener(_onFieldChanged);
    _phone.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit {
    if (_first.text.trim().isEmpty) return false;
    if (_last.text.trim().isEmpty) return false;
    if (toE164(_phone.text) == null) return false;
    if (_dob == null) return false;
    return true;
  }

  void _seedFromSignupContext() {
    final ctx = ref.read(signupFlowProvider);
    if (ctx == null) return;
    if (ctx.firstName != null) _first.text = ctx.firstName!;
    if (ctx.lastName != null) _last.text = ctx.lastName!;
  }

  void _seedFromProfile() {
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;
    _first.text = profile.firstName;
    _last.text = profile.lastName;
    _phone.text = profile.phone == null ? '' : formatFromE164(profile.phone!);
    if (profile.dateOfBirth != null) {
      _dob = DateTime.tryParse(profile.dateOfBirth!);
    }
    _existingAvatarUrl = profile.avatarUrl;
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

  Future<void> _uploadPhoto() async {
    HapticFeedback.lightImpact();
    final picked = await pickAvatarFromLibrary(context);
    if (picked == null || !mounted) return;
    setState(() {
      _avatarFile = picked.file;
      _avatarBase64 = picked.base64;
    });
  }

  void _back() {
    HapticFeedback.lightImpact();
    context.pop();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final firstName = _first.text.trim();
    final lastName = _last.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }
    final phoneE164 = toE164(_phone.text);
    if (phoneE164 == null) {
      setState(() => _errorText = 'Please enter a 10-digit phone number.');
      return;
    }
    if (_dob == null) {
      setState(() => _errorText = 'Please select your date of birth.');
      return;
    }

    if (widget.isEdit) {
      await _submitEdit(firstName, lastName, phoneE164);
    } else {
      await _submitSignup(firstName, lastName, phoneE164);
    }
  }

  Future<void> _submitEdit(String firstName, String lastName, String phone) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final result = await ref.read(profileRepositoryProvider).updateProfile(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          dateOfBirth: _formatIsoDate(_dob!),
          avatarBase64: _avatarBase64,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        ref.read(currentProfileProvider.notifier).optimisticSetFromUpdate(data);
        AppSnackBar.show(context, message: 'Profile updated.');
        context.pop();
      case Failure(:final message):
        setState(() {
          _submitting = false;
          _errorText = message;
        });
    }
  }

  Future<void> _submitSignup(String firstName, String lastName, String phone) async {
    final ctx = ref.read(signupFlowProvider);
    if (ctx == null) {
      context.go(RouteNames.entry);
      return;
    }
    if (!_agreed) {
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
          avatarBase64: _avatarBase64,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        ref.read(currentProfileProvider.notifier).optimisticSetFromCreate(data);

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

  void _openLegal(BuildContext context, String docName) {
    AppSnackBar.show(context, message: '$docName — coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryLabel = widget.isEdit ? 'Save' : 'Submit';
    final secondaryLabel = widget.isEdit ? 'Cancel' : 'Back';
    final headerTitle = widget.isEdit ? 'Edit Profile' : 'Your Account';
    final headerSubtitle = widget.isEdit
        ? 'Update your account details below.'
        : 'A few details to set up your guardian account.';

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    AppOnboardingHeader(
                      title: headerTitle,
                      subtitle: headerSubtitle,
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
                              imageFile: _avatarFile,
                              imageUrl: _existingAvatarUrl,
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
                              placeholder: '(555) 123-4567',
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: const [PhoneInputFormatter()],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppSelectTrigger(
                              label: 'Date of Birth',
                              placeholder: 'Select date',
                              value: _dob == null ? null : _formatDob(_dob!),
                              onTap: _pickDob,
                            ),
                            if (!widget.isEdit) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _ConsentCheckbox(
                                value: _agreed,
                                onChanged: (v) => setState(() => _agreed = v),
                                onTermsTap: () => _openLegal(context, 'Terms of Service'),
                                onPrivacyTap: () => _openLegal(context, 'Privacy Policy'),
                              ),
                            ],
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
              horizontalPadding: AppSpacing.md,
              secondary: AppButton(
                label: secondaryLabel,
                variant: AppButtonVariant.outline,
                onPressed: _submitting ? null : _back,
              ),
              primary: AppButton(
                label: primaryLabel,
                variant: AppButtonVariant.primary,
                loading: _submitting,
                onPressed: (_canSubmit && (widget.isEdit || _agreed))
                    ? _submit
                    : null,
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
    required this.imageFile,
    required this.imageUrl,
    required this.onUpload,
  });

  final String firstName;
  final String lastName;
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);
    return Row(
      children: [
        AppAvatar(
          firstName: firstName,
          lastName: lastName,
          imageFile: imageFile,
          imageUrl: imageUrl,
          size: AppAvatarSize.large,
          onTap: onUpload,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            label: hasPhoto ? 'Change Profile Picture' : 'Upload Profile Picture',
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
