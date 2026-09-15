import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_coach_feedback_summary.dart';
import '../../../../shared/widgets/app_card.dart';
import 'pending_athlete_row.dart';

/// Coach Feedback hero — formal-cadence progress against the current
/// period, plus the list of athletes still needing an assessment.
///
/// Layout:
///   ┌─── (gold border, xxl radius) ───────────────────┐
///   │  0/6                          (display-size)    │
///   │  Players evaluated this cycle                   │
///   │  ▓▓▓▓▓░░░░░░░░░ (progress bar)                   │
///   ├─────────────────────────────────────────────────┤  ← full-bleed divider
///   │  (avatar) M. Thompson       Review    ›         │
///   ├─────────────────────────────────────────────────┤
///   │  (avatar) A. Kim            Review    ›         │
///   └─────────────────────────────────────────────────┘
///
/// Progress bar color is yellow while any athletes are still pending
/// (indicating "in progress") and flips green when the coach has
/// covered the full roster (indicating "done"). Empty pending list
/// hides the tile list entirely.
///
/// Card padding is vertical-only so the dividers can bleed to the
/// card's edges (matches the design). Non-divider children carry
/// their own horizontal padding via [_horizontalPad].
///
/// Pending rows are bare inline rows so the trailing chevrons align
/// vertically with the Requests / Completed section chevrons on the
/// page (both siblings use the outer AppCard padding as the only
/// right-edge inset).
///
/// The `onAthleteTap` callback fires per pending row so the parent
/// owns navigation — Branch 1 sends it to the athlete details page;
/// Branch 2 will redirect to the formal composer.
class CadenceHeroCard extends StatelessWidget {
  const CadenceHeroCard({
    super.key,
    required this.cadence,
    this.onAthleteTap,
  });

  final FormalCadence cadence;
  final void Function(PendingAthlete athlete)? onAthleteTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = cadence.totalAthletes;
    final completed = cadence.completedCount;
    final fraction = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final isComplete = total > 0 && completed >= total;
    final barFill = isComplete ? colors.success : colors.secondary;
    final pending = cadence.pendingAthletes;

    return AppCard(
      variant: AppCardVariant.featured,
      prominent: true,
      // Vertical padding is asymmetric because the last pending row
      // supplies its own `sm` bottom padding — an md bottom on the
      // card would compound that into visible dead space. Zero here
      // lets the row's own padding be the only buffer.
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _horizontalPad(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$completed/$total',
                  style: AppTypography.headlineLarge.copyWith(color: colors.primaryText),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Players evaluated ${cadence.period.label}',
                  style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProgressBar(fraction: fraction, fill: barFill, track: colors.alternate),
              ],
            ),
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            // First divider (between progress section and the first
            // pending row) is full-bleed — separates the two zones of
            // the hero.
            Divider(color: colors.alternate, height: 1),
            for (var i = 0; i < pending.length; i++) ...[
              // Right padding is 2px shy of the header's `md` so the
              // pending row's trailing chevron optically aligns with
              // the chevrons on the Requests / Completed rows below.
              // Those rows sit inside AppCards with a 1px border; the
              // hero uses `prominent` (2px), and pull-to-refresh /
              // scrollbar affordances push things a touch further.
              // 2px is what looks right on the sim.
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md - 2,
                ),
                child: PendingAthleteRow(
                  entry: pending[i],
                  onTap: onAthleteTap == null
                      ? null
                      : () => onAthleteTap!(pending[i]),
                ),
              ),
              // Between-row dividers indent past the avatar column so
              // they read as list separators (Material list pattern),
              // while still bleeding to the card's right edge.
              // Indent = card horizontal padding (md=16) + avatar
              // width (small=32) + gap after avatar (md=16) = 64.
              if (i < pending.length - 1)
                Divider(color: colors.alternate, height: 1, indent: 64),
            ],
          ],
        ],
      ),
    );
  }

  /// Applies the card's horizontal inset to a single child so dividers
  /// (which live outside this wrapper) can bleed to the card's edges.
  static Widget _horizontalPad(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: child,
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.fraction,
    required this.fill,
    required this.track,
  });

  final double fraction;
  final Color fill;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: 8, color: track),
          FractionallySizedBox(
            widthFactor: fraction,
            child: Container(height: 8, color: fill),
          ),
        ],
      ),
    );
  }
}
