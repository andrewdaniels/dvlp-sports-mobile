import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_assessments.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';

/// Read-only list of the coaches who have submitted feedback for this
/// athlete. Opened from the "Verified Coaches" row on the profile
/// info card when tapped.
///
/// Consumers derive the list client-side from the already-loaded
/// `assessmentsProvider` (see profile_page.dart) — no new endpoint,
/// no new provider. This sheet just renders whatever list it's given
/// in the order the caller supplies. Present order is most-recent-
/// assessment-first so recency reads as relevance.
///
/// Row shape: avatar · coach name · role subtitle. Subtitle uses the
/// same "Role · External"-or-"Role · Team" formatting as the feedback
/// list rows so the athlete gets a consistent read of scope.
class VerifiedCoachesSheet extends StatelessWidget {
  const VerifiedCoachesSheet({super.key, required this.rows});

  final List<VerifiedCoachRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppSheetLayout(
      title: 'Verified Coaches',
      subtitle: rows.isEmpty
          ? null
          : 'Coaches who have submitted feedback for you',
      child: rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                'No verified coaches yet.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  _CoachTile(row: rows[i]),
                  if (i < rows.length - 1) const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }
}

/// Immutable per-row data the sheet renders. Derived from Assessment
/// data in the caller so this file has no dependency on the assessments
/// provider or its shape beyond the coach identity + role fields it
/// carries here.
class VerifiedCoachRow {
  const VerifiedCoachRow({
    required this.coachId,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.roleLabel,
    required this.contextLabel,
  });

  final String coachId;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  /// "Head Coach", "Skills Coach", etc. — derived from the coach's
  /// most-recent weighted_role for this athlete.
  final String roleLabel;
  /// The team the assessment(s) fell under, or "External" when the
  /// coach's most-recent contribution came via an external grant.
  final String contextLabel;
}

class _CoachTile extends StatelessWidget {
  const _CoachTile({required this.row});
  final VerifiedCoachRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = [row.roleLabel, row.contextLabel]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            imageUrl: row.avatarUrl,
            firstName: row.firstName,
            lastName: row.lastName,
            size: AppAvatarSize.small,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${row.firstName} ${row.lastName}'.trim(),
                  style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience opener — same pattern as the other sheet openers.
Future<void> showVerifiedCoachesSheet(
  BuildContext context, {
  required List<VerifiedCoachRow> rows,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => VerifiedCoachesSheet(rows: rows),
  );
}

// ─── Derivation helper ──────────────────────────────────────────────
// Kept here so the sheet + the profile page's row summary compute
// from the same source, and the projection rules (uniqueness key,
// ordering, role/context labels) live in one place.

/// Collapse a full assessment list into one row per unique coach,
/// ordered by most-recent submission first. For each unique coach:
///   - identity fields come from the coach on their most-recent row
///   - role comes from that row's `weighted_role`
///   - context is either the team name (team scope) or "External"
///
/// Assessment lists come in already sorted by `submitted_at desc` (see
/// get-assessments), so the first row we encounter per coach is
/// automatically their most-recent contribution.
List<VerifiedCoachRow> deriveVerifiedCoaches(List<Assessment> assessments) {
  final seen = <String, VerifiedCoachRow>{};
  for (final a in assessments) {
    if (seen.containsKey(a.coach.id)) continue;
    seen[a.coach.id] = VerifiedCoachRow(
      coachId: a.coach.id,
      firstName: a.coach.firstName,
      lastName: a.coach.lastName,
      avatarUrl: a.coach.avatarUrl,
      roleLabel: _roleLabel(a.weightedRole),
      contextLabel: a.accessScope == AccessScope.EXTERNAL
          ? 'External'
          : [
              a.team.name.trim(),
              (a.team.ageGroup ?? '').trim(),
              (a.team.levelClassification?.name ?? '').trim(),
            ].where((s) => s.isNotEmpty).join(' '),
    );
  }
  return seen.values.toList(growable: false);
}

String _roleLabel(WeightedRole role) => switch (role) {
      WeightedRole.HEAD_COACH => 'Head Coach',
      WeightedRole.ASSISTANT_COACH => 'Assistant Coach',
      WeightedRole.SKILLS_COACH => 'Skills Coach',
      WeightedRole.OFFSEASON_COACH => 'Offseason Coach',
    };
