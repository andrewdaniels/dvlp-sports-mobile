import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/auth_providers.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/auth/util/profile_format.dart';
import '../../../generated/api/get_profile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_divider.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_profile_header.dart';

/// Coach-side profile page. Mirrors the athlete profile: hero card
/// (name + org · role) + info card of stat rows + Log Out below.
///
/// Design intent: this page reads only from currentProfileProvider
/// for identity + primary team. Player count + Evaluations Logged
/// are placeholders (`-`) until the coach-side team/feedback endpoints
/// land — at which point both counts derive client-side from those
/// caches (same pattern as verified coaches on athlete profile). No
/// per-role bloat on get-profile.
class CoachProfilePage extends ConsumerWidget {
  const CoachProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        // Edit + Settings — settings kept for parity with athlete
        // (Legal + dev tools live behind it, and coach still needs Log
        // Out via placeholder body until edit lands). Design mock shows
        // pencil only; can drop settings when the coach settings flow
        // is designed.
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconButton(
                  icon: AppIcons.edit,
                  size: AppIconButtonSize.large,
                  onPressed: () {
                    // TODO: open coach edit-profile flow.
                  },
                ),
                const SizedBox(width: AppSpacing.xxs),
                AppIconButton(
                  icon: AppIcons.settings,
                  size: AppIconButtonSize.large,
                  onPressed: () => context.push(RouteNames.accountSettings),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppPageInsets.padding,
        children: [
          profileAsync.when(
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : _CoachProfileBody(profile: profile),
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CoachProfileBody extends ConsumerWidget {
  const _CoachProfileBody({required this.profile});
  final GetProfileData profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = formatDisplayName(profile.firstName, profile.lastName);
    // Coach may hold multiple team_memberships across teams — for MVP
    // we surface the first coach-scope membership as the "primary
    // team" (athlete-scope shouldn't exist for a coach profile but
    // filter defensively). Team switcher lands with the multi-team
    // coach flow.
    final coachMembership = profile.teamMemberships
        .where((m) => m.coachType != null)
        .firstOrNull;
    final subtitle = coachMembership == null
        ? null
        : '${coachMembership.organization.name} · '
            '${_coachRoleLabel(coachMembership.coachType!)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppProfileHeader(
          title: displayName,
          subtitle: subtitle,
          avatarUrl: profile.avatarUrl,
        ),
        const SizedBox(height: AppSpacing.md),
        _CoachInfoCard(team: coachMembership?.team),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: 'Log Out',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.medium,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await ref.read(authRepositoryProvider).signOut();
                // Router redirect handles navigation to /entry on
                // auth-state change.
              },
            ),
          ],
        ),
      ],
    );
  }

  static String _coachRoleLabel(CoachType type) => switch (type) {
        CoachType.HEAD_COACH => 'Head Coach',
        CoachType.ASSISTANT_COACH => 'Assistant Coach',
        CoachType.SKILLS_COACH => 'Skills Coach',
        CoachType.OFFSEASON_COACH => 'Offseason Coach',
      };
}

class _CoachInfoCard extends StatelessWidget {
  const _CoachInfoCard({required this.team});
  final Team? team;

  @override
  Widget build(BuildContext context) {
    // Team row uses the two-line value pattern from the design
    // (name accent-colored, subtitle in secondaryText below).
    // Everything else is a plain label + right-aligned value.
    final teamName = team?.name.trim() ?? '';
    final ageAndLevel = [
      team?.ageGroup?.trim() ?? '',
      team?.levelClassification?.trim() ?? '',
    ].where((s) => s.isNotEmpty).join(' · ');

    // Cadence pulled from get-profile — team-level property, so both
    // roles see it. Athlete surface hasn't wired the label yet since
    // it isn't part of that design; can adopt later.
    final cadenceLabel = team == null ? '-' : _cadenceLabel(team!.assessmentCadence);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _TeamRow(name: teamName.isEmpty ? '-' : teamName, subtitle: ageAndLevel),
          const AppDivider(),
          _StatRow(label: 'Players', value: '-'),
          const AppDivider(),
          _StatRow(label: 'Evaluations Logged', value: '-'),
          const AppDivider(),
          // Cadence renders as display-only for now — no chevron. The
          // edit sheet is deferred; every team is on bi_monthly by
          // default and the client hasn't asked for per-team overrides.
          _StatRow(label: 'Cadence', value: cadenceLabel),
        ],
      ),
    );
  }

  /// Human labels for the enum. Kept local — this is the only surface
  /// that renders cadence today; hoist to a shared formatter if a
  /// second reader appears.
  static String _cadenceLabel(AssessmentCadence c) => switch (c) {
        AssessmentCadence.WEEKLY => 'Every week',
        AssessmentCadence.BI_WEEKLY => 'Every 2 weeks',
        AssessmentCadence.MONTHLY => 'Every month',
        AssessmentCadence.BI_MONTHLY => 'Every 2 months',
        AssessmentCadence.QUARTERLY => 'Every 3 months',
        AssessmentCadence.SEMI_ANNUAL => 'Every 6 months',
        AssessmentCadence.ANNUAL => 'Every year',
      };
}

/// Team row with a two-line value stack — team name (accent color) on
/// top, age group · level classification below in secondary text.
/// Layout mirrors _StatRow so the vertical rhythm across the card
/// stays consistent.
class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Team',
              style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Intrinsic-width column so the right edge of `name` sits at
          // the card's right padding — matches how the other rows'
          // Text values right-align. Wrapping in Flexible left a gap
          // on the right (loose-fit slot > intrinsic child width).
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.bodyLarge.copyWith(color: colors.link),
                textAlign: TextAlign.end,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                  textAlign: TextAlign.end,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Plain label + right-aligned value row. Display-only; mirrors the
/// athlete profile's _ProfileRow. Consider extracting to a shared
/// AppInfoRow once a third page needs the same pattern.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
