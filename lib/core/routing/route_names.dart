/// Named routes for go_router.
class RouteNames {
  RouteNames._();

  // Auth / onboarding
  static const entry = '/entry';
  static const login = '/login';
  static const signupCode = '/signup/code';
  static const signupType = '/signup/type';
  static const signupPlayerDetails = '/signup/details/player';
  static const signupCoachDetails = '/signup/details/coach';

  // Shell tabs
  static const passport = '/passport';
  static const dvlp = '/dvlp';
  static const team = '/team';
  static const profile = '/profile';

  // Dev tools (debug mode only)
  static const designSystem = '/dev/design-system';
  static const components = '/dev/components';
}
