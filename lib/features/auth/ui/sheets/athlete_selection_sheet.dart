import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_linked_athletes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_screen_footer.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';
import '../../../assessments/controllers/assessments_providers.dart';
import '../../../journal/controllers/journal_providers.dart';
import '../../../skills/controllers/skills_providers.dart';
import '../../controllers/profile_providers.dart';

/// Guardian's "which athlete am I viewing" picker. Same visual grammar
/// as the coach's request-feedback coach picker (AppRadioCard list +
/// AppEmptyState for the zero case) so the surface reads consistent.
///
/// Interaction: tap a row → apply immediately (updates
/// [viewingAthleteIdProvider]) + pop. No explicit confirm; matches
/// how iOS pickers behave and keeps the "Add via Invite Code" footer
/// slot for the secondary action.
///
/// The "Add via Invite Code" affordance is stubbed for now — the
/// backend flow for a returning guardian to link a second athlete
/// isn't built. Wired to a SnackBar so the intent is visible on the
/// design and the tap target exists.
class AthleteSelectionSheet extends ConsumerWidget {
  const AthleteSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSheetLayout(
      title: 'Select Athlete',
      subtitle: 'Choose which athlete’s profile to view.',
      footer: AppScreenFooter.single(
        primary: AppButton(
          label: 'Add Athlete via Invite Code',
          variant: AppButtonVariant.outline,
          leadingIcon: AppIcons.plus,
          onPressed: () {
            HapticFeedback.lightImpact();
            // Close the sheet first with a signal so the caller
            // (opener of the sheet) can push the code screen from a
            // stable context — pushing from the sheet's context
            // races the modal dismissal.
            Navigator.of(context).pop(_kAddByInviteCodeSignal);
          },
        ),
      ),
      child: _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(linkedAthletesProvider);
    final currentId = ref.watch(viewingAthleteIdProvider);

    return async.when(
      data: (athletes) {
        if (athletes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: AppEmptyState(
              icon: AppIcons.userFallback,
              iconColor: colors.secondaryText,
              title: 'No linked athletes yet',
              subtitle:
                  'When an athlete lists your email as their guardian, '
                  'they’ll appear here.',
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < athletes.length; i++) ...[
              _LinkedAthleteTile(
                athlete: athletes[i],
                selected: currentId == athletes[i].id,
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Only fire the state update when the pick actually
                  // changes — same-value writes are cheap but there's
                  // no point rebuilding downstream families with the
                  // same key.
                  if (currentId != athletes[i].id) {
                    // Invalidate athlete-scoped families so the new
                    // selection fetches fresh. Riverpod family caches
                    // keep every key's data warm for the session
                    // otherwise — fine for tab-hopping, wrong for
                    // cross-identity switching where a guardian
                    // expects "check on my kid" = current data.
                    // Cost is one round-trip per resource on switch;
                    // guardians switch infrequently so the network
                    // hit is imperceptible.
                    ref.invalidate(athleteProfileProvider);
                    ref.invalidate(assessmentsProvider);
                    ref.invalidate(skillProgressProvider);
                    ref.invalidate(journalEntriesProvider);
                    ref.read(viewingAthleteIdProvider.notifier).state =
                        athletes[i].id;
                  }
                  Navigator.of(context).pop();
                },
              ),
              if (i < athletes.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: AppLoadingIndicator()),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Text(
          'Could not load your linked athletes.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }

}

/// Row tile for a linked athlete — avatar + name + team/position
/// subtitle. Matches the Verified Coaches sheet's row treatment so the
/// two picker surfaces read the same to users. Selected state uses
/// AppCard's `featured` variant (yellow border) rather than a
/// checkbox — matches how the assessment composer's athlete picker
/// signals current selection.
class _LinkedAthleteTile extends StatelessWidget {
  const _LinkedAthleteTile({
    required this.athlete,
    required this.selected,
    required this.onTap,
  });

  final Athlete athlete;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = _subtitle(athlete);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard(
        variant: selected ? AppCardVariant.featured : AppCardVariant.plain,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            imageUrl: athlete.avatarUrl,
            firstName: athlete.firstName,
            lastName: athlete.lastName,
            size: AppAvatarSize.small,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayName(athlete.firstName, athlete.lastName),
                  style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// "Kraken U13 AAA · Goalie" — compose the team line + position and
  /// join with a middle-dot when both are present. Empty string when
  /// neither exists so the row collapses to just the name.
  static String _subtitle(Athlete a) {
    final team = a.team;
    final teamLine = team == null
        ? ''
        : [
            team.name.trim(),
            (team.ageGroup ?? '').trim(),
            (team.levelClassification ?? '').trim(),
          ].where((s) => s.isNotEmpty).join(' ');
    final positionName = a.position?.name.trim() ?? '';
    if (teamLine.isEmpty && positionName.isEmpty) return '';
    if (teamLine.isEmpty) return positionName;
    if (positionName.isEmpty) return teamLine;
    return '$teamLine · $positionName';
  }

  static String _displayName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return 'Athlete';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }
}

/// Sentinel returned from the sheet when the guardian taps
/// "Add Athlete via Invite Code" — the caller checks for this and
/// pushes the code screen on the profile page's own nav context
/// (safer than pushing from the modal's context, which is torn down
/// as soon as the sheet pops).
const _kAddByInviteCodeSignal = '__add_by_invite_code__';

/// Convenience opener — matches the pattern of other sheet openers.
///
/// Handles the "add by invite code" side effect internally: awaits
/// the sheet, and if the guardian picked that action, pushes the
/// signup code screen in link-athlete mode.
Future<void> showAthleteSelectionSheet(BuildContext context) async {
  final result = await showAppSheet<String>(
    context: context,
    builder: (_) => const AthleteSelectionSheet(),
  );
  if (result == _kAddByInviteCodeSignal && context.mounted) {
    context.push('${RouteNames.signupCode}?mode=link');
  }
}
