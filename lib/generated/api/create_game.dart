// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createGameData = createGameDataFromJson(jsonString);
//     final createGameRequest = createGameRequestFromJson(jsonString);

import 'dart:convert';

CreateGameData createGameDataFromJson(String str) => CreateGameData.fromJson(json.decode(str));

String createGameDataToJson(CreateGameData data) => json.encode(data.toJson());

CreateGameRequest createGameRequestFromJson(String str) => CreateGameRequest.fromJson(json.decode(str));

String createGameRequestToJson(CreateGameRequest data) => json.encode(data.toJson());

class CreateGameData {
    final List<CreateGameDataGame> games;

    CreateGameData({
        required this.games,
    });

    CreateGameData copyWith({
        List<CreateGameDataGame>? games,
    }) => 
        CreateGameData(
            games: games ?? this.games,
        );

    factory CreateGameData.fromJson(Map<String, dynamic> json) => CreateGameData(
        games: List<CreateGameDataGame>.from(json["games"].map((x) => CreateGameDataGame.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "games": List<dynamic>.from(games.map((x) => x.toJson())),
    };
}

class CreateGameDataGame {
    final String id;
    final bool isHome;
    final String? location;
    final String? note;
    final String? noteCoachId;
    final String opponentName;
    final int? opponentScore;
    final List<String> standoutAthleteIds;
    final String startsAt;
    final String teamId;
    final int? teamScore;

    CreateGameDataGame({
        required this.id,
        required this.isHome,
        required this.location,
        required this.note,
        required this.noteCoachId,
        required this.opponentName,
        required this.opponentScore,
        required this.standoutAthleteIds,
        required this.startsAt,
        required this.teamId,
        required this.teamScore,
    });

    CreateGameDataGame copyWith({
        String? id,
        bool? isHome,
        String? location,
        String? note,
        String? noteCoachId,
        String? opponentName,
        int? opponentScore,
        List<String>? standoutAthleteIds,
        String? startsAt,
        String? teamId,
        int? teamScore,
    }) => 
        CreateGameDataGame(
            id: id ?? this.id,
            isHome: isHome ?? this.isHome,
            location: location ?? this.location,
            note: note ?? this.note,
            noteCoachId: noteCoachId ?? this.noteCoachId,
            opponentName: opponentName ?? this.opponentName,
            opponentScore: opponentScore ?? this.opponentScore,
            standoutAthleteIds: standoutAthleteIds ?? this.standoutAthleteIds,
            startsAt: startsAt ?? this.startsAt,
            teamId: teamId ?? this.teamId,
            teamScore: teamScore ?? this.teamScore,
        );

    factory CreateGameDataGame.fromJson(Map<String, dynamic> json) => CreateGameDataGame(
        id: json["id"],
        isHome: json["is_home"],
        location: json["location"],
        note: json["note"],
        noteCoachId: json["note_coach_id"],
        opponentName: json["opponent_name"],
        opponentScore: json["opponent_score"],
        standoutAthleteIds: List<String>.from(json["standout_athlete_ids"].map((x) => x)),
        startsAt: json["starts_at"],
        teamId: json["team_id"],
        teamScore: json["team_score"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "is_home": isHome,
        "location": location,
        "note": note,
        "note_coach_id": noteCoachId,
        "opponent_name": opponentName,
        "opponent_score": opponentScore,
        "standout_athlete_ids": List<dynamic>.from(standoutAthleteIds.map((x) => x)),
        "starts_at": startsAt,
        "team_id": teamId,
        "team_score": teamScore,
    };
}

class CreateGameRequest {
    final List<CreateGameRequestGame> games;
    final String teamId;

    CreateGameRequest({
        required this.games,
        required this.teamId,
    });

    CreateGameRequest copyWith({
        List<CreateGameRequestGame>? games,
        String? teamId,
    }) => 
        CreateGameRequest(
            games: games ?? this.games,
            teamId: teamId ?? this.teamId,
        );

    factory CreateGameRequest.fromJson(Map<String, dynamic> json) => CreateGameRequest(
        games: List<CreateGameRequestGame>.from(json["games"].map((x) => CreateGameRequestGame.fromJson(x))),
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "games": List<dynamic>.from(games.map((x) => x.toJson())),
        "team_id": teamId,
    };
}

class CreateGameRequestGame {
    final bool isHome;
    final String? location;
    final String opponentName;
    final DateTime startsAt;

    CreateGameRequestGame({
        required this.isHome,
        this.location,
        required this.opponentName,
        required this.startsAt,
    });

    CreateGameRequestGame copyWith({
        bool? isHome,
        String? location,
        String? opponentName,
        DateTime? startsAt,
    }) => 
        CreateGameRequestGame(
            isHome: isHome ?? this.isHome,
            location: location ?? this.location,
            opponentName: opponentName ?? this.opponentName,
            startsAt: startsAt ?? this.startsAt,
        );

    factory CreateGameRequestGame.fromJson(Map<String, dynamic> json) => CreateGameRequestGame(
        isHome: json["is_home"],
        location: json["location"],
        opponentName: json["opponent_name"],
        startsAt: DateTime.parse(json["starts_at"]),
    );

    Map<String, dynamic> toJson() => {
        "is_home": isHome,
        "location": location,
        "opponent_name": opponentName,
        "starts_at": startsAt.toIso8601String(),
    };
}

