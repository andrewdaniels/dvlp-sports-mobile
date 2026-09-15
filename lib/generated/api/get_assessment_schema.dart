// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getAssessmentSchemaData = getAssessmentSchemaDataFromJson(jsonString);
//     final getAssessmentSchemaRequest = getAssessmentSchemaRequestFromJson(jsonString);

import 'dart:convert';

GetAssessmentSchemaData getAssessmentSchemaDataFromJson(String str) => GetAssessmentSchemaData.fromJson(json.decode(str));

String getAssessmentSchemaDataToJson(GetAssessmentSchemaData data) => json.encode(data.toJson());

GetAssessmentSchemaRequest getAssessmentSchemaRequestFromJson(String str) => GetAssessmentSchemaRequest.fromJson(json.decode(str));

String getAssessmentSchemaRequestToJson(GetAssessmentSchemaRequest data) => json.encode(data.toJson());

class GetAssessmentSchemaData {
    final ScoreScale scoreScale;
    final List<Skill> skills;

    GetAssessmentSchemaData({
        required this.scoreScale,
        required this.skills,
    });

    GetAssessmentSchemaData copyWith({
        ScoreScale? scoreScale,
        List<Skill>? skills,
    }) => 
        GetAssessmentSchemaData(
            scoreScale: scoreScale ?? this.scoreScale,
            skills: skills ?? this.skills,
        );

    factory GetAssessmentSchemaData.fromJson(Map<String, dynamic> json) => GetAssessmentSchemaData(
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
    final String? description;
    final String id;
    final String name;

    Skill({
        required this.description,
        required this.id,
        required this.name,
    });

    Skill copyWith({
        String? description,
        String? id,
        String? name,
    }) => 
        Skill(
            description: description ?? this.description,
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        description: json["description"],
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "description": description,
        "id": id,
        "name": name,
    };
}

class GetAssessmentSchemaRequest {
    final String teamId;

    GetAssessmentSchemaRequest({
        required this.teamId,
    });

    GetAssessmentSchemaRequest copyWith({
        String? teamId,
    }) => 
        GetAssessmentSchemaRequest(
            teamId: teamId ?? this.teamId,
        );

    factory GetAssessmentSchemaRequest.fromJson(Map<String, dynamic> json) => GetAssessmentSchemaRequest(
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
    };
}

