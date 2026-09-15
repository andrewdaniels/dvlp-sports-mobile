import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';

/// Formal-score picker for the coach composer.
///
/// 2-column grid of tinted score buttons, one per step from `min` to
/// `max` (inclusive). Each button is colored by the band that value
/// falls into (beginner / bronze / silver / gold / elite) so the coach
/// reads intent at a glance. The currently-selected value renders in
/// a filled state.
///
/// If the option count is odd, the last row holds a single
/// left-aligned cell (not centered) — matches the design mockup.
///
/// Returns the newly-picked score, or `null` if the coach dismisses
/// the sheet without picking.
Future<double?> showSkillScoreSelectorSheet({
  required BuildContext context,
  required String skillName,
  required double? currentScore,
  required double min,
  required double max,
  required double step,
}) {
  return showAppSheet<double>(
    context: context,
    builder: (context) => _SkillScoreSelectorSheet(
      skillName: skillName,
      currentScore: currentScore,
      min: min,
      max: max,
      step: step,
    ),
  );
}

class _SkillScoreSelectorSheet extends StatelessWidget {
  const _SkillScoreSelectorSheet({
    required this.skillName,
    required this.currentScore,
    required this.min,
    required this.max,
    required this.step,
  });

  final String skillName;
  final double? currentScore;
  final double min;
  final double max;
  final double step;

  @override
  Widget build(BuildContext context) {
    final options = _generateOptions(min, max, step);
    // 2-column grid; if odd, the last cell floats left in its own row.
    final rowCount = (options.length / 2).ceil();

    return AppSheetLayout(
      title: skillName,
      subtitle: 'Select a score',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rowCount; r++) ...[
            if (r > 0) const SizedBox(height: AppSpacing.sm),
            _optionRow(context, options, r, max),
          ],
        ],
      ),
    );
  }

  Widget _optionRow(
    BuildContext context,
    List<double> options,
    int rowIndex,
    double maxScore,
  ) {
    final leftIdx = rowIndex * 2;
    final rightIdx = leftIdx + 1;
    final hasRight = rightIdx < options.length;

    return Row(
      children: [
        Expanded(
          child: _ScoreOptionButton(
            score: options[leftIdx],
            selected: _isSelected(options[leftIdx]),
            maxScore: maxScore,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(options[leftIdx]);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: hasRight
              ? _ScoreOptionButton(
                  score: options[rightIdx],
                  selected: _isSelected(options[rightIdx]),
                  maxScore: maxScore,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(options[rightIdx]);
                  },
                )
              // Empty slot preserves the two-column layout so the last
              // row's single item lands under the left column, not
              // centered across the row.
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  bool _isSelected(double option) {
    if (currentScore == null) return false;
    return (currentScore! - option).abs() < 0.001;
  }

  /// Generates `[min, min+step, min+2*step, ..., max]`. Uses a small
  /// epsilon on the upper-bound check so floating-point drift doesn't
  /// clip the last option (e.g., 10.0 with step 0.5 accumulates tiny
  /// error over 20 iterations).
  static List<double> _generateOptions(double min, double max, double step) {
    final out = <double>[];
    for (var v = min; v <= max + 0.0001; v += step) {
      out.add(double.parse(v.toStringAsFixed(2)));
    }
    return out;
  }
}

/// Tinted score cell. Border always in the band color; background is
/// `color @ 15%` when selected and transparent otherwise. Text follows
/// the band color when unselected, primaryText when selected.
class _ScoreOptionButton extends StatelessWidget {
  const _ScoreOptionButton({
    required this.score,
    required this.selected,
    required this.maxScore,
    required this.onTap,
  });

  final double score;
  final bool selected;
  final double maxScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final band = levelBandForPct((score / maxScore).clamp(0.0, 1.0));
    final bandColor = band.color;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? bandColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(color: bandColor, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          _formatScore(score),
          style: AppTypography.titleMedium.copyWith(
            color: selected ? colors.primaryText : bandColor,
          ),
        ),
      ),
    );
  }

  static String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}
