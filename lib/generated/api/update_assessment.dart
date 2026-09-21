// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final updateAssessmentData = updateAssessmentDataFromJson(jsonString);
//     final updateAssessmentRequest = updateAssessmentRequestFromJson(jsonString);

import 'dart:convert';

UpdateAssessmentData updateAssessmentDataFromJson(String str) => UpdateAssessmentData.fromJson(json.decode(str));

String updateAssessmentDataToJson(UpdateAssessmentData data) => json.encode(data.toJson());

UpdateAssessmentRequest updateAssessmentRequestFromJson(String str) => UpdateAssessmentRequest.fromJson(json.decode(str));

String updateAssessmentRequestToJson(UpdateAssessmentRequest data) => json.encode(data.toJson());

class UpdateAssessmentData {
    final String assessmentId;
    final UpdateAssessmentDataStatus status;
    final String? submittedAt;
    final double? totalScore;

    UpdateAssessmentData({
        required this.assessmentId,
        required this.status,
        required this.submittedAt,
        required this.totalScore,
    });

    UpdateAssessmentData copyWith({
        String? assessmentId,
        UpdateAssessmentDataStatus? status,
        String? submittedAt,
        double? totalScore,
    }) => 
        UpdateAssessmentData(
            assessmentId: assessmentId ?? this.assessmentId,
            status: status ?? this.status,
            submittedAt: submittedAt ?? this.submittedAt,
            totalScore: totalScore ?? this.totalScore,
        );

    factory UpdateAssessmentData.fromJson(Map<String, dynamic> json) => UpdateAssessmentData(
        assessmentId: json["assessment_id"],
        status: updateAssessmentDataStatusValues.map[json["status"]]!,
        submittedAt: json["submitted_at"],
        totalScore: json["total_score"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "assessment_id": assessmentId,
        "status": updateAssessmentDataStatusValues.reverse[status],
        "submitted_at": submittedAt,
        "total_score": totalScore,
    };
}

enum UpdateAssessmentDataStatus {
    DRAFT,
    SUBMITTED
}

final updateAssessmentDataStatusValues = EnumValues({
    "draft": UpdateAssessmentDataStatus.DRAFT,
    "submitted": UpdateAssessmentDataStatus.SUBMITTED
});

class UpdateAssessmentRequest {
    final String assessmentId;
    final String? notes;
    final List<Score>? scores;
    final UpdateAssessmentRequestStatus? status;
    final String? voiceNoteBase64;
    final String? voiceNoteMime;

    UpdateAssessmentRequest({
        required this.assessmentId,
        this.notes,
        this.scores,
        this.status,
        this.voiceNoteBase64,
        this.voiceNoteMime,
    });

    UpdateAssessmentRequest copyWith({
        String? assessmentId,
        String? notes,
        List<Score>? scores,
        UpdateAssessmentRequestStatus? status,
        String? voiceNoteBase64,
        String? voiceNoteMime,
    }) => 
        UpdateAssessmentRequest(
            assessmentId: assessmentId ?? this.assessmentId,
            notes: notes ?? this.notes,
            scores: scores ?? this.scores,
            status: status ?? this.status,
            voiceNoteBase64: voiceNoteBase64 ?? this.voiceNoteBase64,
            voiceNoteMime: voiceNoteMime ?? this.voiceNoteMime,
        );

    factory UpdateAssessmentRequest.fromJson(Map<String, dynamic> json) => UpdateAssessmentRequest(
        assessmentId: json["assessment_id"],
        notes: json["notes"],
        scores: json["scores"] == null ? [] : List<Score>.from(json["scores"]!.map((x) => Score.fromJson(x))),
        status: updateAssessmentRequestStatusValues.map[json["status"]],
        voiceNoteBase64: json["voice_note_base64"],
        voiceNoteMime: json["voice_note_mime"],
    );

    Map<String, dynamic> toJson() => {
        "assessment_id": assessmentId,
        "notes": notes,
        "scores": scores == null ? [] : List<dynamic>.from(scores!.map((x) => x.toJson())),
        "status": updateAssessmentRequestStatusValues.reverse[status],
        "voice_note_base64": voiceNoteBase64,
        "voice_note_mime": voiceNoteMime,
    };
}

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

enum UpdateAssessmentRequestStatus {
    SUBMITTED
}

final updateAssessmentRequestStatusValues = EnumValues({
    "submitted": UpdateAssessmentRequestStatus.SUBMITTED
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}

