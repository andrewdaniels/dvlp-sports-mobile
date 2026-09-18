import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/coach_feedback/controllers/coach_feedback_providers.dart';
import '../../../features/coach_feedback/ui/widgets/cadence_hero_card.dart';
import '../../../features/coach_feedback/ui/widgets/feedback_request_row.dart';
import '../../../features/coach_feedback/ui/widgets/recent_completion_row.dart';
import '../../../generated/api/get_coach_feedback_summary.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chevron_right.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';

/// Coach Feedback tab.
///   - Hero: CadenceHeroCard (formal-assessment cadence progress +
///     pending athlete rollup for the current period).
///   - Requests: pending quick-feedback requests submitted by athletes
///     targeted at this coach.
///   - Completed: last 10 assessments authored by this coach (mixed
///     quick + formal).
///
/// All data comes from a single get-coach-feedback-summary fetch —
/// lean payload, IDs only. Row taps navigate to existing pages:
///   - Pending/Request rows → CoachAthleteDetailsPage (this branch;
///     Branch 2 will redirect these to the composer)
///   - Completed rows → existing formal/quick viewer pages
class CoachFeedbackPage extends ConsumerWidget {
  const CoachFeedbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(coachFeedbackSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: async.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const _EmptyFailure(),
        data: (data) => data == null
            ? const _EmptyFailure()
            : _Body(summary: data),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.summary});
  final GetCoachFeedbackSummaryData summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = summary.quickFeedbackRequests;
    final externals = summary.formalNeededExternals;
    final completed = summary.recentCompleted;

    // Coach's active team for composer route wiring. Same resolution
    // as elsewhere (first coach-scope team_membership). Multi-team
    // coaches get a switcher on a follow-up branch.
    final coachTeamId = ref
        .watch(currentProfileProvider)
        .value
        ?.teamMemberships
        .where((m) => m.coachType != null)
        .firstOrNull
        ?.team
        .id;

    return AppRefreshIndicator(
      onRefresh: () =>
          ref.read(coachFeedbackSummaryProvider.notifier).refresh(),
      child: ListView(
        padding: AppPageInsets.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CadenceHeroCard(
            cadence: summary.formalCadence,
            onAthleteTap: (entry) {
              // Pending → formal composer route. Without team_id we
              // can't seed the composer, so fall back to the athlete
              // details page (Branch 1 stopgap).
              if (coachTeamId == null) {
                context.push(RouteNames.coachAthleteDetailsFor(entry.athlete.id));
                return;
              }
              context.push(RouteNames.feedbackFormalNewFor(
                athleteId: entry.athlete.id,
                teamId: coachTeamId,
              ));
            },
          ),
          if (requests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'Requests'),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < requests.length; i++) ...[
              FeedbackRequestRow(
                entry: requests[i],
                onTap: () {
                  // Request → quick composer, linked to the request
                  // so the server marks it completed on submit. team_id
                  // comes from the request itself — works for both
                  // own-roster requests (coach's team) and external
                  // requests (athlete's team). Was using the coach's
                  // own team_id which 403'd on externals.
                  context.push(RouteNames.feedbackQuickNewFor(
                    athleteId: requests[i].athlete.id,
                    teamId: requests[i].teamId,
                    requestId: requests[i].requestId,
                  ));
                },
              ),
              if (i < requests.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
          if (externals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'External Connections'),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < externals.length; i++) ...[
              _ExternalFormalRow(
                entry: externals[i],
                onTap: () {
                  // External → formal composer, using the team_id the
                  // server resolved from the athlete's primary team
                  // (external coach isn't on the athlete's team so we
                  // can't use the coach's own team_id here).
                  context.push(RouteNames.feedbackFormalNewFor(
                    athleteId: externals[i].athlete.id,
                    teamId: externals[i].teamId,
                  ));
                },
              ),
              if (i < externals.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
          if (completed.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'Recent Completed'),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < completed.length; i++) ...[
              RecentCompletionRow(
                entry: completed[i],
                onTap: () {
                  final e = completed[i];
                  final path = e.assessmentType == AssessmentType.QUICK
                      ? RouteNames.feedbackQuickFor(e.assessmentId)
                      : RouteNames.feedbackFormalFor(e.assessmentId);
                  context.push(path);
                },
              ),
              if (i < completed.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(color: context.colors.primaryText),
    );
  }
}

/// Inline row for the External Connections section. Same visual shape
/// as [FeedbackRequestRow] but the subtitle shows the athlete's team
/// name instead of a timestamp — external formals aren't tied to a
/// request or a cadence period, and the section header already implies
/// "these need feedback."
class _ExternalFormalRow extends StatelessWidget {
  const _ExternalFormalRow({required this.entry, this.onTap});

  final FormalNeededExternal entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = entry.athlete;
    final name = _formatName(a.firstName, a.lastName);

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
            AppAvatar(
              imageUrl: a.avatarUrl,
              firstName: a.firstName,
              lastName: a.lastName,
              size: AppAvatarSize.small,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    entry.teamName,
                    style: AppTypography.labelSmall.copyWith(color: colors.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }

  static String _formatName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }
}

class _EmptyFailure extends StatelessWidget {
  const _EmptyFailure();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: AppPageInsets.padding,
      child: Center(
        child: Text(
          'Could not load your feedback summary.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
