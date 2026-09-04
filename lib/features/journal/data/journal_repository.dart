import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/get_journal_entries.dart';
import '../../auth/data/api_result.dart';

/// Wraps the journal edge functions. Pure I/O — no caching happens
/// here; providers own that.
class JournalRepository {
  JournalRepository(this._client);
  final SupabaseClient _client;

  /// Journal entries for an athlete, most recent first. The backend
  /// derives athlete_id from the JWT when omitted.
  Future<ApiResult<GetJournalEntriesData>> getEntries({
    String? athleteId,
  }) {
    return _invoke<GetJournalEntriesData>(
      name: 'get-journal-entries',
      body: {
        // ignore: use_null_aware_elements
        if (athleteId != null) 'athlete_id': athleteId,
      },
      fromJson: GetJournalEntriesData.fromJson,
    );
  }

  // ─── Envelope parsing ──────────────────────────────────────────────
  // Same shape as SkillsRepository / GamesRepository / etc. Hoist to
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
        name: 'JournalRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'JournalRepository',
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
