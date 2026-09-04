import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/app_sheet_layout.dart';
import '../../../shared/widgets/app_sheet_shell.dart';

/// App-wide explainer of how scoring, formal assessments, quick
/// feedback, and tiering work. Opened from a "How it works" button
/// on any surface that shows scores — currently the DVLP → skill
/// detail sheet.
///
/// Pure UI. No data fetching. When more explainer sheets land
/// (glossary, tier detail, etc.), they can live alongside this file
/// in `features/help/ui/`.
///
/// Level band values here are the mirror of the
/// `level_band_thresholds` migration. Keep in sync — if the DB
/// values change, update the [_bands] list below.
class HowItWorksSheet extends StatelessWidget {
  const HowItWorksSheet({super.key});

  // Band → range mapping. Colors + display names come from the
  // shared [LevelBand] extension so this row list stays a pure
  // "which band, what range" declaration.
  //
  // Ranges here mirror the level_band_thresholds migration values.
  // Keep in sync when the DB values change.
  static const List<(LevelBand, String)> _bands = [
    (LevelBand.beginner, '<4.0'),
    (LevelBand.bronze,   '4.0 – 5.9'),
    (LevelBand.silver,   '6.0 – 7.4'),
    (LevelBand.gold,     '7.5 – 8.9'),
    (LevelBand.elite,    '9.0 – 10.0'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppSheetLayout(
      title: 'How it Works',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            title: 'Overall Score',
            body: Text.rich(
              TextSpan(
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                children: [
                  const TextSpan(text: 'Overall score is '),
                  TextSpan(
                    text: 'only',
                    style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                  ),
                  const TextSpan(
                    text: ' determined by Formal Assessments completed by your coaches. It is also what determines your level. The levels are as follows:',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BandsTable(rows: _bands),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Formal Assessments',
            body: Text(
              "Formal Assessments are completed by coaches on a schedule (monthly, every other month, etc) and are a numerical score for each skill category. Your head coach's assessment is 50% of your overall score, Assistant coach is 25%, Spring/Summer coach is 15%, and any Skills coach is 10%.",
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Quick Feedback',
            body: Text(
              'Quick feedback is given to a player from a coach to show feedback on skills on a more regular basis. Players can request feedback from their coaches up to twice a week. These scores are a star rating and do not affect the overall score or level.',
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Tier',
            body: Text(
              "Your tier is graded against your current level only. A player's tier is never compared against a higher or lower level of play. For example, a AA player is graded against other AA players and a AAA player is graded against other AAA players. Your tier answers one question only: how do you compare to peers at your current level.",
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        body,
      ],
    );
  }
}

/// Two equal-width columns split by a vertical divider:
///   • Left  — colored gradient dot + band name (left-aligned)
///   • Right — score range (center-aligned)
/// Rows separated by a horizontal divider. Matches the Figma treatment.
class _BandsTable extends StatelessWidget {
  const _BandsTable({required this.rows});
  final List<(LevelBand, String)> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        border: Border.all(color: colors.alternate),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _BandDot(color: rows[i].$1.color),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            rows[i].$1.displayName,
                            style: AppTypography.titleSmall.copyWith(color: colors.primaryText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(width: 1, thickness: 1, color: colors.alternate),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Center(
                        child: Text(
                          rows[i].$2,
                          style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(height: 1, thickness: 1, color: colors.alternate),
          ],
        ],
      ),
    );
  }
}

/// Small colored disc with a top-left highlight → base color radial
/// gradient so it reads as a sphere/coin rather than a flat dot.
/// Matches the Figma treatment on the "How it Works" bands table.
class _BandDot extends StatelessWidget {
  const _BandDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Highlight is the base color pushed toward white; shadow is the
    // base color pushed toward black. Same math for every band so all
    // five dots share a consistent depth treatment.
    final highlight = Color.lerp(color, Colors.white, 0.35)!;
    final shadow = Color.lerp(color, Colors.black, 0.15)!;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: [highlight, color, shadow],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

/// Convenience opener. Callers don't need to know about the widget
/// class or showAppSheet.
Future<void> showHowItWorksSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => const HowItWorksSheet(),
  );
}
