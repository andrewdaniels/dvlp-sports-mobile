import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/validate_invite.dart';
import 'api_result.dart';

/// Wraps the `validate_invite` edge function.
///
/// Never throws — every outcome collapses into [Success] or [Failure] so
/// UI code can pattern-match without try/catch.
class InviteRepository {
  InviteRepository(this._client);
  final SupabaseClient _client;

  Future<ApiResult<ValidateInviteData>> validateCode(String code) async {
    try {
      final response = await _client.functions.invoke(
        'validate-invite',
        body: {
          'code': code,
          // Mobile completes athlete, coach, and guardian signups.
          // Manager/admin invites route to the web platform.
          'allowed_roles': ['coach', 'athlete', 'guardian'],
        },
      );
      return _parseOk(response.data);
    } on FunctionException catch (e) {
      developer.log(
        'validate-invite FunctionException (status=${e.status})',
        name: 'InviteRepository',
        error: e.details,
      );
      return _parseError(e.details);
    } catch (e, st) {
      developer.log(
        'validate-invite unexpected error',
        name: 'InviteRepository',
        error: e,
        stackTrace: st,
      );
      return const Failure('network_error', 'Something went wrong. Try again.');
    }
  }

  ApiResult<ValidateInviteData> _parseOk(dynamic body) {
    final map = _asMap(body);
    if (map == null) return const Failure('bad_response', 'Unexpected server response.');
    if (map['ok'] == true) {
      final data = _asMap(map['data']);
      if (data == null) {
        return const Failure('bad_response', 'Unexpected server response.');
      }
      return Success(ValidateInviteData.fromJson(data));
    }
    return _parseError(map);
  }

  ApiResult<ValidateInviteData> _parseError(dynamic body) {
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

  /// Coerce anything JSON-map-shaped into `Map<String, dynamic>`. Handles:
  ///  - already-typed `Map<String, dynamic>` (dart:convert default)
  ///  - `Map<dynamic, dynamic>` (some transports/versions)
  ///  - raw JSON strings (fall back to decode)
  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return _asMap(decoded);
      } catch (_) {
        // Fall through
      }
    }
    return null;
  }
}
