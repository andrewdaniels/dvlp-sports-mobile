import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/auth/credentials_page.dart';
import '../../screens/auth/entry_page.dart';
import '../../screens/auth/login_page.dart';
import '../../screens/auth/player_account_page.dart';
import '../../screens/auth/signup_code_page.dart';
import '../../screens/account_settings/account_settings_page.dart';
import '../../screens/auth/signup_type_page.dart';
import '../../screens/dev/components_page.dart';
import '../../screens/feedback/my_feedback_page.dart';
import '../../screens/journal/journal_page.dart';
import '../../screens/dev/design_system_page.dart';
import '../../screens/dvlp/dvlp_page.dart';
import '../../screens/feedback/formal_assessment_page.dart';
import '../../screens/feedback/quick_feedback_page.dart';
import '../../screens/passport/passport_page.dart';
import '../../screens/profile/profile_page.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/team/team_page.dart';
import '../services/supabase_service.dart';
import 'route_names.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

/// Full-screen paths that don't require a signed-in user. Everything
/// else routes through the auth redirect below.
const _publicRoutes = <String>{
  RouteNames.entry,
  RouteNames.login,
  RouteNames.signupCode,
  RouteNames.signupType,
  RouteNames.signupCredentials,
  RouteNames.signupPlayerDetails,
  RouteNames.signupCoachDetails,
};

final appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: RouteNames.passport,
  // Router listens to auth state changes; a fresh sign-in / sign-out
  // triggers the redirect below to re-evaluate the current location.
  refreshListenable: _AuthChangeNotifier(),
  redirect: (context, state) {
    final loggedIn = SupabaseService.client.auth.currentSession != null;
    final path = state.matchedLocation;
    final isPublic = _publicRoutes.contains(path);

    if (!loggedIn && !isPublic) return RouteNames.entry;
    // Bounce out of entry/login if a session is already active.
    if (loggedIn && (path == RouteNames.entry || path == RouteNames.login)) {
      return RouteNames.passport;
    }
    return null;
  },
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
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.signupCode,
      builder: (context, state) => const SignupCodePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.signupType,
      builder: (context, state) => const SignupTypePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.signupCredentials,
      builder: (context, state) => const CredentialsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.signupPlayerDetails,
      builder: (context, state) => const PlayerAccountPage(),
    ),
    // Feedback detail — pushed on root nav so it covers the shell.
    // Split by assessment type so each page renders on the right scale.
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: '${RouteNames.feedbackQuick}/:id',
      builder: (context, state) => QuickFeedbackPage(
        assessmentId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: '${RouteNames.feedbackFormal}/:id',
      builder: (context, state) => FormalAssessmentPage(
        assessmentId: state.pathParameters['id']!,
      ),
    ),
    // Profile → Settings
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.accountSettings,
      builder: (context, state) => const AccountSettingsPage(),
    ),
    // DVLP → Journal
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.journal,
      builder: (context, state) => const JournalPage(),
    ),
    // Passport → My Feedback
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.myFeedback,
      builder: (context, state) => const MyFeedbackPage(),
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

/// Bridges Supabase's auth-state stream into a Listenable go_router can
/// consume. Every sign-in / sign-out / token-refresh triggers a
/// refresh, which re-runs the redirect above.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _subscription = SupabaseService.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final Object _subscription;

  @override
  void dispose() {
    // GoRoute holds this notifier for the app's lifetime, so this rarely
    // fires; still, tear down the subscription defensively.
    (_subscription as dynamic).cancel();
    super.dispose();
  }
}
