// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getGamesData = getGamesDataFromJson(jsonString);
//     final getGamesRequest = getGamesRequestFromJson(jsonString);

import 'dart:convert';

GetGamesData getGamesDataFromJson(String str) => GetGamesData.fromJson(json.decode(str));

String getGamesDataToJson(GetGamesData data) => json.encode(data.toJson());

GetGamesRequest getGamesRequestFromJson(String str) => GetGamesRequest.fromJson(json.decode(str));

String getGamesRequestToJson(GetGamesRequest data) => json.encode(data.toJson());

class GetGamesData {
    final List<Game> games;

    GetGamesData({
        required this.games,
    });

    GetGamesData copyWith({
        List<Game>? games,
    }) => 
        GetGamesData(
            games: games ?? this.games,
        );

    factory GetGamesData.fromJson(Map<String, dynamic> json) => GetGamesData(
        games: List<Game>.from(json["games"].map((x) => Game.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "games": List<dynamic>.from(games.map((x) => x.toJson())),
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
    final List<String> standoutAthleteIds;
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
        required this.standoutAthleteIds,
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
        List<String>? standoutAthleteIds,
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
            standoutAthleteIds: standoutAthleteIds ?? this.standoutAthleteIds,
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

class GetGamesRequest {
    final String teamId;

    GetGamesRequest({
        required this.teamId,
    });

    GetGamesRequest copyWith({
        String? teamId,
    }) => 
        GetGamesRequest(
            teamId: teamId ?? this.teamId,
        );

    factory GetGamesRequest.fromJson(Map<String, dynamic> json) => GetGamesRequest(
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
    };
}

