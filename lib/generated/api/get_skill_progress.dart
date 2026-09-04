// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getSkillProgressData = getSkillProgressDataFromJson(jsonString);
//     final getSkillProgressRequest = getSkillProgressRequestFromJson(jsonString);

import 'dart:convert';

GetSkillProgressData getSkillProgressDataFromJson(String str) => GetSkillProgressData.fromJson(json.decode(str));

String getSkillProgressDataToJson(GetSkillProgressData data) => json.encode(data.toJson());

GetSkillProgressRequest getSkillProgressRequestFromJson(String str) => GetSkillProgressRequest.fromJson(json.decode(str));

String getSkillProgressRequestToJson(GetSkillProgressRequest data) => json.encode(data.toJson());

class GetSkillProgressData {
    final ScoreScale scoreScale;
    final List<Skill> skills;

    GetSkillProgressData({
        required this.scoreScale,
        required this.skills,
    });

    GetSkillProgressData copyWith({
        ScoreScale? scoreScale,
        List<Skill>? skills,
    }) => 
        GetSkillProgressData(
            scoreScale: scoreScale ?? this.scoreScale,
            skills: skills ?? this.skills,
        );

    factory GetSkillProgressData.fromJson(Map<String, dynamic> json) => GetSkillProgressData(
        scoreScale: ScoreScale.fromJson(json["score_scale"]),
        skills: List<Skill>.from(json["skills"].map((x) => Skill.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "score_scale": scoreScale.toJson(),
        "skills": List<dynamic>.from(skills.map((x) => x.toJson())),
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

class Skill {
    final double currentScore;
    final double? delta;
    final double? previousScore;
    final String? skillDescription;
    final String skillId;
    final String skillName;

    Skill({
        required this.currentScore,
        required this.delta,
        required this.previousScore,
        required this.skillDescription,
        required this.skillId,
        required this.skillName,
    });

    Skill copyWith({
        double? currentScore,
        double? delta,
        double? previousScore,
        String? skillDescription,
        String? skillId,
        String? skillName,
    }) => 
        Skill(
            currentScore: currentScore ?? this.currentScore,
            delta: delta ?? this.delta,
            previousScore: previousScore ?? this.previousScore,
            skillDescription: skillDescription ?? this.skillDescription,
            skillId: skillId ?? this.skillId,
            skillName: skillName ?? this.skillName,
        );

    factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        currentScore: json["current_score"]?.toDouble(),
        delta: json["delta"]?.toDouble(),
        previousScore: json["previous_score"]?.toDouble(),
        skillDescription: json["skill_description"],
        skillId: json["skill_id"],
        skillName: json["skill_name"],
    );

    Map<String, dynamic> toJson() => {
        "current_score": currentScore,
        "delta": delta,
        "previous_score": previousScore,
        "skill_description": skillDescription,
        "skill_id": skillId,
        "skill_name": skillName,
    };
}

class GetSkillProgressRequest {
    final String? athleteId;
    final String? levelClassificationId;

    GetSkillProgressRequest({
        this.athleteId,
        this.levelClassificationId,
    });

    GetSkillProgressRequest copyWith({
        String? athleteId,
        String? levelClassificationId,
    }) => 
        GetSkillProgressRequest(
            athleteId: athleteId ?? this.athleteId,
            levelClassificationId: levelClassificationId ?? this.levelClassificationId,
        );

    factory GetSkillProgressRequest.fromJson(Map<String, dynamic> json) => GetSkillProgressRequest(
        athleteId: json["athlete_id"],
        levelClassificationId: json["level_classification_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
        "level_classification_id": levelClassificationId,
    };
}

