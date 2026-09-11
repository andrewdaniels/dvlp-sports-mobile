import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_icon.dart';

/// Coach-side bottom nav shell hosting the 5 main tabs (Home,
/// Feedback, Games, Team, Profile). Uses go_router's
/// [StatefulNavigationShell] so tab state persists on switch.
///
/// Athlete-side users route through [AthleteShell] instead. Router
/// picks the shell based on the caller's role_tier via the splash
/// gate.
class CoachShell extends StatelessWidget {
  const CoachShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Home + Profile reuse athlete-side icons (same semantics). Feedback
  // reuses the message-question icon we already have for the athlete
  // help sheet. Games + Team use dedicated icons registered in
  // AppIcons.
  static const _items = <AppBottomNavItem>[
    AppBottomNavItem(iconAsset: AppIcons.coachNavHome, label: 'Home'),
    AppBottomNavItem(iconAsset: AppIcons.coachNavFeedback, label: 'Feedback'),
    AppBottomNavItem(iconAsset: AppIcons.coachNavGames, label: 'Games'),
    AppBottomNavItem(iconAsset: AppIcons.navTeam, label: 'Team'),
    AppBottomNavItem(iconAsset: AppIcons.navProfile, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: _items,
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
