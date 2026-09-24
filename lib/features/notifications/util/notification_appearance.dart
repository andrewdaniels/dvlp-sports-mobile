import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../generated/api/get_notifications.dart' as gen;
import '../../../shared/widgets/app_icon.dart';

/// Visual treatment for a notification row's left indicator: which icon
/// to render inside the AppIconIndicator, and what color to tint it.
///
/// Kept as a small switch here rather than a helper table — with three
/// types today the branching cost is nothing, and a switch makes
/// missing cases a compile-time error when a new type lands. Promote
/// to a keyed table if this grows past ~6 entries.
class NotificationAppearance {
  const NotificationAppearance({required this.icon, required this.color});
  final String icon;
  final Color color;
}

NotificationAppearance appearanceFor(gen.Type type, BuildContext context) {
  final colors = context.colors;
  switch (type) {
    // Both "quick" types share the coach-nav message-square icon +
    // yellow tint — matches the coach Home To-Do row's "Quick Feedback
    // Requests" treatment so the visual language stays consistent
    // across surfaces. Title text differentiates submitted (athlete-
    // side) vs requested (coach-side) contextually.
    //
    // Formal uses star + red, matching the coach Home To-Do "Formal
    // Assessments due" row.
    //
    // Follow-up: agree with design + client on formal iconography
    // (star is currently overloaded with the quick-feedback score
    // scale) — this is a stopgap that ties the notifications page to
    // the existing coach dashboard visual vocabulary.
    case gen.Type.ASSESSMENT_SUBMITTED_QUICK:
    case gen.Type.ASSESSMENT_REQUESTED_QUICK:
      return NotificationAppearance(
        icon: AppIcons.coachNavFeedback,
        color: colors.secondary,
      );
    case gen.Type.ASSESSMENT_SUBMITTED_FORMAL:
      return NotificationAppearance(
        icon: AppIcons.star,
        color: colors.error,
      );
    // Guardian sign-up completion — fires to the athlete once their
    // guardian links. Reuse the profile-nav icon in the link color
    // (blue) as a neutral "relationship established" cue.
    case gen.Type.GUARDIAN_LINKED:
      return NotificationAppearance(
        icon: AppIcons.navProfile,
        color: colors.link,
      );
    // Org-decision types fire only to GMs (web-only role today) —
    // mobile never renders them in practice. Handled here so the
    // switch stays exhaustive; icon/color chosen so if they ever do
    // surface they read as neutral status updates.
    case gen.Type.ORGANIZATION_APPROVED:
    case gen.Type.ORGANIZATION_DENIED:
      return NotificationAppearance(
        icon: AppIcons.checkCircle,
        color: colors.link,
      );
  }
}
