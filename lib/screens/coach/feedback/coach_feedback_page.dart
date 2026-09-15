import 'package:flutter/material.dart';
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
                  // so the server marks it completed on submit.
                  if (coachTeamId == null) {
                    context.push(
                      RouteNames.coachAthleteDetailsFor(requests[i].athlete.id),
                    );
                    return;
                  }
                  context.push(RouteNames.feedbackQuickNewFor(
                    athleteId: requests[i].athlete.id,
                    teamId: coachTeamId,
                    requestId: requests[i].requestId,
                  ));
                },
              ),
              if (i < requests.length - 1) const SizedBox(height: AppSpacing.sm),
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
