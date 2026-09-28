// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final deleteTeamData = deleteTeamDataFromJson(jsonString);
//     final deleteTeamRequest = deleteTeamRequestFromJson(jsonString);

import 'dart:convert';

DeleteTeamData deleteTeamDataFromJson(String str) => DeleteTeamData.fromJson(json.decode(str));

String deleteTeamDataToJson(DeleteTeamData data) => json.encode(data.toJson());

DeleteTeamRequest deleteTeamRequestFromJson(String str) => DeleteTeamRequest.fromJson(json.decode(str));

String deleteTeamRequestToJson(DeleteTeamRequest data) => json.encode(data.toJson());

class DeleteTeamData {
    final String teamId;

    DeleteTeamData({
        required this.teamId,
    });

    DeleteTeamData copyWith({
        String? teamId,
    }) => 
        DeleteTeamData(
            teamId: teamId ?? this.teamId,
        );

    factory DeleteTeamData.fromJson(Map<String, dynamic> json) => DeleteTeamData(
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
    };
}

class DeleteTeamRequest {
    final String teamId;

    DeleteTeamRequest({
        required this.teamId,
    });

    DeleteTeamRequest copyWith({
        String? teamId,
    }) => 
        DeleteTeamRequest(
            teamId: teamId ?? this.teamId,
        );

    factory DeleteTeamRequest.fromJson(Map<String, dynamic> json) => DeleteTeamRequest(
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
    };
}

