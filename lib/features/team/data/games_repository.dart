import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../generated/api/get_games.dart';
import '../../../generated/api/update_game.dart';
import '../../auth/data/api_result.dart';

/// Wraps games-related edge functions. Pure I/O — no caching happens
/// here; providers own that.
class GamesRepository {
  GamesRepository(this._client);
  final SupabaseClient _client;

  /// Fetch all games for a team, sorted most recent first.
  Future<ApiResult<GetGamesData>> getGames({required String teamId}) {
    return _invoke<GetGamesData>(
      name: 'get-games',
      body: {'team_id': teamId},
      fromJson: GetGamesData.fromJson,
    );
  }

  /// Partial-update a game — post-game report (score + note) or any
  /// mutable game field. Only pass keys that changed; the server treats
  /// omitted keys as "don't touch." Pass `null` on nullable fields to
  /// explicitly clear them.
  ///
  /// Attribution rule for `note` (server-enforced): setting a non-empty
  /// note also sets `note_coach_id = caller`; clearing note also clears
  /// note_coach_id. When `note` is omitted, note_coach_id is untouched
  /// (a score-only edit won't re-attribute an existing note).
  Future<ApiResult<UpdateGameData>> updateGame({
    required String gameId,
    Object? teamScore = absent,
    Object? opponentScore = absent,
    Object? note = absent,
    // Standouts follow the same absent-vs-passed pattern. Pass a list
    // (even empty) to REPLACE the full set for this game; omit to
    // leave existing rows untouched.
    Object? standoutAthleteIds = absent,
  }) {
    final body = <String, dynamic>{'game_id': gameId};
    if (!identical(teamScore, absent)) body['team_score'] = teamScore;
    if (!identical(opponentScore, absent)) body['opponent_score'] = opponentScore;
    if (!identical(note, absent)) body['note'] = note;
    if (!identical(standoutAthleteIds, absent)) {
      body['standout_athlete_ids'] = standoutAthleteIds;
    }
    return _invoke<UpdateGameData>(
      name: 'update-game',
      body: body,
      fromJson: UpdateGameData.fromJson,
    );
  }

  /// Sentinel to distinguish "field omitted" from "field passed as
  /// null". Dart's optional-param default is null, but null on a
  /// nullable column means "explicitly clear it" — we need a third
  /// state for "don't touch." Callers pass [absent] to signal "don't
  /// include this key in the request payload."
  static const Object absent = Object();

  // ─── Envelope parsing ──────────────────────────────────────────────
  // Duplicated from ProfileRepository for now. When we add a 3rd
  // repository, hoist into a shared EdgeFunctionInvoker.

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
        name: 'GamesRepository',
        error: e.details,
      );
      return _parseError<T>(e.details);
    } catch (e, st) {
      developer.log(
        '$name unexpected error',
        name: 'GamesRepository',
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
