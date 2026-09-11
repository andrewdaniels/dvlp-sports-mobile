import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/assessments/controllers/assessments_providers.dart';
import '../../../features/auth/controllers/auth_providers.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/auth/util/profile_format.dart';
import '../../../generated/api/get_profile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chevron_right.dart';
import '../../../shared/widgets/app_divider.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_profile_header.dart';
import 'sheets/verified_coaches_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        // Edit + Settings trailing actions. Neither is wired yet —
        // both open TODO surfaces (edit profile flow / settings page).
        // Wrapped in a Padding so they don't hug the right edge.
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
                    // TODO: open edit-profile flow.
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
                : _ProfileBody(profile: profile),
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});
  final GetProfileData profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = formatDisplayName(profile.firstName, profile.lastName);
    final team = profile.teamMemberships.isNotEmpty ? profile.teamMemberships.first.team : null;
    final subtitle = team == null
        ? null
        : [
            team.name.trim(),
            (team.ageGroup ?? '').trim(),
            (team.levelClassification ?? '').trim(),
          ].where((s) => s.isNotEmpty).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppProfileHeader(
          title: displayName,
          subtitle: subtitle,
          avatarUrl: profile.avatarUrl,
        ),
        const SizedBox(height: AppSpacing.md),
        _ProfileInfoCard(profile: profile),
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
}

class _ProfileInfoCard extends ConsumerWidget {
  const _ProfileInfoCard({required this.profile});
  final GetProfileData profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athlete = profile.athleteDetails;
    final team = profile.teamMemberships.isNotEmpty ? profile.teamMemberships.first.team : null;

    // Team value line — compose club name + age group + level so we
    // get "Rampage U13 AAA" (team.name is club identity only now).
    final teamValue = [
      team?.name.trim() ?? '',
      (team?.ageGroup ?? '').trim(),
      (team?.levelClassification ?? '').trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    // Verified Coaches — derived from the already-cached assessments
    // for this athlete (assessmentsProvider is warmed by the Passport
    // page). Rules:
    //   0 coaches → "-", not tappable
    //   1 coach   → "First Last", tappable
    //   >1        → "N Coaches", tappable
    // Sheet gets the projected VerifiedCoachRow list so the display
    // rules + the sheet render from the same derivation.
    final assessmentsAsync = ref.watch(assessmentsProvider(profile.id));
    final coachRows = deriveVerifiedCoaches(
      assessmentsAsync.value?.assessments ?? const [],
    );
    final verifiedValue = switch (coachRows.length) {
      0 => '-',
      1 => '${coachRows[0].firstName} ${coachRows[0].lastName}'.trim(),
      final n => '$n Coaches',
    };
    final verifiedOnTap = coachRows.isEmpty
        ? null
        : () => showVerifiedCoachesSheet(context, rows: coachRows);

    final rows = <_RowSpec>[
      _RowSpec(label: 'Team', value: teamValue.isEmpty ? '-' : teamValue, accent: true),
      _RowSpec(label: 'Position', value: athlete?.position?.name ?? '-'),
      _RowSpec(label: 'Verified Coaches', value: verifiedValue, onTap: verifiedOnTap),
      // Guardian: pending guardian-consent surfacing.
      _RowSpec(label: 'Guardian', value: '-', accent: true),
      _RowSpec(label: 'Age', value: formatAge(profile.dateOfBirth)),
      _RowSpec(label: 'Weight', value: formatWeight(athlete?.weightKg)),
      _RowSpec(label: 'Height', value: formatHeight(athlete?.heightCm)),
      // Backend stores this as `dominant_side`; the mobile label uses
      // "Dominant Hand" per client preference. Applies to hand-based
      // sports; if we add a kicking sport later we'll want to make
      // this label per-sport instead of hardcoded.
      _RowSpec(label: 'Dominant Hand', value: formatDominantSide(athlete?.dominantSide)),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _ProfileRow(spec: rows[i]),
            if (i < rows.length - 1) const AppDivider(),
          ],
        ],
      ),
    );
  }
}

class _RowSpec {
  const _RowSpec({
    required this.label,
    required this.value,
    this.accent = false,
    this.onTap,
  });
  final String label;
  final String value;
  /// When `true`, the value renders in `link` blue instead of primaryText.
  final bool accent;
  /// When set, the row becomes tappable (haptic + callback) and shows
  /// a trailing chevron. Rows without an [onTap] render as read-only.
  final VoidCallback? onTap;
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.spec});
  final _RowSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tappable = spec.onTap != null;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              spec.label,
              style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            spec.value,
            style: AppTypography.bodyLarge.copyWith(
              color: spec.accent ? colors.link : colors.secondaryText,
            ),
            textAlign: TextAlign.end,
          ),
          // Chevron sits tight to the value (xxs = 4px) — reads as
          // "this value is tappable" rather than a separate trailing
          // element. Non-tappable rows just end at the value so their
          // right edge matches the card's inner padding.
          if (tappable) ...[
            const SizedBox(width: AppSpacing.xxs),
            const AppChevronRight(),
          ],
        ],
      ),
    );

    if (!tappable) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        spec.onTap!();
      },
      child: row,
    );
  }
}
