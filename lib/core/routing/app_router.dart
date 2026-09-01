import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/auth/entry_page.dart';
import '../../screens/auth/login_page.dart';
import '../../screens/dev/components_page.dart';
import '../../screens/dev/design_system_page.dart';
import '../../screens/dvlp/dvlp_page.dart';
import '../../screens/passport/passport_page.dart';
import '../../screens/profile/profile_page.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/team/team_page.dart';
import 'route_names.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: RouteNames.passport,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.passport,
            builder: (context, state) => const PassportPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.dvlp,
            builder: (context, state) => const DvlpPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.team,
            builder: (context, state) => const TeamPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ]),
      ],
    ),
    // Auth / onboarding — full-screen routes (outside the shell)
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.entry,
      builder: (context, state) => const EntryPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    // Dev tools — full-screen routes (outside the shell)
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.designSystem,
      builder: (context, state) => const DesignSystemPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.components,
      builder: (context, state) => const ComponentsPage(),
    ),
  ],
);
