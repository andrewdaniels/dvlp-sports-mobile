// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createAssessmentRequestData = createAssessmentRequestDataFromJson(jsonString);
//     final createAssessmentRequestRequest = createAssessmentRequestRequestFromJson(jsonString);

import 'dart:convert';

CreateAssessmentRequestData createAssessmentRequestDataFromJson(String str) => CreateAssessmentRequestData.fromJson(json.decode(str));

String createAssessmentRequestDataToJson(CreateAssessmentRequestData data) => json.encode(data.toJson());

CreateAssessmentRequestRequest createAssessmentRequestRequestFromJson(String str) => CreateAssessmentRequestRequest.fromJson(json.decode(str));

String createAssessmentRequestRequestToJson(CreateAssessmentRequestRequest data) => json.encode(data.toJson());

class CreateAssessmentRequestData {
    final Request request;

    CreateAssessmentRequestData({
        required this.request,
    });

    CreateAssessmentRequestData copyWith({
        Request? request,
    }) => 
        CreateAssessmentRequestData(
            request: request ?? this.request,
        );

    factory CreateAssessmentRequestData.fromJson(Map<String, dynamic> json) => CreateAssessmentRequestData(
        request: Request.fromJson(json["request"]),
    );

    Map<String, dynamic> toJson() => {
        "request": request.toJson(),
    };
}

class Request {
    final String athleteId;
    final String coachId;
    final String? fulfilledAt;
    final String? fulfilledByAssessmentId;
    final String id;
    final String requestedAt;
    final Status status;
    final String teamId;

    Request({
        required this.athleteId,
        required this.coachId,
        required this.fulfilledAt,
        required this.fulfilledByAssessmentId,
        required this.id,
        required this.requestedAt,
        required this.status,
        required this.teamId,
    });

    Request copyWith({
        String? athleteId,
        String? coachId,
        String? fulfilledAt,
        String? fulfilledByAssessmentId,
        String? id,
        String? requestedAt,
        Status? status,
        String? teamId,
    }) => 
        Request(
            athleteId: athleteId ?? this.athleteId,
            coachId: coachId ?? this.coachId,
            fulfilledAt: fulfilledAt ?? this.fulfilledAt,
            fulfilledByAssessmentId: fulfilledByAssessmentId ?? this.fulfilledByAssessmentId,
            id: id ?? this.id,
            requestedAt: requestedAt ?? this.requestedAt,
            status: status ?? this.status,
            teamId: teamId ?? this.teamId,
        );

    factory Request.fromJson(Map<String, dynamic> json) => Request(
        athleteId: json["athlete_id"],
        coachId: json["coach_id"],
        fulfilledAt: json["fulfilled_at"],
        fulfilledByAssessmentId: json["fulfilled_by_assessment_id"],
        id: json["id"],
        requestedAt: json["requested_at"],
        status: statusValues.map[json["status"]]!,
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
        "coach_id": coachId,
        "fulfilled_at": fulfilledAt,
        "fulfilled_by_assessment_id": fulfilledByAssessmentId,
        "id": id,
        "requested_at": requestedAt,
        "status": statusValues.reverse[status],
        "team_id": teamId,
    };
}

enum Status {
    COMPLETED,
    IN_PROGRESS,
    PENDING
}

final statusValues = EnumValues({
    "completed": Status.COMPLETED,
    "in_progress": Status.IN_PROGRESS,
    "pending": Status.PENDING
});

class CreateAssessmentRequestRequest {
    final String coachId;
    final String teamId;

    CreateAssessmentRequestRequest({
        required this.coachId,
        required this.teamId,
    });

    CreateAssessmentRequestRequest copyWith({
        String? coachId,
        String? teamId,
    }) => 
        CreateAssessmentRequestRequest(
            coachId: coachId ?? this.coachId,
            teamId: teamId ?? this.teamId,
        );

    factory CreateAssessmentRequestRequest.fromJson(Map<String, dynamic> json) => CreateAssessmentRequestRequest(
        coachId: json["coach_id"],
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "coach_id": coachId,
        "team_id": teamId,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}

