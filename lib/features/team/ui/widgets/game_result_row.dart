import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_games.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_game_result_badge.dart';

/// List row for a completed game — coach Games "Results" section.
///
/// Layout:
///
///   ┌────────────────────────────────────────────────┐
///   │ (W)  vs. Lakers                    4-2      ›  │
///   │      Feb 22                                    │
///   └────────────────────────────────────────────────┘
///
/// Model-aware: derives W/L/T from `teamScore` / `opponentScore`,
/// formats the date, prefixes opponent with `vs.` or `@` based on
/// `isHome`. Callers pass a [Game] and an optional [onTap] (for the
/// eventual game detail route).
///
/// Assumes the caller has already filtered to completed games (both
/// scores non-null). Bang-derefs the scores.
class GameResultRow extends StatelessWidget {
  const GameResultRow({
    super.key,
    required this.game,
    this.onTap,
  });

  final Game game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ts = game.teamScore!;
    final os = game.opponentScore!;
    final result = _resultFor(ts, os);
    final opponentLine = '${game.isHome ? 'vs.' : '@'} ${game.opponentName}';
    final startsAt = DateTime.tryParse(game.startsAt)?.toLocal();
    final dateLine = startsAt == null ? '' : _formatShortDate(startsAt);

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
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppGameResultBadge(result: result),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    opponentLine,
                    style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateLine,
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '$ts-$os',
              style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
            ),
            const SizedBox(width: AppSpacing.xs),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }

  static GameResult _resultFor(int team, int opponent) {
    if (team > opponent) return GameResult.win;
    if (team < opponent) return GameResult.loss;
    return GameResult.tie;
  }
}

const _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Feb 22"
String _formatShortDate(DateTime dt) => '${_monthAbbr[dt.month - 1]} ${dt.day}';
