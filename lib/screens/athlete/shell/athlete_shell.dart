import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_icon.dart';

/// Athlete-side bottom nav shell hosting the 4 main tabs (Passport,
/// DVLP, Team, Profile). Uses go_router's [StatefulNavigationShell]
/// so tab state persists on switch.
///
/// Coach-side users route through [CoachShell] instead. Router picks
/// the shell based on the caller's role_tier via the splash gate.
class AthleteShell extends StatelessWidget {
  const AthleteShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <AppBottomNavItem>[
    AppBottomNavItem(iconAsset: AppIcons.navPassport, label: 'Passport'),
    AppBottomNavItem(iconAsset: AppIcons.navDvlp, label: 'DVLP'),
    AppBottomNavItem(iconAsset: AppIcons.navTeam, label: 'Team'),
    AppBottomNavItem(iconAsset: AppIcons.navProfile, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // let page content render behind nav for the blur effect
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
