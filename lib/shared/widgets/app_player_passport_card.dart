import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_avatar.dart';
import 'app_card.dart';

/// Featured passport card for a player's identity — two touching
/// sections inside a featured+prominent [AppCard]:
/// - Top: avatar + name row on an `alternate @ 40%` tint
/// - Bottom: 5-column stats grid (Age / Height / Weight / Hand /
///   Verified) on a solid `alternate` fill
///
/// [topInset] reserves vertical space at the top of the inner content
/// for a coin/badge that visually overlaps the card from above. Leave
/// at `0` when there is no overlay.
///
/// Primitive props only — feature code maps `Profile` → these strings
/// at the call site (unit conversions, team formatting). Firstname +
/// lastname are separate so [AppAvatar] can render initials when there
/// is no photo. Values not yet available (Verified) should be passed as
/// `'-'` — the widget never hides columns based on data.
class AppPlayerPassportCard extends StatelessWidget {
  const AppPlayerPassportCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.teamLine,
    required this.age,
    required this.height,
    required this.weight,
    required this.hand,
    required this.verified,
    this.avatarUrl,
    this.topInset = 0,
  });

  final String firstName;
  final String lastName;

  /// Team + level + position, e.g. "Rampage U13 AAA | Forward".
  final String teamLine;

  final String age;
  final String height;
  final String weight;
  final String hand;
  final String verified;
  final String? avatarUrl;

  /// Extra vertical space reserved at the top of the inner content, for
  /// a coin/badge that visually overlaps the card from above.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.featured,
      prominent: true,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (topInset > 0) SizedBox(height: topInset),
          Container(
            decoration: BoxDecoration(
              color: colors.alternate.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: _PlayerRow(
              firstName: firstName,
              lastName: lastName,
              teamLine: teamLine,
              avatarUrl: avatarUrl,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.alternate,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
            ),
            child: _StatsGrid(
              entries: [
                (label: 'AGE', value: age),
                (label: 'HEIGHT', value: height),
                (label: 'WEIGHT', value: weight),
                (label: 'SHOT', value: hand),
                (label: 'VERIFIED', value: verified),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.firstName,
    required this.lastName,
    required this.teamLine,
    this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String teamLine;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayName = _formatDisplayName(firstName, lastName);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            firstName: firstName,
            lastName: lastName,
            size: AppAvatarSize.medium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  teamLine,
                  style: AppTypography.boldSmall.copyWith(color: colors.secondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDisplayName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }
}

typedef _StatEntry = ({String label, String value});

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.entries});

  final List<_StatEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Expanded(child: _StatCell(label: e.label, value: e.value)),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.captionSemibold.copyWith(
            color: colors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(color: colors.primaryText),
        ),
      ],
    );
  }
}
