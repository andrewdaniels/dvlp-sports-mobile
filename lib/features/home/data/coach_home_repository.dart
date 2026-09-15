import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/get_team_aggregates.dart';
import '../../auth/data/api_result.dart';

/// Wraps the coach home endpoints. Currently just get-team-aggregates
/// (avg tier + per-skill averages). Everything else on the home
/// screen composes from other feature providers (games, feedback
/// summary, profile) — this is the only home-scoped fetch.
class CoachHomeRepository {
  CoachHomeRepository(this._client);
  final SupabaseClient _client;

  Future<ApiResult<GetTeamAggregatesData>> getTeamAggregates({
    required String teamId,
  }) {
    return _invoke<GetTeamAggregatesData>(
      name: 'get-team-aggregates',
      body: {'team_id': teamId},
      fromJson: GetTeamAggregatesData.fromJson,
    );
  }

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
        name: 'CoachHomeRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'CoachHomeRepository',
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
