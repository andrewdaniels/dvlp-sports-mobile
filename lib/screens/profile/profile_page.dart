import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/auth_providers.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/auth/util/profile_format.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_divider.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_profile_header.dart';

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
    final subtitle = team?.name;

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

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.profile});
  final GetProfileData profile;

  @override
  Widget build(BuildContext context) {
    final athlete = profile.athleteDetails;
    final team = profile.teamMemberships.isNotEmpty ? profile.teamMemberships.first.team : null;

    // "Rampage AAA U13" — swapped from the passport formatting so the
    // level classification leads (matches the profile design intent).
    final teamValue = [
      team?.name.trim() ?? '',
      team?.levelClassification?.trim() ?? '',
    ].where((s) => s.isNotEmpty).join(' ');

    final rows = <_RowSpec>[
      _RowSpec(label: 'Team', value: teamValue.isEmpty ? '-' : teamValue, accent: true),
      _RowSpec(label: 'Position', value: athlete?.position?.name ?? '-'),
      // Verified Coaches: pending coach-verification feature.
      _RowSpec(label: 'Verified Coaches', value: '-'),
      // Guardian: pending guardian-consent surfacing.
      _RowSpec(label: 'Guardian', value: '-', accent: true),
      _RowSpec(label: 'Age', value: formatAge(profile.dateOfBirth)),
      _RowSpec(label: 'Weight', value: formatWeight(athlete?.weightKg)),
      _RowSpec(label: 'Height', value: formatHeight(athlete?.heightCm)),
      // Backend stores this as `dominant_side`; label matches so the
      // model + UI stay in sync and it doesn't imply a hand-specific
      // sport (kicking sports also have a dominant side).
      _RowSpec(label: 'Dominant Side', value: formatDominantSide(athlete?.dominantSide)),
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
  const _RowSpec({required this.label, required this.value, this.accent = false});
  final String label;
  final String value;
  /// When `true`, the value renders in `link` blue instead of primaryText.
  final bool accent;
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.spec});
  final _RowSpec spec;

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
        ],
      ),
    );
  }
}

