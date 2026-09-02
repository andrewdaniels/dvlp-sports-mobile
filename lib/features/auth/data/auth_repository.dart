import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps `SupabaseClient.auth` so calling code doesn't reach into the
/// Supabase package directly. Keeps auth-specific error mapping and any
/// future middleware (analytics, retry, telemetry) in one place.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes. Emits the current state immediately
  /// on subscribe, then on every sign-in / sign-out / token refresh.
  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();
}

/// Maps Supabase auth errors to short user-facing strings. Extend as we
/// hit new failure modes in the wild.
String authErrorMessage(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Wrong email or password.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirm your email before signing in.';
    }
    if (msg.contains('user already registered')) {
      return 'That email is already registered.';
    }
    return error.message;
  }
  return 'Something went wrong. Try again.';
}
