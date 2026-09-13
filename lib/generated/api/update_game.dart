// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final updateGameData = updateGameDataFromJson(jsonString);
//     final updateGameRequest = updateGameRequestFromJson(jsonString);

import 'dart:convert';

UpdateGameData updateGameDataFromJson(String str) => UpdateGameData.fromJson(json.decode(str));

String updateGameDataToJson(UpdateGameData data) => json.encode(data.toJson());

UpdateGameRequest updateGameRequestFromJson(String str) => UpdateGameRequest.fromJson(json.decode(str));

String updateGameRequestToJson(UpdateGameRequest data) => json.encode(data.toJson());

class UpdateGameData {
    final Game game;

    UpdateGameData({
        required this.game,
    });

    UpdateGameData copyWith({
        Game? game,
    }) => 
        UpdateGameData(
            game: game ?? this.game,
        );

    factory UpdateGameData.fromJson(Map<String, dynamic> json) => UpdateGameData(
        game: Game.fromJson(json["game"]),
    );

    Map<String, dynamic> toJson() => {
        "game": game.toJson(),
    };
}

class Game {
    final String id;
    final bool isHome;
    final String? location;
    final String? note;
    final String? noteCoachId;
    final String opponentName;
    final int? opponentScore;
    final String startsAt;
    final String teamId;
    final int? teamScore;

    Game({
        required this.id,
        required this.isHome,
        required this.location,
        required this.note,
        required this.noteCoachId,
        required this.opponentName,
        required this.opponentScore,
        required this.startsAt,
        required this.teamId,
        required this.teamScore,
    });

    Game copyWith({
        String? id,
        bool? isHome,
        String? location,
        String? note,
        String? noteCoachId,
        String? opponentName,
        int? opponentScore,
        String? startsAt,
        String? teamId,
        int? teamScore,
    }) => 
        Game(
            id: id ?? this.id,
            isHome: isHome ?? this.isHome,
            location: location ?? this.location,
            note: note ?? this.note,
            noteCoachId: noteCoachId ?? this.noteCoachId,
            opponentName: opponentName ?? this.opponentName,
            opponentScore: opponentScore ?? this.opponentScore,
            startsAt: startsAt ?? this.startsAt,
            teamId: teamId ?? this.teamId,
            teamScore: teamScore ?? this.teamScore,
        );

    factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json["id"],
        isHome: json["is_home"],
        location: json["location"],
        note: json["note"],
        noteCoachId: json["note_coach_id"],
        opponentName: json["opponent_name"],
        opponentScore: json["opponent_score"],
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
        "starts_at": startsAt,
        "team_id": teamId,
        "team_score": teamScore,
    };
}

class UpdateGameRequest {
    final String gameId;
    final String? note;
    final int? opponentScore;
    final int? teamScore;

    UpdateGameRequest({
        required this.gameId,
        this.note,
        this.opponentScore,
        this.teamScore,
    });

    UpdateGameRequest copyWith({
        String? gameId,
        String? note,
        int? opponentScore,
        int? teamScore,
    }) => 
        UpdateGameRequest(
            gameId: gameId ?? this.gameId,
            note: note ?? this.note,
            opponentScore: opponentScore ?? this.opponentScore,
            teamScore: teamScore ?? this.teamScore,
        );

    factory UpdateGameRequest.fromJson(Map<String, dynamic> json) => UpdateGameRequest(
        gameId: json["game_id"],
        note: json["note"],
        opponentScore: json["opponent_score"],
        teamScore: json["team_score"],
    );

    Map<String, dynamic> toJson() => {
        "game_id": gameId,
        "note": note,
        "opponent_score": opponentScore,
        "team_score": teamScore,
    };
}

