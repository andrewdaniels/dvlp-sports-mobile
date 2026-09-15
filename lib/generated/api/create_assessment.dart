// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createAssessmentData = createAssessmentDataFromJson(jsonString);
//     final createAssessmentRequest = createAssessmentRequestFromJson(jsonString);

import 'dart:convert';

CreateAssessmentData createAssessmentDataFromJson(String str) => CreateAssessmentData.fromJson(json.decode(str));

String createAssessmentDataToJson(CreateAssessmentData data) => json.encode(data.toJson());

CreateAssessmentRequest createAssessmentRequestFromJson(String str) => CreateAssessmentRequest.fromJson(json.decode(str));

String createAssessmentRequestToJson(CreateAssessmentRequest data) => json.encode(data.toJson());

class CreateAssessmentData {
    final String assessmentId;
    final Status status;
    final String? submittedAt;
    final double? totalScore;

    CreateAssessmentData({
        required this.assessmentId,
        required this.status,
        required this.submittedAt,
        required this.totalScore,
    });

    CreateAssessmentData copyWith({
        String? assessmentId,
        Status? status,
        String? submittedAt,
        double? totalScore,
    }) => 
        CreateAssessmentData(
            assessmentId: assessmentId ?? this.assessmentId,
            status: status ?? this.status,
            submittedAt: submittedAt ?? this.submittedAt,
            totalScore: totalScore ?? this.totalScore,
        );

    factory CreateAssessmentData.fromJson(Map<String, dynamic> json) => CreateAssessmentData(
        assessmentId: json["assessment_id"],
        status: statusValues.map[json["status"]]!,
        submittedAt: json["submitted_at"],
        totalScore: json["total_score"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "assessment_id": assessmentId,
        "status": statusValues.reverse[status],
        "submitted_at": submittedAt,
        "total_score": totalScore,
    };
}

enum Status {
    DRAFT,
    SUBMITTED
}

final statusValues = EnumValues({
    "draft": Status.DRAFT,
    "submitted": Status.SUBMITTED
});

class CreateAssessmentRequest {
    final AssessmentType assessmentType;
    final String athleteId;
    final String? notes;
    final String? requestId;
    final List<Score>? scores;
    final Status status;
    final String teamId;
    final String? voiceNoteUrl;

    CreateAssessmentRequest({
        required this.assessmentType,
        required this.athleteId,
        this.notes,
        this.requestId,
        this.scores,
        required this.status,
        required this.teamId,
        this.voiceNoteUrl,
    });

    CreateAssessmentRequest copyWith({
        AssessmentType? assessmentType,
        String? athleteId,
        String? notes,
        String? requestId,
        List<Score>? scores,
        Status? status,
        String? teamId,
        String? voiceNoteUrl,
    }) => 
        CreateAssessmentRequest(
            assessmentType: assessmentType ?? this.assessmentType,
            athleteId: athleteId ?? this.athleteId,
            notes: notes ?? this.notes,
            requestId: requestId ?? this.requestId,
            scores: scores ?? this.scores,
            status: status ?? this.status,
            teamId: teamId ?? this.teamId,
            voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
        );

    factory CreateAssessmentRequest.fromJson(Map<String, dynamic> json) => CreateAssessmentRequest(
        assessmentType: assessmentTypeValues.map[json["assessment_type"]]!,
        athleteId: json["athlete_id"],
        notes: json["notes"],
        requestId: json["request_id"],
        scores: json["scores"] == null ? [] : List<Score>.from(json["scores"]!.map((x) => Score.fromJson(x))),
        status: statusValues.map[json["status"]]!,
        teamId: json["team_id"],
        voiceNoteUrl: json["voice_note_url"],
    );

    Map<String, dynamic> toJson() => {
        "assessment_type": assessmentTypeValues.reverse[assessmentType],
        "athlete_id": athleteId,
        "notes": notes,
        "request_id": requestId,
        "scores": scores == null ? [] : List<dynamic>.from(scores!.map((x) => x.toJson())),
        "status": statusValues.reverse[status],
        "team_id": teamId,
        "voice_note_url": voiceNoteUrl,
    };
}

enum AssessmentType {
    FORMAL,
    QUICK
}

final assessmentTypeValues = EnumValues({
    "formal": AssessmentType.FORMAL,
    "quick": AssessmentType.QUICK
});

class Score {
    final double score;
    final String skillId;

    Score({
        required this.score,
        required this.skillId,
    });

    Score copyWith({
        double? score,
        String? skillId,
    }) => 
        Score(
            score: score ?? this.score,
            skillId: skillId ?? this.skillId,
        );

    factory Score.fromJson(Map<String, dynamic> json) => Score(
        score: json["score"]?.toDouble(),
        skillId: json["skill_id"],
    );

    Map<String, dynamic> toJson() => {
        "score": score,
        "skill_id": skillId,
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

