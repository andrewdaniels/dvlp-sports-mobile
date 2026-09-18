import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/auth/controllers/signup_flow_provider.dart';
import '../../features/auth/data/api_result.dart';
import '../../shared/util/avatar_picker.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';

/// Coach account form.
///
///  - Signup ([isEdit] false): coach signup is invite-only. The Submit
///    button remains disabled today — coach create-profile path isn't
///    wired yet (see follow-up task).
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
    _phone.text = profile.phone ?? '';
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

  Future<void> _submitEdit() async {
    if (_submitting) return;
    final firstName = _first.text.trim();
    final lastName = _last.text.trim();
    final phone = _phone.text.trim();
    if (firstName.isEmpty) {
      setState(() => _errorText = 'Please enter your first name.');
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
          phone: phone.isEmpty ? null : phone,
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
    final primaryLabel = widget.isEdit ? 'Save' : 'Next';
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                      placeholder: 'Enter phone number',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
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
              horizontalPadding: AppSpacing.xl,
              secondary: AppButton(
                label: secondaryLabel,
                variant: AppButtonVariant.outline,
                onPressed: _submitting ? null : () => context.pop(),
              ),
              // Signup coach path isn't wired yet — the primary button
              // stays disabled in that mode. Edit mode is fully wired.
              primary: AppButton(
                label: primaryLabel,
                variant: AppButtonVariant.primary,
                loading: _submitting,
                onPressed: widget.isEdit ? _submitEdit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
