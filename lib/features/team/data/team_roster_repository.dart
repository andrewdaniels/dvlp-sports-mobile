import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/get_team_roster.dart';
import '../../auth/data/api_result.dart';

/// Wraps the get-team-roster edge function. Pure I/O — no caching
/// here; providers own that.
class TeamRosterRepository {
  TeamRosterRepository(this._client);
  final SupabaseClient _client;

  /// Fetch the active roster for a team, with each athlete's ranking
  /// derived at the team's level_classification.
  ///
  /// Caller must be an active coach on the team (server-enforced;
  /// 403 otherwise).
  Future<ApiResult<GetTeamRosterData>> getTeamRoster({
    required String teamId,
  }) {
    return _invoke<GetTeamRosterData>(
      name: 'get-team-roster',
      body: {'team_id': teamId},
      fromJson: GetTeamRosterData.fromJson,
    );
  }

  // ─── Envelope parsing ──────────────────────────────────────────────
  // Same shape as ProfileRepository / GamesRepository / SkillsRepository.
  // Hoist to a shared EdgeFunctionInvoker if we grow one more copy.

  Future<ApiResult<T>> _invoke<T>({
    required String name,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final response = await _client.functions.invoke(name, body: body);
      return _parseOk<T>(response.data, fromJson);
    } on FunctionException catch (e) {
      developer.log(
        '$name FunctionException (status=${e.status})',
        name: 'TeamRosterRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'TeamRosterRepository',
        error: e,
        stackTrace: st,
      );
      return const Failure('network_error', 'Something went wrong. Try again.');
    }
  }

  ApiResult<T> _parseOk<T>(dynamic body, T Function(Map<String, dynamic>) fromJson) {
    final map = _asMap(body);
    if (map == null) return const Failure('bad_response', 'Unexpected server response.');
    if (map['ok'] == true) {
      final data = _asMap(map['data']);
      if (data == null) return const Failure('bad_response', 'Unexpected server response.');
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
