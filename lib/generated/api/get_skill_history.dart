// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getSkillHistoryData = getSkillHistoryDataFromJson(jsonString);
//     final getSkillHistoryRequest = getSkillHistoryRequestFromJson(jsonString);

import 'dart:convert';

GetSkillHistoryData getSkillHistoryDataFromJson(String str) => GetSkillHistoryData.fromJson(json.decode(str));

String getSkillHistoryDataToJson(GetSkillHistoryData data) => json.encode(data.toJson());

GetSkillHistoryRequest getSkillHistoryRequestFromJson(String str) => GetSkillHistoryRequest.fromJson(json.decode(str));

String getSkillHistoryRequestToJson(GetSkillHistoryRequest data) => json.encode(data.toJson());

class GetSkillHistoryData {
    final List<Point> points;
    final ScoreScale scoreScale;

    GetSkillHistoryData({
        required this.points,
        required this.scoreScale,
    });

    GetSkillHistoryData copyWith({
        List<Point>? points,
        ScoreScale? scoreScale,
    }) => 
        GetSkillHistoryData(
            points: points ?? this.points,
            scoreScale: scoreScale ?? this.scoreScale,
        );

    factory GetSkillHistoryData.fromJson(Map<String, dynamic> json) => GetSkillHistoryData(
        points: List<Point>.from(json["points"].map((x) => Point.fromJson(x))),
        scoreScale: ScoreScale.fromJson(json["score_scale"]),
    );

    Map<String, dynamic> toJson() => {
        "points": List<dynamic>.from(points.map((x) => x.toJson())),
        "score_scale": scoreScale.toJson(),
    };
}

class Point {
    final String monthEnd;
    final double? weightedAvg;

    Point({
        required this.monthEnd,
        required this.weightedAvg,
    });

    Point copyWith({
        String? monthEnd,
        double? weightedAvg,
    }) => 
        Point(
            monthEnd: monthEnd ?? this.monthEnd,
            weightedAvg: weightedAvg ?? this.weightedAvg,
        );

    factory Point.fromJson(Map<String, dynamic> json) => Point(
        monthEnd: json["month_end"],
        weightedAvg: json["weighted_avg"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "month_end": monthEnd,
        "weighted_avg": weightedAvg,
    };
}

class ScoreScale {
    final double max;
    final double min;
    final double step;

    ScoreScale({
        required this.max,
        required this.min,
        required this.step,
    });

    ScoreScale copyWith({
        double? max,
        double? min,
        double? step,
    }) => 
        ScoreScale(
            max: max ?? this.max,
            min: min ?? this.min,
            step: step ?? this.step,
        );

    factory ScoreScale.fromJson(Map<String, dynamic> json) => ScoreScale(
        max: json["max"]?.toDouble(),
        min: json["min"]?.toDouble(),
        step: json["step"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "max": max,
        "min": min,
        "step": step,
    };
}

class GetSkillHistoryRequest {
    final String? athleteId;
    final String? levelClassificationId;
    final int? months;
    final String skillId;

    GetSkillHistoryRequest({
        this.athleteId,
        this.levelClassificationId,
        this.months,
        required this.skillId,
    });

    GetSkillHistoryRequest copyWith({
        String? athleteId,
        String? levelClassificationId,
        int? months,
        String? skillId,
    }) => 
        GetSkillHistoryRequest(
            athleteId: athleteId ?? this.athleteId,
            levelClassificationId: levelClassificationId ?? this.levelClassificationId,
            months: months ?? this.months,
            skillId: skillId ?? this.skillId,
        );

    factory GetSkillHistoryRequest.fromJson(Map<String, dynamic> json) => GetSkillHistoryRequest(
        athleteId: json["athlete_id"],
        levelClassificationId: json["level_classification_id"],
        months: json["months"],
        skillId: json["skill_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
        "level_classification_id": levelClassificationId,
        "months": months,
        "skill_id": skillId,
    };
}

