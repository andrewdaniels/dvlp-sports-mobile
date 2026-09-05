import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/assessments/controllers/assessments_providers.dart';
import '../../features/assessments/ui/widgets/score_gauge.dart';
import '../../generated/api/get_assessment_detail.dart' as detail_api;
import '../../shared/widgets/app_audio_note.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_detail_app_bar.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

/// Detail view for a submitted formal assessment.
///
/// Same data source as [QuickFeedbackPage] — [assessmentDetailProvider]
/// keyed by [assessmentId]. Only the visualization differs: numeric
/// scores render as [ScoreGauge]s (bar + pointer + colored badge)
/// instead of star ratings.
class FormalAssessmentPage extends ConsumerWidget {
  const FormalAssessmentPage({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(assessmentDetailProvider(assessmentId));

    return Scaffold(
      appBar: AppDetailAppBar(
        title: 'Feedback',
        actions: [
          AppIconButton(
            icon: AppIcons.messageQuestionSquare,
            size: AppIconButtonSize.large,
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: open help sheet explaining formal-assessment scoring.
            },
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: () =>
            ref.read(assessmentDetailProvider(assessmentId).notifier).refresh(),
        child: async.when(
          data: (detail) => detail == null
              ? Center(
                  child: Text(
                    'Feedback not found.',
                    style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                  ),
                )
              : _DetailBody(detail: detail),
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (_, _) => Center(
            child: Text(
              'Something went wrong.',
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});
  final detail_api.Assessment detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: AppPageInsets.padding,
      children: [
        _CoachHeader(detail: detail),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < detail.scores.length; i++) ...[
          ScoreGauge(
            title: detail.scores[i].skillName,
            description: detail.scores[i].skillDescription,
            score: detail.scores[i].score.toDouble(),
            maxScore: detail.scoreScale.max.toDouble(),
            previousScore: detail.scores[i].previousScore?.toDouble(),
          ),
          if (i < detail.scores.length - 1) const SizedBox(height: AppSpacing.xl),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Text(
          "Coach's Note",
          style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppAudioNote(audioUrl: 'https://placeholder.invalid/audio.m4a'),
        if ((detail.notes ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            detail.notes!,
            style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
          ),
        ],
      ],
    );
  }
}

class _CoachHeader extends StatelessWidget {
  const _CoachHeader({required this.detail});
  final detail_api.Assessment detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final coach = detail.coach;
    final teamLine = [
      _roleLabel(detail.weightedRole),
      [
        detail.team.name.trim(),
        (detail.team.ageGroup ?? '').trim(),
        (detail.team.level ?? '').trim(),
      ].where((s) => s.isNotEmpty).join(' '),
    ].where((s) => s.isNotEmpty).join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: coach.avatarUrl,
          firstName: coach.firstName,
          lastName: coach.lastName,
          size: AppAvatarSize.medium,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Coach ${coach.firstName}',
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                teamLine,
                style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _roleLabel(detail_api.WeightedRole role) => switch (role) {
        detail_api.WeightedRole.HEAD_COACH => 'Head Coach',
        detail_api.WeightedRole.ASSISTANT_COACH => 'Assistant Coach',
        detail_api.WeightedRole.SKILLS_COACH => 'Skills Coach',
        detail_api.WeightedRole.OFFSEASON_COACH => 'Offseason Coach',
      };
}
