import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/create_assessment_request.dart';
import '../../../generated/api/get_coaches.dart';
import '../../auth/data/api_result.dart';

/// Wraps the Request Feedback edge functions. Pure I/O — providers
/// own caching + mutation state.
class FeedbackRequestsRepository {
  FeedbackRequestsRepository(this._client);
  final SupabaseClient _client;

  /// Fetch coaches available to the current caller. Sending an empty
  /// body lets the server derive scope from the JWT — athlete = their
  /// active team; coach (later) = their organization. Pass explicit
  /// filters only when the caller needs a specific team or org.
  Future<ApiResult<GetCoachesData>> getCoaches({
    String? teamId,
    String? organizationId,
  }) {
    return _invoke<GetCoachesData>(
      name: 'get-coaches',
      body: {
        // ignore: use_null_aware_elements
        if (teamId != null) 'team_id': teamId,
        // ignore: use_null_aware_elements
        if (organizationId != null) 'organization_id': organizationId,
      },
      fromJson: GetCoachesData.fromJson,
    );
  }

  /// Athlete creates a request for a specific (coach, team) pair.
  /// Server validates the pair is a live team_coaches membership.
  Future<ApiResult<CreateAssessmentRequestData>> createRequest({
    required String coachId,
    required String teamId,
  }) {
    return _invoke<CreateAssessmentRequestData>(
      name: 'create-assessment-request',
      body: {
        'coach_id': coachId,
        'team_id': teamId,
      },
      fromJson: CreateAssessmentRequestData.fromJson,
    );
  }

  // ─── Envelope parsing ──────────────────────────────────────────────
  // Same shape as JournalRepository / SkillsRepository / etc. Hoist to
  // a shared EdgeFunctionInvoker when we're touching all of them.

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
        name: 'FeedbackRequestsRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'FeedbackRequestsRepository',
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
