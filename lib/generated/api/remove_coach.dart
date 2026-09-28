// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final removeCoachData = removeCoachDataFromJson(jsonString);
//     final removeCoachRequest = removeCoachRequestFromJson(jsonString);

import 'dart:convert';

RemoveCoachData removeCoachDataFromJson(String str) => RemoveCoachData.fromJson(json.decode(str));

String removeCoachDataToJson(RemoveCoachData data) => json.encode(data.toJson());

RemoveCoachRequest removeCoachRequestFromJson(String str) => RemoveCoachRequest.fromJson(json.decode(str));

String removeCoachRequestToJson(RemoveCoachRequest data) => json.encode(data.toJson());

class RemoveCoachData {
    final String coachId;
    final String teamId;

    RemoveCoachData({
        required this.coachId,
        required this.teamId,
    });

    RemoveCoachData copyWith({
        String? coachId,
        String? teamId,
    }) => 
        RemoveCoachData(
            coachId: coachId ?? this.coachId,
            teamId: teamId ?? this.teamId,
        );

    factory RemoveCoachData.fromJson(Map<String, dynamic> json) => RemoveCoachData(
        coachId: json["coach_id"],
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "coach_id": coachId,
        "team_id": teamId,
    };
}

class RemoveCoachRequest {
    final String coachId;
    final String teamId;

    RemoveCoachRequest({
        required this.coachId,
        required this.teamId,
    });

    RemoveCoachRequest copyWith({
        String? coachId,
        String? teamId,
    }) => 
        RemoveCoachRequest(
            coachId: coachId ?? this.coachId,
            teamId: teamId ?? this.teamId,
        );

    factory RemoveCoachRequest.fromJson(Map<String, dynamic> json) => RemoveCoachRequest(
        coachId: json["coach_id"],
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "coach_id": coachId,
        "team_id": teamId,
    };
}

