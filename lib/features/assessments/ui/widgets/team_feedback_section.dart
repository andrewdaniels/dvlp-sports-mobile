import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_assessments.dart';
import '../../../../shared/widgets/app_expandable_section.dart';
import 'app_feedback_list_item.dart';

/// One expandable section on the My Feedback page — a team's name
/// as the header, the count as subtitle, and the team's own
/// assessments (already-loaded from `assessmentsProvider`, filtered
/// down to this team's rows by the parent) rendered as
/// `AppFeedbackListItem`s when expanded.
///
/// Row tap routes to the correct detail page per `assessment_type`
/// — same routing pattern as Passport's Recent Feedback section.
class TeamFeedbackSection extends StatelessWidget {
  const TeamFeedbackSection({
    super.key,
    required this.teamName,
    required this.ageGroup,
    required this.levelName,
    required this.assessments,
    this.initiallyExpanded = false,
  });

  final String teamName;
  final String? ageGroup;
  final String? levelName;
  final List<Assessment> assessments;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    // Team display name — e.g., "Rampage U13 AAA" — using the same
    // ordering as the profile page (name → level, age already in name).
    final display = [teamName, levelName ?? ''].where((s) => s.trim().isNotEmpty).join(' ');

    return AppExpandableSection(
      title: display,
      subtitle: _countLabel(assessments.length),
      initiallyExpanded: initiallyExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < assessments.length; i++) ...[
            AppFeedbackListItem(
              assessment: assessments[i],
              unread: !assessments[i].athleteRead,
              onTap: () {
                final a = assessments[i];
                final path = a.assessmentType == AssessmentType.QUICK
                    ? RouteNames.feedbackQuickFor(a.id)
                    : RouteNames.feedbackFormalFor(a.id);
                context.push(path);
              },
            ),
            if (i < assessments.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  static String _countLabel(int n) => n == 1 ? '1 entry' : '$n entries';
}
