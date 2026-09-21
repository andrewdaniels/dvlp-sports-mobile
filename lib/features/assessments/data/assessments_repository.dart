import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/create_assessment.dart';
import '../../../generated/api/get_assessment_detail.dart';
import '../../../generated/api/get_assessment_schema.dart';
import '../../../generated/api/get_assessments.dart';
import '../../../generated/api/update_assessment.dart';
import '../../auth/data/api_result.dart';

/// Wraps assessment-related edge functions. Pure I/O — no caching
/// happens here; providers own that.
class AssessmentsRepository {
  AssessmentsRepository(this._client);
  final SupabaseClient _client;

  /// Submitted assessments for an athlete, most recent first.
  Future<ApiResult<GetAssessmentsData>> getAssessments({String? athleteId}) {
    return _invoke<GetAssessmentsData>(
      name: 'get-assessments',
      // ignore: use_null_aware_elements
      body: {if (athleteId != null) 'athlete_id': athleteId},
      fromJson: GetAssessmentsData.fromJson,
    );
  }

  /// Full detail for one assessment (scores + skill metadata + notes).
  /// Marks the row as read on the server as a side effect when the
  /// caller is the athlete on the row.
  Future<ApiResult<GetAssessmentDetailData>> getAssessmentDetail(String assessmentId) {
    return _invoke<GetAssessmentDetailData>(
      name: 'get-assessment-detail',
      body: {'assessment_id': assessmentId},
      fromJson: GetAssessmentDetailData.fromJson,
    );
  }

  /// Composer schema: skills for the team's sport + the sport's score
  /// scale. Powers the coach's create-assessment composer for both
  /// quick and formal (quick ignores score_scale — it's a client-side
  /// constant of 1–5 stars).
  ///
  /// [positionId] optional. When provided the returned skills are
  /// filtered to only those mapped to that position (so a goalie
  /// doesn't get scored on shooting). Omit for the sport-wide list.
  Future<ApiResult<GetAssessmentSchemaData>> getAssessmentSchema({
    required String teamId,
    String? positionId,
  }) {
    return _invoke<GetAssessmentSchemaData>(
      name: 'get-assessment-schema',
      body: {
        'team_id': teamId,
        if (positionId != null) 'position_id': positionId,
      },
      fromJson: GetAssessmentSchemaData.fromJson,
    );
  }

  /// Coach creates a new assessment (quick or formal).
  /// - [scores] can be empty for a draft; server rejects submit with
  ///   no scores.
  /// - [requestId] is only valid for a submitted quick assessment;
  ///   server flips the request row to `completed` in the same call.
  Future<ApiResult<CreateAssessmentData>> createAssessment({
    required String assessmentType, // 'quick' | 'formal'
    required String athleteId,
    required String teamId,
    required String status, // 'draft' | 'submitted'
    String? notes,
    List<({String skillId, num score})> scores = const [],
    String? requestId,
    String? voiceNoteBase64,
  }) {
    return _invoke<CreateAssessmentData>(
      name: 'create-assessment',
      body: {
        'assessment_type': assessmentType,
        'athlete_id': athleteId,
        'team_id': teamId,
        'status': status,
        'notes': ?notes,
        'scores': [
          for (final s in scores) {'skill_id': s.skillId, 'score': s.score},
        ],
        'request_id': ?requestId,
        'voice_note_base64': ?voiceNoteBase64,
      },
      fromJson: CreateAssessmentData.fromJson,
    );
  }

  /// Author-only edit of an existing assessment. PATCH semantics —
  /// omit a field to leave it alone. When [scores] is non-null it
  /// REPLACES the full stored set.
  Future<ApiResult<UpdateAssessmentData>> updateAssessment({
    required String assessmentId,
    String? status, // only 'submitted' is meaningful
    String? notes,
    List<({String skillId, num score})>? scores,
    String? voiceNoteBase64,
  }) {
    return _invoke<UpdateAssessmentData>(
      name: 'update-assessment',
      body: {
        'assessment_id': assessmentId,
        'status': ?status,
        'notes': ?notes,
        if (scores != null)
          'scores': [
            for (final s in scores)
              {'skill_id': s.skillId, 'score': s.score},
          ],
        'voice_note_base64': ?voiceNoteBase64,
      },
      fromJson: UpdateAssessmentData.fromJson,
    );
  }

  // ─── Envelope parsing ──────────────────────────────────────────────
  // Duplicated from ProfileRepository / GamesRepository for now. When
  // we add a 4th repository, hoist into a shared EdgeFunctionInvoker.

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
        name: 'AssessmentsRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'AssessmentsRepository',
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
