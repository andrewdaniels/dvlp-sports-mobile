import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/assessments/controllers/assessments_providers.dart';
import '../../../features/auth/controllers/auth_providers.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/auth/ui/sheets/athlete_selection_sheet.dart';
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
    // Header renders the CALLER's own profile — athletes see themselves,
    // guardians see themselves. Info card below still shows athlete-
    // scoped data (position, verified coaches, height, etc.) resolved
    // via viewingAthleteProvider, prefixed with a "Viewing" switcher
    // row for guardians so the athlete-in-view is explicit + swappable.
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
                  onPressed: () => context.push(RouteNames.editProfile),
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
                : _ProfileBody(caller: profile),
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.caller});

  /// The signed-in user's own profile. Drives the top identity card
  /// for both athletes and guardians.
  final GetProfileData caller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuardian = caller.roleTier == RoleTier.GUARDIAN;

    // Athletes: the info card renders THEIR data (they're the viewing
    // athlete). Guardians: the info card renders the LINKED athlete's
    // data, with a switcher row prepended. Skip the info card entirely
    // if the linked athlete hasn't loaded yet (or a guardian has no
    // link, which shouldn't happen today but is defensive).
    final viewing = isGuardian
        ? ref.watch(viewingAthleteProvider).value
        : caller;

    final displayName = formatFullName(caller.firstName, caller.lastName);
    // Guardians have no team affiliation of their own — use the
    // literal role label as the subtitle so the header line always
    // has secondary text (empty subtitles read as a data gap).
    // Athletes get the standard "Club Age Level" line.
    final String? subtitle;
    if (isGuardian) {
      subtitle = 'Guardian';
    } else {
      final team = caller.teamMemberships.isNotEmpty
          ? caller.teamMemberships.first.team
          : null;
      subtitle = team == null
          ? null
          : [
              team.name.trim(),
              (team.ageGroup ?? '').trim(),
              (team.levelClassification ?? '').trim(),
            ].where((s) => s.isNotEmpty).join(' ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppProfileHeader(
          title: displayName,
          subtitle: subtitle,
          avatarUrl: caller.avatarUrl,
        ),
        const SizedBox(height: AppSpacing.md),
        if (viewing != null)
          _ProfileInfoCard(profile: viewing, isGuardianView: isGuardian),
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
  const _ProfileInfoCard({
    required this.profile,
    required this.isGuardianView,
  });

  /// The athlete profile whose stats are rendered in this card. For
  /// athlete sessions this is the caller; for guardian sessions it's
  /// the currently-viewing linked athlete (via viewingAthleteProvider).
  final GetProfileData profile;

  /// True when the caller is a guardian viewing a linked athlete —
  /// prepends a "Viewing" row at the top of the card with the athlete's
  /// name + the switcher icon.
  final bool isGuardianView;

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
      // Guardian-only: "Viewing" row at the top. Reads like the
      // Verified Coaches row — tappable, chevron trailing — so the
      // affordance matches other pickers in the card. Tap opens the
      // athlete selection sheet.
      if (isGuardianView)
        _RowSpec(
          label: 'Viewing',
          value: formatFullName(profile.firstName, profile.lastName),
          accent: true,
          onTap: () => showAthleteSelectionSheet(context),
        ),
      _RowSpec(
        label: 'Team',
        value: teamValue.isEmpty ? '-' : teamValue,
        accent: true,
      ),
      _RowSpec(label: 'Position', value: athlete?.position?.name ?? '-'),
      _RowSpec(label: 'Verified Coaches', value: verifiedValue, onTap: verifiedOnTap),
      // Guardian row: only meaningful on the athlete's own view (who
      // is my guardian). Redundant when the caller IS the guardian —
      // they already see the athlete they're linked to via the
      // "Viewing" row above + they wouldn't be shown as their own
      // guardian. Placeholder value pending the guardian-consent
      // surface on the athlete side.
      if (!isGuardianView)
        _RowSpec(label: 'Guardian', value: '-', accent: true),
      _RowSpec(label: 'Age', value: formatAge(profile.dateOfBirth)),
      _RowSpec(label: 'Weight', value: formatWeight(athlete?.weightKg)),
      _RowSpec(label: 'Height', value: formatHeight(athlete?.heightCm)),
      // Backend stores this as `dominant_side`; hockey uses "Shot"
      // (shoots left / shoots right) as the natural term. When we add
      // sports where "Hand" or "Foot" reads better, promote this label
      // to per-sport lookup instead of hardcoded.
      _RowSpec(label: 'Shot', value: formatDominantSide(athlete?.dominantSide)),
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
