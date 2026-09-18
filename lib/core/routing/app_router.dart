import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/account_settings/account_settings_page.dart';
import '../../screens/athlete/dvlp/dvlp_page.dart';
import '../../screens/athlete/feedback/my_feedback_page.dart';
import '../../screens/feedback/formal_feedback_page.dart';
import '../../screens/feedback/quick_feedback_page.dart';
import '../../screens/athlete/journal/journal_page.dart';
import '../../screens/athlete/passport/passport_page.dart';
import '../../screens/athlete/profile/profile_page.dart';
import '../../screens/athlete/shell/athlete_shell.dart';
import '../../screens/athlete/team/team_page.dart';
import '../../screens/auth/coach_account_page.dart';
import '../../screens/auth/credentials_page.dart';
import '../../screens/auth/entry_page.dart';
import '../../screens/auth/guardian_account_page.dart';
import '../../screens/auth/login_page.dart';
import '../../screens/auth/player_account_page.dart';
import '../../screens/auth/signup_code_page.dart';
import '../../screens/coach/feedback/coach_feedback_page.dart';
import '../../screens/coach/games/coach_game_details_page.dart';
import '../../screens/coach/games/coach_games_page.dart';
import '../../screens/coach/home/coach_home_page.dart';
import '../../screens/coach/profile/coach_profile_page.dart';
import '../../screens/coach/shell/coach_shell.dart';
import '../../features/team/ui/widgets/coach_athlete_passport_card.dart';
import '../../screens/coach/team/coach_athlete_details_page.dart';
import '../../screens/coach/team/coach_team_page.dart';
import '../../screens/dev/components_page.dart';
import '../../screens/dev/design_system_page.dart';
import '../../screens/notifications/notifications_page.dart';
import '../../screens/settings/edit_profile_page.dart';
import '../../screens/splash/splash_page.dart';
import '../services/supabase_service.dart';
import 'route_names.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

/// Full-screen paths that don't require a signed-in user. Everything
/// else routes through the auth redirect below.
const _publicRoutes = <String>{
  RouteNames.entry,
  RouteNames.login,
  RouteNames.signupCode,
  RouteNames.signupCredentials,
  RouteNames.signupPlayerDetails,
  RouteNames.signupCoachDetails,
  RouteNames.signupGuardianDetails,
};

final appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  // Start on the splash gate. It reads currentProfileProvider and
  // navigates to /athlete/passport or /coach/home once the profile
  // resolves. Loose role-based enforcement — a signed-in user with
  // the wrong shell's URL will still render that shell (mobile has
  // no URL bar, so this doesn't happen in practice; guard tightens
  // when we build the coach app in earnest).
  initialLocation: RouteNames.splash,
  refreshListenable: _AuthChangeNotifier(),
  redirect: (context, state) {
    final loggedIn = SupabaseService.client.auth.currentSession != null;
    final path = state.matchedLocation;
    final isPublic = _publicRoutes.contains(path);

    // Not logged in → entry (auth guard for every non-public path,
    // including splash). Cold-boot with no session goes directly to
    // /entry without ever rendering splash.
    if (!loggedIn && !isPublic) {
      return RouteNames.entry;
    }
    // Deliberately NOT bouncing off /entry or /login when logged in.
    // Post-signIn navigation is owned by the login / signup pages so
    // they can chain the profile fetch onto the button's loading
    // state and go directly to the right shell — no intermediate
    // splash flash. Splash only renders on cold-boot with a valid
    // session, resolving role → shell.
    return null;
  },
  routes: [
    // Splash / role gate.
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // ── Athlete shell ────────────────────────────────────────────
    // Guardians share this shell — each tab resolves the athlete-to-
    // display via viewingAthleteProvider (their linked athlete),
    // while athletes see their own data. Same code path either way.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AthleteShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.athletePassport,
            builder: (context, state) => const PassportPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.athleteDvlp,
            builder: (context, state) => const DvlpPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.athleteTeam,
            builder: (context, state) => const TeamPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.athleteProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ]),
      ],
    ),

    // ── Coach shell ──────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => CoachShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.coachHome,
            builder: (context, state) => const CoachHomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.coachFeedback,
            builder: (context, state) => const CoachFeedbackPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.coachGames,
            builder: (context, state) => const CoachGamesPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.coachTeam,
            builder: (context, state) => const CoachTeamPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.coachProfile,
            builder: (context, state) => const CoachProfilePage(),
          ),
        ]),
      ],
    ),

    // Auth / onboarding — full-screen routes (outside any shell)
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
      builder: (context, state) {
        // `?mode=link` puts the page in link-athlete mode for an
        // authenticated guardian entering an additional invite code.
        // Default (no query) is the normal signup flow.
        final linkMode = state.uri.queryParameters['mode'] == 'link';
        return SignupCodePage(linkMode: linkMode);
      },
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
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.signupCoachDetails,
      builder: (context, state) => const CoachAccountPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.signupGuardianDetails,
      builder: (context, state) => const GuardianAccountPage(),
    ),

    // Assessment composer — coach creates a NEW assessment. Listed
    // BEFORE the viewer routes so GoRouter matches `/feedback/*/new/*`
    // before falling back to the single-segment viewer path.
    // team_id is a required query param; request_id is optional
    // (quick only, links a pending assessment_request).
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: '${RouteNames.feedbackFormalNew}/:athleteId',
      builder: (context, state) => FormalFeedbackPage(
        newForAthleteId: state.pathParameters['athleteId']!,
        newForTeamId: state.uri.queryParameters['team_id']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: '${RouteNames.feedbackQuickNew}/:athleteId',
      builder: (context, state) => QuickFeedbackPage(
        newForAthleteId: state.pathParameters['athleteId']!,
        newForTeamId: state.uri.queryParameters['team_id']!,
        requestId: state.uri.queryParameters['request_id'],
      ),
    ),

    // Assessment detail — pushed on root nav so it covers whichever
    // shell the caller is inside.
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
      builder: (context, state) => FormalFeedbackPage(
        assessmentId: state.pathParameters['id']!,
      ),
    ),

    // Athlete → Passport → My Feedback (kept at /feedback/all for
    // backwards-compat with existing pushes; conceptually part of
    // the athlete stack but pushed on root nav to escape the shell).
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.myFeedback,
      builder: (context, state) => const MyFeedbackPage(),
    ),

    // Coach → Games → Game details. Pushed on root nav so it covers
    // the coach shell. Same page handles the post-game report
    // composer (for completed games) and the read-only upcoming
    // preview (for future games).
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: '${RouteNames.coachGameDetails}/:id',
      builder: (context, state) => CoachGameDetailsPage(
        gameId: state.pathParameters['id']!,
      ),
    ),

    // Coach → Team → Athlete details. Pushed on root nav.
    // `state.extra` is the AthletePassportRanking captured from the
    // roster / external row that navigated here — lets the passport
    // card render the coin immediately without an extra fetch. Null
    // when deep-linked or navigated without a source row.
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: '${RouteNames.coachAthleteDetails}/:athleteId',
      builder: (context, state) => CoachAthleteDetailsPage(
        athleteId: state.pathParameters['athleteId']!,
        initialRanking: state.extra is AthletePassportRanking
            ? state.extra as AthletePassportRanking
            : null,
      ),
    ),

    // Profile → Edit (pencil icon). Dispatches to the role-appropriate
    // account form in edit mode.
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.editProfile,
      builder: (context, state) => const EditProfilePage(),
    ),

    // Profile → Settings (shared across shells)
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.accountSettings,
      builder: (context, state) => const AccountSettingsPage(),
    ),

    // Notifications inbox (shared across shells — pushed from bell
    // icons on athlete Passport and coach Home)
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),

    // Athlete → DVLP → Journal
    GoRoute(
      parentNavigatorKey: _rootNavKey,
      path: RouteNames.journal,
      builder: (context, state) => const JournalPage(),
    ),

    // Dev tools — full-screen routes (outside any shell)
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
    (_subscription as dynamic).cancel();
    super.dispose();
  }
}
