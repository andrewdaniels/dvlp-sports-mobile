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
  static const signupType = '/signup/type';
  static const signupCredentials = '/signup/credentials';
  static const signupPlayerDetails = '/signup/details/player';
  static const signupCoachDetails = '/signup/details/coach';

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

  // Assessment detail — pushed on the root navigator (over either
  // shell). Split by type so each renders on the right score scale.
  static const feedbackQuick = '/feedback/quick';
  static const feedbackFormal = '/feedback/formal';
  static String feedbackQuickFor(String assessmentId) => '$feedbackQuick/$assessmentId';
  static String feedbackFormalFor(String assessmentId) => '$feedbackFormal/$assessmentId';

  // Profile → Settings (shared across shells)
  static const accountSettings = '/account-settings';

  // Dev tools (debug mode only)
  static const designSystem = '/dev/design-system';
  static const components = '/dev/components';
}
