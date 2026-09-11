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
import '../../features/reference/controllers/reference_providers.dart';
import '../../generated/api/get_positions.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_select_trigger.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_wheel_picker.dart';

/// Local for now — hoist to shared enum if a second screen needs it.
enum _DominantSide { left, right, ambidextrous }

extension on _DominantSide {
  String get label {
    switch (this) {
      case _DominantSide.left:
        return 'Left';
      case _DominantSide.right:
        return 'Right';
      case _DominantSide.ambidextrous:
        return 'Ambidextrous';
    }
  }
}

/// Player account creation form.
///
/// [isEdit] flips the footer button labels (Back/Next → Cancel/Save) so
/// the same page can be reused in-app once we wire up profile editing.
/// Data loading + submission is left unwired for now.
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
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    // Seed name fields from invite/signup context if we have them.
    // initState runs once per widget lifecycle, so no guard needed.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Positions still loading — try again in a moment.')),
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
      title: 'Dominant Side',
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

  void _uploadPhoto() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload — coming later')),
    );
  }

  void _back() {
    HapticFeedback.lightImpact();
    context.pop();
  }

  /// Convert form data → create-profile payload → sign in → passport.
  Future<void> _submit() async {
    if (_submitting) return;

    final ctx = ref.read(signupFlowProvider);
    if (ctx == null) {
      // Landed here without going through the flow — bounce home.
      context.go(RouteNames.entry);
      return;
    }

    // Local validation: required fields not covered by input widgets.
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
    if (ctx.email == null || ctx.password == null) {
      setState(() => _errorText = 'Credentials missing — please go back and try again.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    // ft/in → cm, lbs → kg. Nulls preserved so backend stores as null.
    final heightCm = (_heightFt == null && _heightIn == null)
        ? null
        : (((_heightFt ?? 0) * 12 + (_heightIn ?? 0)) * 2.54).round();
    final weightKg = _weightLbs == null ? null : (_weightLbs! * 0.453592).round();

    final result = await ref.read(profileRepositoryProvider).createAthlete(
          email: ctx.email!,
          password: ctx.password!,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: _formatIsoDate(_dob!),
          inviteId: ctx.inviteId,
          heightCm: heightCm,
          weightKg: weightKg,
          dominantSide: _dominantSide?.name, // 'left' | 'right' | 'ambidextrous'
          positionId: _position?.id,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        // Store the freshly-created profile so downstream screens skip a fetch.
        ref.read(currentProfileProvider.notifier).optimisticSetFromCreate(data);

        // create-profile ran under service_role (admin) — mobile has no
        // session yet. Sign in with the credentials we just collected.
        try {
          await ref.read(authRepositoryProvider).signInWithPassword(
                email: ctx.email!,
                password: ctx.password!,
              );
        } catch (_) {
          // Profile exists but sign-in failed. Rare — user can log in manually.
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _errorText = 'Account created. Please sign in.';
          });
          return;
        }

        // Clear the signup context now that we're done with it.
        ref.read(signupFlowProvider.notifier).state = null;

        if (!mounted) return;
        // Chain profile fetch onto the same loading state so signup
        // → shell is one seamless transition. Falls back to splash if
        // the fetch fails so the user isn't stranded mid-loading.
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

  /// Mirrors [SplashPage._landingFor] — kept in sync with login_page so
  /// post-auth direct-nav and cold-boot splash agree per role. Null
  /// role falls back to splash to retry / show an error.
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryLabel = widget.isEdit ? 'Save' : 'Next';
    final secondaryLabel = widget.isEdit ? 'Cancel' : 'Back';

    // Fields coming from an invite are locked — the invite is the source
    // of truth for the invited person's name; user shouldn't retype it.
    final ctx = ref.watch(signupFlowProvider);
    final lockedFromInvite = ctx?.fromInvite ?? false;
    final lockFirst = lockedFromInvite && (ctx?.firstName?.isNotEmpty ?? false);
    final lockLast = lockedFromInvite && (ctx?.lastName?.isNotEmpty ?? false);

    // Trigger positions fetch on mount + track loading state. Riverpod
    // caches the result for the session; navigating away and back is free.
    final positionsAsync = ref.watch(positionsProvider);
    final positionsLoading = positionsAsync.isLoading;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              const AppOnboardingHeader(
                title: 'Your Account',
                subtitle: 'Enter the information below to create your account',
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
                        label: 'Dominant Side',
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
              AppScreenFooter.row(
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
    required this.onUpload,
  });

  final String firstName;
  final String lastName;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Falls back to initials from invite-prefilled name, or the
        // userFallback icon when nothing's typed yet. Both avatar and
        // button trigger upload — wider tap target.
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

