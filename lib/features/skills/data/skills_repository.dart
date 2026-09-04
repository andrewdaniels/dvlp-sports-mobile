import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/get_skill_history.dart';
import '../../../generated/api/get_skill_progress.dart';
import '../../auth/data/api_result.dart';

/// Wraps skill-progress edge functions. Pure I/O — no caching happens
/// here; providers own that.
class SkillsRepository {
  SkillsRepository(this._client);
  final SupabaseClient _client;

  /// Running weighted per-skill averages for an athlete. The backend
  /// derives athlete_id from the JWT when omitted, and derives the
  /// level_classification_id from the athlete's active team (enforced
  /// single-active by DB partial unique index).
  Future<ApiResult<GetSkillProgressData>> getSkillProgress({
    String? athleteId,
    String? levelClassificationId,
  }) {
    return _invoke<GetSkillProgressData>(
      name: 'get-skill-progress',
      body: {
        // ignore: use_null_aware_elements
        if (athleteId != null) 'athlete_id': athleteId,
        // ignore: use_null_aware_elements
        if (levelClassificationId != null) 'level_classification_id': levelClassificationId,
      },
      fromJson: GetSkillProgressData.fromJson,
    );
  }

  /// Monthly weighted-average trend for one skill. Server derives
  /// level from the athlete's active team. `months` defaults to 6
  /// server-side; pass explicitly to widen the window.
  Future<ApiResult<GetSkillHistoryData>> getSkillHistory({
    required String skillId,
    String? athleteId,
    String? levelClassificationId,
    int? months,
  }) {
    return _invoke<GetSkillHistoryData>(
      name: 'get-skill-history',
      body: {
        'skill_id': skillId,
        // ignore: use_null_aware_elements
        if (athleteId != null) 'athlete_id': athleteId,
        // ignore: use_null_aware_elements
        if (levelClassificationId != null) 'level_classification_id': levelClassificationId,
        // ignore: use_null_aware_elements
        if (months != null) 'months': months,
      },
      fromJson: GetSkillHistoryData.fromJson,
    );
  }

  // ─── Envelope parsing ──────────────────────────────────────────────
  // Same shape as ProfileRepository / GamesRepository / AssessmentsRepository.
  // Hoist to a shared EdgeFunctionInvoker when we're touching all four.

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
        name: 'SkillsRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'SkillsRepository',
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
