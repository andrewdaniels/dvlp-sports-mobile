/// Named routes for go_router.
///
/// Structure:
///   `/`                 — splash / role gate. Reads currentProfileProvider
///                         and go's to the correct shell's landing tab.
///   `/athlete/*`        — athlete shell tabs + child routes.
///   `/coach/*`          — coach shell tabs + child routes.
///   Auth + dev + shared routes live at the top level.
class RouteNames {
  RouteNames._();

  // Root / splash
  static const splash = '/';

  // Auth / onboarding
  static const entry = '/entry';
  static const login = '/login';
  static const signupCode = '/signup/code';
  static const signupCredentials = '/signup/credentials';
  static const signupPlayerDetails = '/signup/details/player';
  static const signupCoachDetails = '/signup/details/coach';
  static const signupGuardianDetails = '/signup/details/guardian';

  // Athlete shell tabs
  static const athletePassport = '/athlete/passport';
  static const athleteDvlp = '/athlete/dvlp';
  static const athleteTeam = '/athlete/team';
  static const athleteProfile = '/athlete/profile';

  // Athlete → Passport → My Feedback
  static const myFeedback = '/feedback/all';

  // Athlete → DVLP → Journal
  static const journal = '/journal';

  // Coach shell tabs
  static const coachHome = '/coach/home';
  static const coachFeedback = '/coach/feedback';
  static const coachGames = '/coach/games';
  static const coachTeam = '/coach/team';
  static const coachProfile = '/coach/profile';

  // Coach → Games → Game details (post-game report composer for
  // completed games; read-only preview for upcoming).
  static const coachGameDetails = '/coach/games/details';
  static String coachGameDetailsFor(String gameId) => '$coachGameDetails/$gameId';

  // Coach → Team → Athlete details (roster row + external connection tap).
  static const coachAthleteDetails = '/coach/team/athlete';
  static String coachAthleteDetailsFor(String athleteId) =>
      '$coachAthleteDetails/$athleteId';

  // Assessment detail — pushed on the root navigator (over either
  // shell). Split by type so each renders on the right score scale.
  static const feedbackQuick = '/feedback/quick';
  static const feedbackFormal = '/feedback/formal';
  static String feedbackQuickFor(String assessmentId) => '$feedbackQuick/$assessmentId';
  static String feedbackFormalFor(String assessmentId) => '$feedbackFormal/$assessmentId';

  // Composer routes — coach creates a NEW assessment for an athlete.
  // The composer sub-tree lives under the same feedback/* paths as
  // the viewers so the two share the mode-aware page widget.
  // team_id is required as a query param (server needs it for both
  // authorization + score scale resolution). request_id is only
  // meaningful for the quick composer (fulfilling a pending request).
  static const feedbackFormalNew = '/feedback/formal/new';
  static const feedbackQuickNew = '/feedback/quick/new';
  static String feedbackFormalNewFor({
    required String athleteId,
    required String teamId,
  }) =>
      '$feedbackFormalNew/$athleteId?team_id=$teamId';
  static String feedbackQuickNewFor({
    required String athleteId,
    required String teamId,
    String? requestId,
  }) {
    final base = '$feedbackQuickNew/$athleteId?team_id=$teamId';
    return requestId == null ? base : '$base&request_id=$requestId';
  }

  // Profile → Settings (shared across shells)
  static const accountSettings = '/account-settings';

  // Notifications inbox — pushed on root nav from athlete Passport /
  // coach Home bell icons. Shared across both shells.
  static const notifications = '/notifications';

  // Dev tools (debug mode only)
  static const designSystem = '/dev/design-system';
  static const components = '/dev/components';
}
