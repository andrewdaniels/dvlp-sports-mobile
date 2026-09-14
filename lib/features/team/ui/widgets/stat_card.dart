import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';

/// Small stat tile used in a horizontal row on the Team page.
/// Uppercase label on top, headline value below.
///
/// Used on:
///   - Athlete Team page — RECORD (from games) + RANKING (team standing).
///   - Coach Team page   — same pattern (both perspectives care about
///                         team record + ranking, not per-player state).
///
/// Ranking is styled with the `secondary` (gold) accent because it's
/// the marquee stat — record can be derived from the schedule; ranking
/// is a signal from an external standings source. Passing
/// `accent: true` gets that treatment.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;

  /// When true, renders the value in `secondary` (gold) instead of
  /// `primaryText`. Reserved for the marquee stat in a row (RANKING).
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.boldSmall.copyWith(
              color: colors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: accent ? colors.secondary : colors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
