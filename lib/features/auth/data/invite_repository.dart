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
        'validate_invite',
        body: {'code': code},
      );
      return _parseOk(response.data);
    } on FunctionException catch (e) {
      return _parseError(e.details);
    } catch (_) {
      return const Failure('network_error', 'Something went wrong. Try again.');
    }
  }

  ApiResult<ValidateInviteData> _parseOk(dynamic body) {
    final map = _asMap(body);
    if (map == null) return const Failure('bad_response', 'Unexpected server response.');
    if (map['ok'] == true) {
      final data = map['data'] as Map<String, dynamic>;
      return Success(ValidateInviteData.fromJson(data));
    }
    return _parseError(map);
  }

  ApiResult<ValidateInviteData> _parseError(dynamic body) {
    final map = _asMap(body);
    final errorMap = map?['error'];
    if (errorMap is Map<String, dynamic>) {
      return Failure(
        errorMap['code'] as String? ?? 'unknown',
        errorMap['message'] as String? ?? 'Something went wrong.',
      );
    }
    return const Failure('unknown', 'Something went wrong. Try again.');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}
