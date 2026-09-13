import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_games.dart';
import '../../../../shared/widgets/app_card.dart';

/// Compact card for an upcoming (scheduled, not-yet-played) game.
///
/// Rendered in a horizontal scroller on the coach Games page. Uses
/// the default plain AppCard variant — "upcoming" state is signaled
/// by the section header ("Upcoming") and the blue-tinted whenLine,
/// not the card border. Layout:
///
///   ┌──────────────────────┐
///   │ Saturday, 10:15 AM   │  ← weekday + time, link color
///   │ vs Sabers            │  ← opponent, primary text bold
///   │ Riverside Arena      │  ← location, secondary text
///   └──────────────────────┘
///
/// Fixed width so the card sits nicely in a horizontal ListView. Tap
/// forwards through `onTap` (game detail route TBD).
class UpcomingGameCard extends StatelessWidget {
  const UpcomingGameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  final Game game;
  final VoidCallback? onTap;

  static const double _width = 240;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final startsAt = DateTime.tryParse(game.startsAt)?.toLocal();
    final whenLine = startsAt == null ? '' : _formatWeekdayTime(startsAt);
    final opponentLine = '${game.isHome ? 'vs' : '@'} ${game.opponentName}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: SizedBox(
        width: _width,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                whenLine,
                style: AppTypography.boldSmall.copyWith(color: colors.link),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                opponentLine,
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                (game.location ?? '').isEmpty ? '-' : game.location!,
                style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// "Saturday, 10:15 AM"
String _formatWeekdayTime(DateTime dt) {
  final weekday = _weekdayNames[dt.weekday - 1];
  final hour24 = dt.hour;
  final ampm = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$weekday, $hour12:$mm $ampm';
}
