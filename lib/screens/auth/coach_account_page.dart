import 'dart:io';

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
import '../../shared/util/avatar_picker.dart';
import '../../shared/util/phone.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';

/// Coach account form.
///
///  - Signup ([isEdit] false): invite-only. Submit calls create-profile,
///    signs in with the credentials collected upstream, and lands the
///    coach on their home shell. team_id + coach_type come from the
///    invite (backend RPC reads both); the form doesn't expose them.
///  - Edit ([isEdit] true): seeded from currentProfileProvider, Save
///    calls update-profile and pops.
class CoachAccountPage extends ConsumerStatefulWidget {
  const CoachAccountPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  ConsumerState<CoachAccountPage> createState() => _CoachAccountPageState();
}

class _CoachAccountPageState extends ConsumerState<CoachAccountPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();

  File? _avatarFile;
  String? _avatarBase64;
  String? _existingAvatarUrl;
  bool _submitting = false;
  String? _errorText;

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
    _existingAvatarUrl = profile.avatarUrl;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _uploadPhoto() async {
    HapticFeedback.lightImpact();
    final picked = await pickAvatarFromLibrary(context);
    if (picked == null || !mounted) return;
    setState(() {
      _avatarFile = picked.file;
      _avatarBase64 = picked.base64;
    });
  }

  Future<void> _submitSignup() async {
    if (_submitting) return;
    final ctx = ref.read(signupFlowProvider);
    if (ctx == null) {
      context.go(RouteNames.entry);
      return;
    }
    final firstName = _first.text.trim();
    final lastName = _last.text.trim();
    final phoneE164 = toE164(_phone.text);
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorText = 'Please enter your first and last name.');
      return;
    }
    if (phoneE164 == null) {
      setState(() => _errorText = 'Please enter a 10-digit phone number.');
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

    final result = await ref.read(profileRepositoryProvider).createCoach(
          email: ctx.email!,
          password: ctx.password!,
          firstName: firstName,
          lastName: lastName,
          inviteId: ctx.inviteId!,
          phone: phoneE164,
          avatarBase64: _avatarBase64,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        ref.read(currentProfileProvider.notifier).optimisticSetFromCreate(data);

        // create-profile ran under service_role — no mobile session
        // yet. Sign in with the credentials collected upstream.
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
        context.go(RouteNames.coachHome);

      case Failure(:final message):
        setState(() {
          _submitting = false;
          _errorText = message;
        });
    }
  }

  Future<void> _submitEdit() async {
    if (_submitting) return;
    final firstName = _first.text.trim();
    final lastName = _last.text.trim();
    final phoneE164 = toE164(_phone.text);
    if (firstName.isEmpty) {
      setState(() => _errorText = 'Please enter your first name.');
      return;
    }
    if (phoneE164 == null) {
      setState(() => _errorText = 'Please enter a 10-digit phone number.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final result = await ref.read(profileRepositoryProvider).updateProfile(
          firstName: firstName,
          lastName: lastName.isEmpty ? null : lastName,
          phone: phoneE164,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryLabel = widget.isEdit ? 'Save' : 'Submit';
    final secondaryLabel = widget.isEdit ? 'Cancel' : 'Back';
    final headerTitle = widget.isEdit ? 'Edit Profile' : 'Your Account';
    final headerSubtitle = widget.isEdit
        ? 'Update your account details below.'
        : 'Enter the information below to create your account';
    final hasPhoto = _avatarFile != null ||
        (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty);

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
                    Row(
                      children: [
                        AppAvatar(
                          firstName: _first.text,
                          lastName: _last.text,
                          imageFile: _avatarFile,
                          imageUrl: _existingAvatarUrl,
                          size: AppAvatarSize.large,
                          onTap: _uploadPhoto,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: hasPhoto
                                ? 'Change Profile Picture'
                                : 'Upload Profile Picture',
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
                      placeholder: '(555) 123-4567',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: const [PhoneInputFormatter()],
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _errorText!,
                        style: AppTypography.bodyMedium
                            .copyWith(color: colors.error),
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ),
            AppScreenFooter.row(
              horizontalPadding: AppSpacing.md,
              secondary: AppButton(
                label: secondaryLabel,
                variant: AppButtonVariant.outline,
                onPressed: _submitting ? null : () => context.pop(),
              ),
              primary: AppButton(
                label: primaryLabel,
                variant: AppButtonVariant.primary,
                loading: _submitting,
                onPressed: _canSubmit
                    ? (widget.isEdit ? _submitEdit : _submitSignup)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
