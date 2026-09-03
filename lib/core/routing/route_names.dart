/// Named routes for go_router.
class RouteNames {
  RouteNames._();

  // Auth / onboarding
  static const entry = '/entry';
  static const login = '/login';
  static const signupCode = '/signup/code';
  static const signupType = '/signup/type';
  static const signupCredentials = '/signup/credentials';
  static const signupPlayerDetails = '/signup/details/player';
  static const signupCoachDetails = '/signup/details/coach';

  // Shell tabs
  static const passport = '/passport';
  static const dvlp = '/dvlp';
  static const team = '/team';
  static const profile = '/profile';

  // Detail routes — pushed on the root navigator (over the shell).
  // Split by assessment_type so each page can render on the correct
  // score scale (quick=1..5 stars, formal=0.5..20 gauge).
  static const feedbackQuick = '/feedback/quick';
  static const feedbackFormal = '/feedback/formal';
  static String feedbackQuickFor(String assessmentId) => '$feedbackQuick/$assessmentId';
  static String feedbackFormalFor(String assessmentId) => '$feedbackFormal/$assessmentId';

  // Dev tools (debug mode only)
  static const designSystem = '/dev/design-system';
  static const components = '/dev/components';
}
