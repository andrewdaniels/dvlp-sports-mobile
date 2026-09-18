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
import '../../features/auth/data/profile_repository.dart';
import '../../features/auth/ui/sheets/guardian_email_sheet.dart';
import '../../features/reference/controllers/reference_providers.dart';
import '../../generated/api/get_positions.dart';
import '../../generated/api/get_profile.dart' as gp;
import '../../shared/util/avatar_picker.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_select_trigger.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_wheel_picker.dart';

/// Local for now — hoist to shared enum if a second screen needs it.
///
/// Hockey uses "shoots left" / "shoots right"; the DB enum still
/// includes `ambidextrous` but we intentionally don't surface it here
/// (product decision — no meaningful shooting-side ambiguity in hockey).
/// Add back if we introduce a sport where it applies.
enum _DominantSide { left, right }

extension on _DominantSide {
  String get label {
    switch (this) {
      case _DominantSide.left:
        return 'Left';
      case _DominantSide.right:
        return 'Right';
    }
  }
}

/// Player (athlete) account form. Two modes:
///
///  - Signup ([isEdit] false): fields blank / invite-prefilled, submit
///    calls create-profile + signs in + routes to landing.
///  - Edit ([isEdit] true): fields seeded from currentProfileProvider,
///    submit calls update-profile + pops. The under-18 guardian-email
///    sheet is signup-only (age gate is only meaningful at signup).
class PlayerAccountPage extends ConsumerStatefulWidget {
  const PlayerAccountPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  ConsumerState<PlayerAccountPage> createState() => _PlayerAccountPageState();
}

class _PlayerAccountPageState extends ConsumerState<PlayerAccountPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();

  int? _heightFt;
  int? _heightIn;
  int? _weightLbs;
  PositionElement? _position;
  _DominantSide? _dominantSide;
  DateTime? _dob;
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
    if (profile.dateOfBirth != null) {
      _dob = DateTime.tryParse(profile.dateOfBirth!);
    }
    _existingAvatarUrl = profile.avatarUrl;

    final details = profile.athleteDetails;
    if (details != null) {
      final h = details.heightCm;
      if (h != null) {
        // cm → total inches (rounded) → ft/in
        final totalIn = (h / 2.54).round();
        _heightFt = totalIn ~/ 12;
        _heightIn = totalIn % 12;
      }
      final w = details.weightKg;
      if (w != null) _weightLbs = (w / 0.453592).round();
      switch (details.dominantSide) {
        case gp.DominantSide.LEFT:
          _dominantSide = _DominantSide.left;
        case gp.DominantSide.RIGHT:
          _dominantSide = _DominantSide.right;
        case _:
          _dominantSide = null;
      }
      // Position is matched from the positions list once it loads —
      // see build() below.
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _pickHeightFt() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      title: 'Height (ft)',
      items: List.generate(6, (i) => i + 3),
      itemLabel: (v) => '$v ft',
      initialItem: _heightFt ?? 5,
    );
    if (result != null && mounted) setState(() => _heightFt = result);
  }

  Future<void> _pickHeightIn() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      title: 'Height (in)',
      items: List.generate(12, (i) => i),
      itemLabel: (v) => '$v in',
      initialItem: _heightIn ?? 6,
    );
    if (result != null && mounted) setState(() => _heightIn = result);
  }

  Future<void> _pickWeight() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      title: 'Weight',
      items: List.generate(311, (i) => i + 40),
      itemLabel: (v) => '$v lbs',
      initialItem: _weightLbs ?? 140,
    );
    if (result != null && mounted) setState(() => _weightLbs = result);
  }

  Future<void> _pickPosition() async {
    final async = ref.read(positionsProvider);
    final positionsData = async.valueOrNull;
    if (positionsData == null || positionsData.positions.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Positions still loading — try again in a moment.',
      );
      return;
    }
    final result = await showAppWheelPicker<PositionElement>(
      context: context,
      title: 'Position',
      items: positionsData.positions,
      itemLabel: (p) => p.name,
      initialItem: _position ?? positionsData.positions.first,
    );
    if (result != null && mounted) setState(() => _position = result);
  }

  Future<void> _pickDominantSide() async {
    final result = await showAppWheelPicker<_DominantSide>(
      context: context,
      title: 'Shot',
      items: _DominantSide.values,
      itemLabel: (v) => v.label,
      initialItem: _dominantSide ?? _DominantSide.right,
    );
    if (result != null && mounted) setState(() => _dominantSide = result);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final result = await showAppDatePicker(
      context: context,
      title: 'Date of Birth',
      initialDate: _dob ?? DateTime(now.year - 15, 6, 15),
      minimumDate: DateTime(now.year - 60),
      maximumDate: DateTime(now.year - 3),
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
      setState(() => _errorText = 'Please enter your first and last name.');
      return;
    }
    if (_dob == null) {
      setState(() => _errorText = 'Please select your date of birth.');
      return;
    }

    if (widget.isEdit) {
      await _submitEdit(firstName, lastName);
    } else {
      await _submitSignup(firstName, lastName);
    }
  }

  int? _heightCmFromInputs() {
    if (_heightFt == null && _heightIn == null) return null;
    return (((_heightFt ?? 0) * 12 + (_heightIn ?? 0)) * 2.54).round();
  }

  int? _weightKgFromInputs() =>
      _weightLbs == null ? null : (_weightLbs! * 0.453592).round();

  Future<void> _submitEdit(String firstName, String lastName) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final result = await ref.read(profileRepositoryProvider).updateProfile(
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: _formatIsoDate(_dob!),
          avatarBase64: _avatarBase64,
          athleteDetails: UpdateProfileAthleteDetailsPatch(
            heightCm: _heightCmFromInputs(),
            weightKg: _weightKgFromInputs(),
            dominantSide: _dominantSide?.name,
            positionId: _position?.id,
          ),
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

  Future<void> _submitSignup(String firstName, String lastName) async {
    final ctx = ref.read(signupFlowProvider);
    if (ctx == null) {
      context.go(RouteNames.entry);
      return;
    }
    if (ctx.email == null || ctx.password == null) {
      setState(() => _errorText = 'Credentials missing — please go back and try again.');
      return;
    }

    // Age gate: under-18 athletes must supply a guardian email before
    // signup. Server enforces the same gate — this is UX.
    String? guardianEmail;
    if (_computeAgeYears(_dob!) < 18) {
      guardianEmail = await showGuardianEmailSheet(context: context);
      if (!mounted) return;
      if (guardianEmail == null) {
        // Athlete dismissed the sheet — bail silently.
        return;
      }
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final result = await ref.read(profileRepositoryProvider).createAthlete(
          email: ctx.email!,
          password: ctx.password!,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: _formatIsoDate(_dob!),
          inviteId: ctx.inviteId,
          heightCm: _heightCmFromInputs(),
          weightKg: _weightKgFromInputs(),
          dominantSide: _dominantSide?.name,
          positionId: _position?.id,
          guardianEmail: guardianEmail,
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

  static String _landingFor(gp.RoleTier? role) => switch (role) {
        gp.RoleTier.COACH => RouteNames.coachHome,
        null => RouteNames.splash,
        _ => RouteNames.athletePassport,
      };

  static String _formatIsoDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  /// Whole-years age at today's date. Mirrors the server's helper in
  /// create-profile/index.ts so client + server agree on the under-18
  /// cutoff.
  static int _computeAgeYears(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    final beforeBirthday = now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day);
    if (beforeBirthday) age--;
    return age < 0 ? 0 : age;
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

    final ctx = ref.watch(signupFlowProvider);
    final lockedFromInvite = ctx?.fromInvite ?? false;
    // Only lock invite-prefilled fields during signup — in edit mode
    // the user can freely rename themselves.
    final lockFirst = !widget.isEdit &&
        lockedFromInvite &&
        (ctx?.firstName?.isNotEmpty ?? false);
    final lockLast = !widget.isEdit &&
        lockedFromInvite &&
        (ctx?.lastName?.isNotEmpty ?? false);

    final positionsAsync = ref.watch(positionsProvider);
    final positionsLoading = positionsAsync.isLoading;

    // Edit mode: once positions load, seed the picker from the
    // profile's stored position id.
    if (widget.isEdit && _position == null) {
      final positions = positionsAsync.valueOrNull?.positions ?? const [];
      final profilePositionId = ref
          .read(currentProfileProvider)
          .value
          ?.athleteDetails
          ?.position
          ?.id;
      if (profilePositionId != null) {
        for (final p in positions) {
          if (p.id == profilePositionId) {
            _position = p;
            break;
          }
        }
      }
    }

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
                              enabled: !lockFirst,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: 'Last Name',
                              placeholder: 'Enter last name',
                              controller: _last,
                              enabled: !lockLast,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _FieldLabel('Height'),
                            const SizedBox(height: AppSpacing.xxs),
                            Row(
                              children: [
                                Expanded(
                                  child: AppSelectTrigger(
                                    placeholder: 'ft',
                                    value: _heightFt == null ? null : '$_heightFt ft',
                                    onTap: _pickHeightFt,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppSelectTrigger(
                                    placeholder: 'in',
                                    value: _heightIn == null ? null : '$_heightIn in',
                                    onTap: _pickHeightIn,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: AppSelectTrigger(
                                    label: 'Weight',
                                    placeholder: 'Select weight',
                                    value: _weightLbs == null ? null : '$_weightLbs lbs',
                                    onTap: _pickWeight,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppSelectTrigger(
                                    label: 'Date of Birth',
                                    placeholder: 'Select date',
                                    value: _dob == null ? null : _formatDob(_dob!),
                                    onTap: _pickDob,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppSelectTrigger(
                              label: 'Position',
                              placeholder: positionsLoading ? 'Loading positions…' : 'Select Position',
                              value: _position?.name,
                              onTap: positionsLoading ? null : _pickPosition,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppSelectTrigger(
                              label: 'Shot',
                              placeholder: 'Select side',
                              value: _dominantSide?.label,
                              onTap: _pickDominantSide,
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
                label: secondaryLabel,
                variant: AppButtonVariant.outline,
                onPressed: _submitting ? null : _back,
              ),
              primary: AppButton(
                label: primaryLabel,
                variant: AppButtonVariant.primary,
                loading: _submitting,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(color: context.colors.secondaryText),
      ),
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
