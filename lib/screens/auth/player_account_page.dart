import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_onboarding_header.dart';
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
class PlayerAccountPage extends StatefulWidget {
  const PlayerAccountPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<PlayerAccountPage> createState() => _PlayerAccountPageState();
}

class _PlayerAccountPageState extends State<PlayerAccountPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();

  int? _heightFt;
  int? _heightIn;
  int? _weightLbs;
  String? _position;
  _DominantSide? _dominantSide;
  int? _dobMonth;
  int? _dobDay;
  int? _dobYear;

  static const _positions = ['Goalie', 'Forward', 'Defense'];
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _pickHeightFt() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      items: List.generate(6, (i) => i + 3), // 3–8
      itemLabel: (v) => '$v ft',
      initialItem: _heightFt,
    );
    if (result != null && mounted) setState(() => _heightFt = result);
  }

  Future<void> _pickHeightIn() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      items: List.generate(12, (i) => i), // 0–11
      itemLabel: (v) => '$v in',
      initialItem: _heightIn,
    );
    if (result != null && mounted) setState(() => _heightIn = result);
  }

  Future<void> _pickWeight() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      items: List.generate(311, (i) => i + 40), // 40–350
      itemLabel: (v) => '$v lbs',
      initialItem: _weightLbs,
    );
    if (result != null && mounted) setState(() => _weightLbs = result);
  }

  Future<void> _pickPosition() async {
    final result = await showAppWheelPicker<String>(
      context: context,
      items: _positions,
      itemLabel: (v) => v,
      initialItem: _position,
    );
    if (result != null && mounted) setState(() => _position = result);
  }

  Future<void> _pickMonth() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      items: List.generate(12, (i) => i + 1),
      itemLabel: (v) => _monthLabels[v - 1],
      initialItem: _dobMonth,
    );
    if (result != null && mounted) setState(() => _dobMonth = result);
  }

  Future<void> _pickDay() async {
    final result = await showAppWheelPicker<int>(
      context: context,
      items: List.generate(31, (i) => i + 1),
      itemLabel: (v) => '$v',
      initialItem: _dobDay,
    );
    if (result != null && mounted) setState(() => _dobDay = result);
  }

  Future<void> _pickYear() async {
    // 1970 → current year. Wheel starts at the most recent year selected.
    final now = DateTime.now().year;
    final years = List.generate(now - 1969, (i) => now - i);
    final result = await showAppWheelPicker<int>(
      context: context,
      items: years,
      itemLabel: (v) => '$v',
      initialItem: _dobYear,
    );
    if (result != null && mounted) setState(() => _dobYear = result);
  }

  void _selectDominantSide(_DominantSide side) {
    HapticFeedback.selectionClick();
    setState(() => _dominantSide = side);
  }

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

  void _next() {
    // TODO(task #28): submit profile via auth repository, then navigate
    // based on auth state.
    context.go(RouteNames.passport);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryLabel = widget.isEdit ? 'Save' : 'Next';
    final secondaryLabel = widget.isEdit ? 'Cancel' : 'Back';

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
                      _PhotoRow(onUpload: _uploadPhoto),
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
                      AppSelectTrigger(
                        label: 'Weight',
                        placeholder: 'Enter weight',
                        value: _weightLbs == null ? null : '$_weightLbs lbs',
                        onTap: _pickWeight,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppSelectTrigger(
                        label: 'Position',
                        placeholder: 'Select Position',
                        value: _position,
                        onTap: _pickPosition,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FieldLabel('Dominant Side'),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          for (final side in _DominantSide.values) ...[
                            Expanded(
                              child: _DominantSideOption(
                                label: side.label,
                                selected: _dominantSide == side,
                                onTap: () => _selectDominantSide(side),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FieldLabel('Date of Birth'),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Expanded(
                            child: AppSelectTrigger(
                              placeholder: 'Month',
                              value: _dobMonth == null ? null : _monthLabels[_dobMonth! - 1],
                              onTap: _pickMonth,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppSelectTrigger(
                              placeholder: 'Day',
                              value: _dobDay == null ? null : '$_dobDay',
                              onTap: _pickDay,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppSelectTrigger(
                              placeholder: 'Year',
                              value: _dobYear == null ? null : '$_dobYear',
                              onTap: _pickYear,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: secondaryLabel,
                      variant: AppButtonVariant.outline,
                      expand: true,
                      onPressed: _back,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: primaryLabel,
                      variant: AppButtonVariant.primary,
                      expand: true,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
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
  const _PhotoRow({required this.onUpload});
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.secondaryBackground,
            border: Border.all(color: colors.alternate, width: 1),
          ),
          child: Center(
            child: AppIcon(AppIcons.image, size: 24, color: colors.secondaryText),
          ),
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

class _DominantSideOption extends StatelessWidget {
  const _DominantSideOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.secondary : colors.alternate,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.secondary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
