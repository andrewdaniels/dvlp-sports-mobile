import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/assessments/controllers/assessments_providers.dart';
import '../../../features/assessments/ui/widgets/app_feedback_list_item.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/skills/controllers/skills_providers.dart';
import '../../../features/skills/ui/sheets/skill_detail_sheet.dart';
import '../../../features/skills/ui/widgets/skill_row.dart';
import '../../../features/team/ui/widgets/coach_athlete_passport_card.dart';
import '../../../generated/api/get_assessments.dart' as assessments_api;
import '../../../generated/api/get_profile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_detail_app_bar.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_screen_footer.dart';

/// Coach's view of a single athlete — reached by tapping any row in
/// the coach Team page (own-team roster or external connection).
///
/// Composes:
///   - AppDetailAppBar
///   - CoachAthletePassportCard from athleteProfileProvider(athleteId)
///     (falls back to a minimal placeholder if the profile is still
///     loading so the page has structure immediately)
///   - Categories section: reuses SkillRow, reads skillProgressProvider
///     (athleteId). Same cache the athlete's own DVLP page uses.
///   - Feedback History section: reuses AppFeedbackListItem, reads
///     assessmentsProvider(athleteId). Same cache the athlete's own
///     Passport / My Feedback pages use.
///   - Yellow featured "Quick Feedback" CTA (stubbed for this branch —
///     wire the composer sheet on a follow-up).
///
/// Backend enforces coach_can_access_athlete on all three endpoints,
/// so a coach without an active team_coaches / external_coach_grant
/// relationship gets 403s and this page renders empty states.
class CoachAthleteDetailsPage extends ConsumerWidget {
  const CoachAthleteDetailsPage({
    super.key,
    required this.athleteId,
    this.initialRanking,
  });

  final String athleteId;

  /// Passed via GoRouter `state.extra` from the roster / external row
  /// that navigated here. Lets the passport card render the ranking
  /// coin immediately without an extra fetch (roster already has it).
  final AthletePassportRanking? initialRanking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(athleteProfileProvider(athleteId));

    return Scaffold(
      appBar: const AppDetailAppBar(title: 'Athlete Details'),
      body: profileAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const _EmptyProfile(),
        data: (profile) => profile == null
            ? const _EmptyProfile()
            : _Body(
                athleteId: athleteId,
                profile: profile,
                ranking: initialRanking,
              ),
      ),
      bottomNavigationBar: AppScreenFooter.single(
        primary: AppButton(
          label: 'Quick Feedback',
          variant: AppButtonVariant.primary,
          onPressed: () {
            HapticFeedback.lightImpact();
            // Resolve the coach's team id (same lookup as other coach
            // surfaces) — required by the composer for score-scale +
            // authorization. If unavailable, silently no-op; the
            // button shouldn't render in a coach-less shell.
            final coachTeamId = ref
                .read(currentProfileProvider)
                .value
                ?.teamMemberships
                .where((m) => m.coachType != null)
                .firstOrNull
                ?.team
                .id;
            if (coachTeamId == null) return;
            context.push(RouteNames.feedbackQuickNewFor(
              athleteId: athleteId,
              teamId: coachTeamId,
            ));
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.athleteId,
    required this.profile,
    required this.ranking,
  });

  final String athleteId;
  final GetProfileData profile;
  final AthletePassportRanking? ranking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamLine = _composeTeamLine(profile);

    return AppRefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(athleteProfileProvider(athleteId).notifier).refresh(),
          ref.read(skillProgressProvider(athleteId).notifier).refresh(),
          ref.read(assessmentsProvider(athleteId).notifier).refresh(),
        ]);
      },
      child: ListView(
        padding: AppPageInsets.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CoachAthletePassportCard(
            profile: profile,
            teamLine: teamLine,
            // Ranking coin comes from the row that navigated here
            // (passed via GoRouter state.extra). Null when navigated
            // to via URL / deep link without a source row.
            ranking: ranking,
          ),
          const SizedBox(height: AppSpacing.xl),
          _CategoriesSection(athleteId: athleteId),
          const SizedBox(height: AppSpacing.xl),
          _FeedbackHistorySection(athleteId: athleteId),
        ],
      ),
    );
  }

  /// "Rampage U13 AAA | Forward" — matches the athlete passport line.
  static String _composeTeamLine(GetProfileData profile) {
    final membership = profile.teamMemberships.isNotEmpty
        ? profile.teamMemberships.first
        : null;
    final team = membership?.team;
    final positionName = profile.athleteDetails?.position?.name;

    final teamText = [
      team?.name.trim() ?? '',
      (team?.ageGroup ?? '').trim(),
      (team?.levelClassification ?? '').trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    if (teamText.isEmpty && (positionName == null || positionName.isEmpty)) {
      return '';
    }
    if (teamText.isEmpty) return positionName!;
    if (positionName == null || positionName.isEmpty) return teamText;
    return '$teamText | $positionName';
  }
}

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(skillProgressProvider(athleteId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Categories',
          style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          data: (data) {
            if (data == null || data.skills.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'No skill scores yet.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < data.skills.length; i++) ...[
                  SkillRow(
                    skill: data.skills[i],
                    scoreScale: data.scoreScale,
                    onTap: () => showSkillDetailSheet(
                      context,
                      skill: data.skills[i],
                      athleteId: athleteId,
                    ),
                  ),
                  if (i < data.skills.length - 1) const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: AppLoadingIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _FeedbackHistorySection extends ConsumerWidget {
  const _FeedbackHistorySection({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(assessmentsProvider(athleteId));
    final items = async.value?.assessments ?? const <assessments_api.Assessment>[];
    final loading = async.isLoading && items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Feedback History',
          style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: AppLoadingIndicator()),
          )
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'No feedback yet.',
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          )
        else
          for (var i = 0; i < items.length; i++) ...[
            AppFeedbackListItem(
              assessment: items[i],
              onTap: () {
                final a = items[i];
                final path =
                    a.assessmentType == assessments_api.AssessmentType.QUICK
                        ? RouteNames.feedbackQuickFor(a.id)
                        : RouteNames.feedbackFormalFor(a.id);
                context.push(path);
              },
            ),
            if (i < items.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: AppPageInsets.padding,
      child: Center(
        child: Text(
          'Could not load athlete profile.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
