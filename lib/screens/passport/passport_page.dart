import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/assessments/controllers/assessments_providers.dart';
import '../../features/assessments/ui/widgets/app_feedback_list_item.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/feedback_requests/ui/sheets/request_feedback_sheet.dart';
import '../../features/auth/util/profile_format.dart';
import '../../generated/api/get_assessments.dart' as assessments_api;
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_level_badge.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_player_passport_card.dart';

class PassportPage extends ConsumerWidget {
  const PassportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passport'),
        actions: [
          AppIconButton(
            icon: AppIcons.bell,
            size: AppIconButtonSize.large,
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: notifications screen
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => profile == null ? const SizedBox.shrink() : _PassportBody(profile: profile),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _PassportBody extends ConsumerWidget {
  const _PassportBody({required this.profile});

  final GetProfileData profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athlete = profile.athleteDetails;
    // TODO: derive from athlete's overall score once scoring is wired.
    const band = LevelBand.silver;

    final teamLine = _teamLine(profile);
    final age = formatAge(profile.dateOfBirth);
    final height = formatHeight(athlete?.heightCm);
    final weight = formatWeight(athlete?.weightKg);
    final hand = formatDominantSide(athlete?.dominantSide);

    // Position the hero PNG so the visible COIN's center — not the PNG
    // center — aligns with the card's top edge. Measured from the coin
    // artwork's alpha bbox at 0.5 of the PNG height (PNG contains coin
    // + band label; the coin CIRCLE is centered exactly at 50%).
    const heroDim = AppLevelHeroBadge.dim;
    const coinVisualCenterFraction = 0.5;
    const cardOffset = heroDim * coinVisualCenterFraction;
    const cardTopInset = heroDim - cardOffset;

    return ListView(
      padding: AppPageInsets.padding,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: cardOffset),
              child: AppPlayerPassportCard(
                firstName: profile.firstName,
                lastName: profile.lastName,
                teamLine: teamLine,
                age: age,
                height: height,
                weight: weight,
                hand: hand,
                verified: '-',
                avatarUrl: profile.avatarUrl,
                topInset: cardTopInset,
              ),
            ),
            const AppLevelHeroBadge(band: band),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Request Quick Feedback',
          variant: AppButtonVariant.outline,
          expand: true,
          onPressed: () => showRequestFeedbackSheet(context, athleteId: profile.id),
        ),
        const SizedBox(height: AppSpacing.xl),
        _RecentFeedbackSection(athleteId: profile.id),
      ],
    );
  }

  static String _teamLine(GetProfileData profile) {
    final membership = profile.teamMemberships.isNotEmpty ? profile.teamMemberships.first : null;
    final team = membership?.team;
    final positionName = profile.athleteDetails?.position?.name;
    // Team names in our seed already include the age group ("Rampage U13"),
    // so we only append the level classification here to avoid "U13 U13".
    final teamName = team?.name.trim() ?? '';
    final level = team?.levelClassification?.trim() ?? '';
    final teamText = [teamName, level].where((s) => s.isNotEmpty).join(' ');
    if (teamText.isEmpty && (positionName == null || positionName.isEmpty)) return '';
    if (teamText.isEmpty) return positionName!;
    if (positionName == null || positionName.isEmpty) return teamText;
    return '$teamText | $positionName';
  }
}

/// "Recent Feedback" header + See All action + list of submitted
/// assessments as [AppFeedbackListItem]s. Falls back to hidden when
/// the athlete has no submitted rows.
class _RecentFeedbackSection extends ConsumerWidget {
  const _RecentFeedbackSection({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(assessmentsProvider(athleteId));
    final items = async.value?.assessments ?? const <assessments_api.Assessment>[];

    // Hide the whole section when the athlete has no submitted feedback.
    if (async.isLoading && items.isEmpty) {
      return const SizedBox.shrink();
    }
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Feedback',
              style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push(RouteNames.myFeedback);
              },
              child: Text(
                'See All',
                style: AppTypography.boldSmall.copyWith(color: colors.link),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < items.length; i++) ...[
          AppFeedbackListItem(
            assessment: items[i],
            unread: !items[i].athleteRead,
            onTap: () {
              final a = items[i];
              final path = a.assessmentType == assessments_api.AssessmentType.QUICK
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
