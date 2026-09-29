import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/delete_account.dart';
import 'api_result.dart';

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

  /// Hard-deletes the calling user's account via the `delete-account`
  /// edge fn. The fn cascades DB deletes, removes the auth user, and
  /// fires the recovery-code email. Caller is expected to `signOut()`
  /// and route to the entry screen after a `Success` — this method
  /// does not do it automatically because the caller usually wants
  /// to toast the user with the recovery code first.
  ///
  /// Failure codes worth handling in UI:
  ///   * `sole_gm_of_org_with_teams` — user must reassign / delete
  ///     their organization before deleting their account.
  Future<ApiResult<DeleteAccountData>> deleteAccount() async {
    try {
      final response = await _client.functions.invoke(
        'delete-account',
        body: const <String, dynamic>{},
      );
      return _parseOk(response.data, DeleteAccountData.fromJson);
    } on FunctionException catch (e) {
      return _parseError(e.details);
    } catch (_) {
      return const Failure('network_error', 'Something went wrong. Try again.');
    }
  }

  ApiResult<T> _parseOk<T>(
    dynamic body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final map = _asMap(body);
    if (map == null) {
      return const Failure('bad_response', 'Unexpected server response.');
    }
    if (map['ok'] == true) {
      final data = _asMap(map['data']);
      if (data == null) {
        return const Failure('bad_response', 'Unexpected server response.');
      }
      return Success(fromJson(data));
    }
    return _parseError<T>(map);
  }

  ApiResult<T> _parseError<T>(dynamic body) {
    final map = _asMap(body);
    final errorMap = _asMap(map?['error']);
    if (errorMap != null) {
      return Failure(
        errorMap['code']?.toString() ?? 'unknown',
        errorMap['message']?.toString() ?? 'Something went wrong.',
      );
    }
    return const Failure('unknown', 'Something went wrong. Try again.');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return _asMap(decoded);
      } catch (_) {}
    }
    return null;
  }
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
