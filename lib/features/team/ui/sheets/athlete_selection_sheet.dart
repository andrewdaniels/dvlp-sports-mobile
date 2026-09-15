import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_screen_footer.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';

/// Data-agnostic shape the sheet consumes. Callers map their own list
/// (roster row, external connection row, coach ref, whatever) to
/// these fields — keeps the sheet decoupled from any specific codegen
/// type so it can be reused for future selection surfaces (bulk
/// feedback send, event assignments, etc.).
class AthletePickerItem {
  const AthletePickerItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  String get _displayName {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }
}

/// Multi-select athlete picker. Returns the picked ids on Save, or
/// `null` if the coach dismisses without saving.
///
/// [maxSelectable] enforces a hard cap — when at the cap, tapping an
/// unselected row is a silent no-op (header copy makes the limit
/// obvious). Omit for unlimited selection.
///
/// Rows are sorted alphabetically by display name so athletes are
/// easy to scan regardless of the source list's order.
Future<List<String>?> showAthleteSelectionSheet({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<AthletePickerItem> athletes,
  Set<String> initiallySelected = const {},
  int? maxSelectable,
}) {
  final sorted = [...athletes]
    ..sort((a, b) => a._displayName.toLowerCase().compareTo(b._displayName.toLowerCase()));

  return showAppSheet<List<String>>(
    context: context,
    builder: (context) => _AthleteSelectionSheet(
      title: title,
      subtitle: subtitle,
      athletes: sorted,
      initiallySelected: initiallySelected,
      maxSelectable: maxSelectable,
    ),
  );
}

class _AthleteSelectionSheet extends StatefulWidget {
  const _AthleteSelectionSheet({
    required this.title,
    required this.subtitle,
    required this.athletes,
    required this.initiallySelected,
    required this.maxSelectable,
  });

  final String title;
  final String? subtitle;
  final List<AthletePickerItem> athletes;
  final Set<String> initiallySelected;
  final int? maxSelectable;

  @override
  State<_AthleteSelectionSheet> createState() => _AthleteSelectionSheetState();
}

class _AthleteSelectionSheetState extends State<_AthleteSelectionSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initiallySelected};
  }

  bool get _atCap =>
      widget.maxSelectable != null && _selected.length >= widget.maxSelectable!;

  /// Header subtitle is just the counter — no `Pick up to N` prefix
  /// (the cap is implied by "N of M"). Reads as "0 of 3 selected".
  String _selectionCopy() {
    final cap = widget.maxSelectable;
    if (cap == null) return '${_selected.length} selected';
    return '${_selected.length} of $cap selected';
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        if (_atCap) return; // silent no-op at cap
        _selected.add(id);
      }
    });
  }

  void _save() {
    HapticFeedback.mediumImpact();
    // Preserve alphabetical order in the returned list so callers
    // that render immediately (before a refetch) don't see a
    // reshuffle.
    final ordered = widget.athletes
        .where((a) => _selected.contains(a.id))
        .map((a) => a.id)
        .toList();
    Navigator.of(context).pop(ordered);
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetLayout(
      title: widget.title,
      subtitle: _selectionCopy(),
      footer: AppScreenFooter.single(
        primary: AppButton(
          label: 'Save',
          variant: AppButtonVariant.primary,
          // Force at least one selection. Coach can dismiss the
          // sheet to keep the existing set unchanged. If a "clear
          // all" case surfaces later, add a dedicated affordance.
          onPressed: _selected.isEmpty ? null : _save,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final a in widget.athletes)
            _SelectionRow(
              athlete: a,
              selected: _selected.contains(a.id),
              atCap: _atCap,
              onTap: () {
                HapticFeedback.lightImpact();
                _toggle(a.id);
              },
            ),
        ],
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.athlete,
    required this.selected,
    required this.atCap,
    required this.onTap,
  });

  final AthletePickerItem athlete;
  final bool selected;
  final bool atCap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // At cap + not currently selected → row reads as inactive.
    final dim = atCap && !selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppAvatar(
              imageUrl: athlete.avatarUrl,
              firstName: athlete.firstName,
              lastName: athlete.lastName,
              size: AppAvatarSize.small,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                athlete._displayName,
                style: AppTypography.boldLarge.copyWith(
                  color: dim ? colors.secondaryText : colors.primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _CheckSquare(selected: selected, dim: dim),
          ],
        ),
      ),
    );
  }
}

/// Same visual language as AppCheckbox — mirrors its box treatment
/// pixel-for-pixel (border, radius, filled state, check icon). Built
/// inline here rather than importing AppCheckbox because that widget
/// is fixed as "[box] label" (label to the RIGHT of the box), and
/// this consumer needs "content [box]" (checkbox trailing after the
/// row's content). Same primitive, different row arrangement.
///
/// If a second "trailing checkbox" consumer appears, promote this to
/// a shared `AppCheckboxBox` and have AppCheckbox compose it too.
class _CheckSquare extends StatelessWidget {
  const _CheckSquare({required this.selected, required this.dim});
  final bool selected;
  final bool dim;

  static const double _box = 22;
  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor =
        dim ? colors.secondaryText : colors.primaryText70;
    return Container(
      width: _box,
      height: _box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? colors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: selected
            ? null
            : Border.all(color: borderColor, width: 1.5),
      ),
      child: selected
          ? AppIcon(AppIcons.check, size: _iconSize, color: colors.persistDark)
          : null,
    );
  }
}
