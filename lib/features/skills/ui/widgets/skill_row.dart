import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_skill_progress.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';

/// One skill row for the DVLP list.
///
/// Layout:
///   ┌────────────────────────────────────────────────┐
///   │ Skill title                    +0.4 · 7.6 · ›  │  ← trailing centered
///   │ Skill description                              │
///   │ ├──filled──▶ · · · · · · · · · · · · · · · · ┤  │  ← thin progress bar
///   └────────────────────────────────────────────────┘
///
/// Reads a single [Skill] response object + [ScoreScale] for the max.
/// Delta sign drives color: positive → success, negative → error,
/// zero/null → secondaryText.
///
/// Feature-scoped (skills). Nothing here is shared with the assessment
/// detail page's ScoreGauge — different visual (single-tone fill vs
/// full band gradient) and different context (list row vs hero row).
class SkillRow extends StatelessWidget {
  const SkillRow({
    super.key,
    required this.skill,
    required this.scoreScale,
    this.onTap,
  });

  final Skill skill;
  final ScoreScale scoreScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDescription = (skill.skillDescription ?? '').trim().isNotEmpty;
    final fraction = (skill.currentScore / scoreScale.max).clamp(0.0, 1.0);
    // One dot per interior whole-number step (skip 0 + max — they sit
    // under the pill's rounded ends).
    final tickCount = (scoreScale.max.round() - 1).clamp(0, 1 << 30);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              // Center the delta / score / chevron cluster against the
              // title + description column.
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill.skillName,
                        style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                      ),
                      if (hasDescription) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          skill.skillDescription!,
                          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _DeltaLabel(delta: skill.delta),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatScore(skill.currentScore),
                  style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                ),
                const SizedBox(width: AppSpacing.xs),
                const AppChevronRight(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MiniProgressBar(fraction: fraction, tickCount: tickCount),
          ],
        ),
      ),
    );
  }

  static String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({required this.delta});
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (delta == null) {
      return Text(
        '—',
        style: AppTypography.boldSmall.copyWith(color: colors.secondaryText),
      );
    }
    final positive = delta! > 0;
    final negative = delta! < 0;
    final color = positive
        ? colors.success
        : negative
            ? colors.error
            : colors.secondaryText;
    final sign = positive ? '+' : '';
    return Text(
      '$sign${delta!.toStringAsFixed(1)}',
      style: AppTypography.boldSmall.copyWith(color: color),
    );
  }
}

/// Thin single-tone progress bar with dot notches at whole-number
/// steps. Fill length = fraction × width. Empty portion uses the
/// alternate surface color. Feature-local (not shared) — the
/// assessment detail's ScoreGauge uses a full band gradient which is
/// a different visual language.
class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({required this.fraction, required this.tickCount});
  final double fraction;
  final int tickCount;

  static const double _height = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // CustomPaint has no intrinsic width — inside a Column it would
    // collapse to zero. `double.infinity` forces it to fill the card's
    // content width.
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: CustomPaint(
        painter: _MiniBarPainter(
          fraction: fraction,
          tickCount: tickCount,
          fillColor: colors.secondary,
          trackColor: colors.alternate,
        ),
      ),
    );
  }
}

class _MiniBarPainter extends CustomPainter {
  const _MiniBarPainter({
    required this.fraction,
    required this.tickCount,
    required this.fillColor,
    required this.trackColor,
  });

  final double fraction;
  final int tickCount;
  final Color fillColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(trackRect, Paint()..color = trackColor);

    if (fraction > 0) {
      final fillWidth = size.width * fraction;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        radius,
      );
      canvas.drawRRect(fillRect, Paint()..color = fillColor);
    }

    // Dot notches: dark low-opacity circles at each interior
    // whole-number step. Same "recessed pinhole" treatment as the
    // ScoreGauge on the detail page.
    if (tickCount > 0) {
      final dotPaint = Paint()..color = Colors.black.withValues(alpha: 0.32);
      final dotRadius = size.height * 0.18;
      final segments = tickCount + 1;
      for (var i = 1; i <= tickCount; i++) {
        final x = size.width * (i / segments);
        canvas.drawCircle(Offset(x, size.height / 2), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.tickCount != tickCount ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.trackColor != trackColor;
}
