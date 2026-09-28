// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final deleteGameData = deleteGameDataFromJson(jsonString);
//     final deleteGameRequest = deleteGameRequestFromJson(jsonString);

import 'dart:convert';

DeleteGameData deleteGameDataFromJson(String str) => DeleteGameData.fromJson(json.decode(str));

String deleteGameDataToJson(DeleteGameData data) => json.encode(data.toJson());

DeleteGameRequest deleteGameRequestFromJson(String str) => DeleteGameRequest.fromJson(json.decode(str));

String deleteGameRequestToJson(DeleteGameRequest data) => json.encode(data.toJson());

class DeleteGameData {
    final String gameId;

    DeleteGameData({
        required this.gameId,
    });

    DeleteGameData copyWith({
        String? gameId,
    }) => 
        DeleteGameData(
            gameId: gameId ?? this.gameId,
        );

    factory DeleteGameData.fromJson(Map<String, dynamic> json) => DeleteGameData(
        gameId: json["game_id"],
    );

    Map<String, dynamic> toJson() => {
        "game_id": gameId,
    };
}

class DeleteGameRequest {
    final String gameId;

    DeleteGameRequest({
        required this.gameId,
    });

    DeleteGameRequest copyWith({
        String? gameId,
    }) => 
        DeleteGameRequest(
            gameId: gameId ?? this.gameId,
        );

    factory DeleteGameRequest.fromJson(Map<String, dynamic> json) => DeleteGameRequest(
        gameId: json["game_id"],
    );

    Map<String, dynamic> toJson() => {
        "game_id": gameId,
    };
}

