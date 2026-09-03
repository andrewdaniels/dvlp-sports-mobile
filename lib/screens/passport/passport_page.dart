import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../generated/api/get_profile.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_level_badge.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _PassportBody extends StatelessWidget {
  const _PassportBody({required this.profile});

  final GetProfileData profile;

  @override
  Widget build(BuildContext context) {
    final athlete = profile.athleteDetails;
    // TODO: derive from athlete's overall score once scoring is wired.
    const band = LevelBand.silver;

    final teamLine = _teamLine(profile);
    final age = _formatAge(profile.dateOfBirth);
    final height = _formatHeight(athlete?.heightCm);
    final weight = _formatWeight(athlete?.weightKg);
    final hand = _formatHand(athlete?.dominantSide);

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
          onPressed: () {
            HapticFeedback.mediumImpact();
            // TODO: open request-feedback flow
          },
        ),
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

  static String _formatAge(String? dobIso) {
    if (dobIso == null || dobIso.isEmpty) return '-';
    final dob = DateTime.tryParse(dobIso);
    if (dob == null) return '-';
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age yo';
  }

  static String _formatHeight(double? cm) {
    if (cm == null || cm <= 0) return '-';
    final totalInches = (cm / 2.54).round();
    final ft = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$ft'$inches\"";
  }

  static String _formatWeight(double? kg) {
    if (kg == null || kg <= 0) return '-';
    final lbs = (kg * 2.20462).round();
    return '${lbs}lbs';
  }

  static String _formatHand(DominantSide? side) => switch (side) {
        DominantSide.LEFT => 'Left',
        DominantSide.RIGHT => 'Right',
        DominantSide.AMBIDEXTROUS => 'Both',
        null => '-',
      };
}
