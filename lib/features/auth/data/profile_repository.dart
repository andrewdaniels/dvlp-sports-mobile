import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/create_profile.dart';
import '../../../generated/api/get_profile.dart';
import 'api_result.dart';

/// Wraps profile-related edge functions. Pure I/O — no caching happens
/// here; providers own that.
class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  /// Fetch the current authenticated user's profile.
  Future<ApiResult<GetProfileData>> getProfile() {
    return _invoke<GetProfileData>(
      name: 'get-profile',
      body: const {},
      fromJson: GetProfileData.fromJson,
    );
  }

  Future<ApiResult<CreateProfileData>> createAthlete({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String? inviteId,
    required int? heightCm,
    required int? weightKg,
    required String? dominantSide,
    required String? positionId,
  }) {
    return _invoke<CreateProfileData>(
      name: 'create-profile',
      body: {
        'role': 'athlete',
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        if (inviteId != null) 'invite_id': inviteId,
        'athlete_details': {
          'height_cm': heightCm,
          'weight_kg': weightKg,
          'dominant_side': dominantSide,
          'position_id': positionId,
        },
      },
      fromJson: CreateProfileData.fromJson,
    );
  }

  /// Shared envelope-parsing invocation. Every function follows the
  /// `{ ok, data | error }` contract, so one helper serves all callers.
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
        name: 'ProfileRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'ProfileRepository',
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
