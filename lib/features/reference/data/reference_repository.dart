import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/get_positions.dart';
import '../../auth/data/api_result.dart';

/// Read-only lookups against reference tables (positions today; skills,
/// level bands, sports later). Pure I/O — no caching happens here;
/// providers handle that.
class ReferenceRepository {
  ReferenceRepository(this._client);
  final SupabaseClient _client;

  Future<ApiResult<GetPositionsData>> getPositions({String? sportId}) async {
    try {
      final response = await _client.functions.invoke(
        'get-positions',
        body: sportId == null ? const {} : {'sport_id': sportId},
      );
      return _parseOk(response.data);
    } on FunctionException catch (e) {
      developer.log(
        'get-positions FunctionException (status=${e.status})',
        name: 'ReferenceRepository',
        error: e.details,
      );
      return _parseError(e.details);
    } catch (e, st) {
      developer.log(
        'get-positions unexpected error',
        name: 'ReferenceRepository',
        error: e,
        stackTrace: st,
      );
      return const Failure('network_error', 'Something went wrong. Try again.');
    }
  }

  ApiResult<GetPositionsData> _parseOk(dynamic body) {
    final map = _asMap(body);
    if (map == null) return const Failure('bad_response', 'Unexpected server response.');
    if (map['ok'] == true) {
      final data = _asMap(map['data']);
      if (data == null) return const Failure('bad_response', 'Unexpected server response.');
      return Success(GetPositionsData.fromJson(data));
    }
    return _parseError(map);
  }

  ApiResult<GetPositionsData> _parseError(dynamic body) {
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
