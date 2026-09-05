import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_assessments.dart' as assessments_api;
import '../../../../generated/api/get_skill_progress.dart' as progress_api;
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';
import '../../../assessments/controllers/assessments_providers.dart';
import '../../../assessments/ui/widgets/app_feedback_list_item.dart';
import '../../../help/ui/how_it_works_sheet.dart';
import '../../controllers/skills_providers.dart';
import '../widgets/skill_trend_chart.dart';

/// Sheet content for the DVLP → tap-a-skill drill-in.
///
/// Composed of three pieces:
///   1. Header with the skill name + description.
///   2. Weighted-average trend chart for this skill (from
///      `skillHistoryProvider`).
///   3. Formal-only feedback list, client-filtered from the already-
///      loaded `assessmentsProvider`. Since every formal assessment
///      touches every skill, "filter by skill" degenerates to
///      "formal only" — no server round trip needed. Quick feedback
///      is intentionally excluded here because it doesn't feed the
///      weighted average shown on the chart.
///
/// Opened via [showSkillDetailSheet] which wraps `showAppSheet`. Use
/// that helper from callers so the sheet contract stays in one place.
class SkillDetailSheet extends ConsumerWidget {
  const SkillDetailSheet({
    super.key,
    required this.skill,
    required this.athleteId,
  });

  final progress_api.Skill skill;
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final historyAsync = ref.watch(skillHistoryProvider(skill.skillId));
    final assessmentsAsync = ref.watch(assessmentsProvider(athleteId));
    final formals = (assessmentsAsync.value?.assessments ?? const [])
        .where((a) => a.assessmentType == assessments_api.AssessmentType.FORMAL)
        .toList();

    return AppSheetLayout(
      title: skill.skillName,
      subtitle: skill.skillDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Trend chart ────────────────────────────────────
          historyAsync.when(
            data: (data) {
              if (data == null) {
                return _ChartFallback(
                  text: 'Trend not available yet.',
                  color: colors.secondaryText,
                );
              }
              return SkillTrendChart(
                points: data.points,
                scoreScale: data.scoreScale,
              );
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: AppLoadingIndicator()),
            ),
            error: (_, _) => _ChartFallback(
              text: 'Could not load trend.',
              color: colors.secondaryText,
            ),
          ),
          // ── How it works link ──────────────────────────────
          // Button provides its own vertical hit padding; keep the
          // surrounding gap small so the link reads as attached to
          // the chart above it, with the feedback list below.
          Center(
            child: AppButton(
              label: 'How it works',
              variant: AppButtonVariant.text,
              leadingIcon: AppIcons.messageQuestionSquare,
              onPressed: () => showHowItWorksSheet(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Formal feedback list ───────────────────────────
          if (formals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'No formal assessments yet.',
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
              ),
            )
          else
            for (var i = 0; i < formals.length; i++) ...[
              AppFeedbackListItem(
                assessment: formals[i],
                unread: !formals[i].athleteRead,
                onTap: () {
                  // Pop the sheet first so the detail page pushes
                  // onto the underlying navigator, not on top of
                  // the modal.
                  Navigator.of(context).pop();
                  context.push(RouteNames.feedbackFormalFor(formals[i].id));
                },
              ),
              if (i < formals.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _ChartFallback extends StatelessWidget {
  const _ChartFallback({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(text, style: AppTypography.bodyMedium.copyWith(color: color)),
      ),
    );
  }
}

/// Convenience opener so callers don't have to construct the sheet
/// widget + call showAppSheet + know the type of `T` themselves.
Future<void> showSkillDetailSheet(
  BuildContext context, {
  required progress_api.Skill skill,
  required String athleteId,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => SkillDetailSheet(skill: skill, athleteId: athleteId),
  );
}
