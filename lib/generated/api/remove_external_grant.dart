// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final removeExternalGrantData = removeExternalGrantDataFromJson(jsonString);
//     final removeExternalGrantRequest = removeExternalGrantRequestFromJson(jsonString);

import 'dart:convert';

RemoveExternalGrantData removeExternalGrantDataFromJson(String str) => RemoveExternalGrantData.fromJson(json.decode(str));

String removeExternalGrantDataToJson(RemoveExternalGrantData data) => json.encode(data.toJson());

RemoveExternalGrantRequest removeExternalGrantRequestFromJson(String str) => RemoveExternalGrantRequest.fromJson(json.decode(str));

String removeExternalGrantRequestToJson(RemoveExternalGrantRequest data) => json.encode(data.toJson());

class RemoveExternalGrantData {
    final String athleteId;
    final String coachId;

    RemoveExternalGrantData({
        required this.athleteId,
        required this.coachId,
    });

    RemoveExternalGrantData copyWith({
        String? athleteId,
        String? coachId,
    }) => 
        RemoveExternalGrantData(
            athleteId: athleteId ?? this.athleteId,
            coachId: coachId ?? this.coachId,
        );

    factory RemoveExternalGrantData.fromJson(Map<String, dynamic> json) => RemoveExternalGrantData(
        athleteId: json["athlete_id"],
        coachId: json["coach_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
        "coach_id": coachId,
    };
}

class RemoveExternalGrantRequest {
    final String athleteId;
    final String coachId;

    RemoveExternalGrantRequest({
        required this.athleteId,
        required this.coachId,
    });

    RemoveExternalGrantRequest copyWith({
        String? athleteId,
        String? coachId,
    }) => 
        RemoveExternalGrantRequest(
            athleteId: athleteId ?? this.athleteId,
            coachId: coachId ?? this.coachId,
        );

    factory RemoveExternalGrantRequest.fromJson(Map<String, dynamic> json) => RemoveExternalGrantRequest(
        athleteId: json["athlete_id"],
        coachId: json["coach_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
        "coach_id": coachId,
    };
}

