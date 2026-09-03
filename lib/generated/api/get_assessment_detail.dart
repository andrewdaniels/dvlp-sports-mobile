// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getAssessmentDetailData = getAssessmentDetailDataFromJson(jsonString);
//     final getAssessmentDetailRequest = getAssessmentDetailRequestFromJson(jsonString);

import 'dart:convert';

GetAssessmentDetailData getAssessmentDetailDataFromJson(String str) => GetAssessmentDetailData.fromJson(json.decode(str));

String getAssessmentDetailDataToJson(GetAssessmentDetailData data) => json.encode(data.toJson());

GetAssessmentDetailRequest getAssessmentDetailRequestFromJson(String str) => GetAssessmentDetailRequest.fromJson(json.decode(str));

String getAssessmentDetailRequestToJson(GetAssessmentDetailRequest data) => json.encode(data.toJson());

class GetAssessmentDetailData {
    final Assessment assessment;

    GetAssessmentDetailData({
        required this.assessment,
    });

    GetAssessmentDetailData copyWith({
        Assessment? assessment,
    }) => 
        GetAssessmentDetailData(
            assessment: assessment ?? this.assessment,
        );

    factory GetAssessmentDetailData.fromJson(Map<String, dynamic> json) => GetAssessmentDetailData(
        assessment: Assessment.fromJson(json["assessment"]),
    );

    Map<String, dynamic> toJson() => {
        "assessment": assessment.toJson(),
    };
}

class Assessment {
    final AssessmentType assessmentType;
    final bool athleteRead;
    final Coach coach;
    final String id;
    final String? notes;
    final ScoreScale scoreScale;
    final List<Score> scores;
    final String submittedAt;
    final Team team;
    final double? totalScore;
    final String? voiceNoteUrl;
    final WeightedRole weightedRole;

    Assessment({
        required this.assessmentType,
        required this.athleteRead,
        required this.coach,
        required this.id,
        required this.notes,
        required this.scoreScale,
        required this.scores,
        required this.submittedAt,
        required this.team,
        required this.totalScore,
        required this.voiceNoteUrl,
        required this.weightedRole,
    });

    Assessment copyWith({
        AssessmentType? assessmentType,
        bool? athleteRead,
        Coach? coach,
        String? id,
        String? notes,
        ScoreScale? scoreScale,
        List<Score>? scores,
        String? submittedAt,
        Team? team,
        double? totalScore,
        String? voiceNoteUrl,
        WeightedRole? weightedRole,
    }) => 
        Assessment(
            assessmentType: assessmentType ?? this.assessmentType,
            athleteRead: athleteRead ?? this.athleteRead,
            coach: coach ?? this.coach,
            id: id ?? this.id,
            notes: notes ?? this.notes,
            scoreScale: scoreScale ?? this.scoreScale,
            scores: scores ?? this.scores,
            submittedAt: submittedAt ?? this.submittedAt,
            team: team ?? this.team,
            totalScore: totalScore ?? this.totalScore,
            voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
            weightedRole: weightedRole ?? this.weightedRole,
        );

    factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        assessmentType: assessmentTypeValues.map[json["assessment_type"]]!,
        athleteRead: json["athlete_read"],
        coach: Coach.fromJson(json["coach"]),
        id: json["id"],
        notes: json["notes"],
        scoreScale: ScoreScale.fromJson(json["score_scale"]),
        scores: List<Score>.from(json["scores"].map((x) => Score.fromJson(x))),
        submittedAt: json["submitted_at"],
        team: Team.fromJson(json["team"]),
        totalScore: json["total_score"]?.toDouble(),
        voiceNoteUrl: json["voice_note_url"],
        weightedRole: weightedRoleValues.map[json["weighted_role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "assessment_type": assessmentTypeValues.reverse[assessmentType],
        "athlete_read": athleteRead,
        "coach": coach.toJson(),
        "id": id,
        "notes": notes,
        "score_scale": scoreScale.toJson(),
        "scores": List<dynamic>.from(scores.map((x) => x.toJson())),
        "submitted_at": submittedAt,
        "team": team.toJson(),
        "total_score": totalScore,
        "voice_note_url": voiceNoteUrl,
        "weighted_role": weightedRoleValues.reverse[weightedRole],
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

class Coach {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;

    Coach({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    Coach copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        Coach(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
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

class Score {
    final double? previousScore;
    final double score;
    final String? skillDescription;
    final String skillId;
    final String skillName;

    Score({
        required this.previousScore,
        required this.score,
        required this.skillDescription,
        required this.skillId,
        required this.skillName,
    });

    Score copyWith({
        double? previousScore,
        double? score,
        String? skillDescription,
        String? skillId,
        String? skillName,
    }) => 
        Score(
            previousScore: previousScore ?? this.previousScore,
            score: score ?? this.score,
            skillDescription: skillDescription ?? this.skillDescription,
            skillId: skillId ?? this.skillId,
            skillName: skillName ?? this.skillName,
        );

    factory Score.fromJson(Map<String, dynamic> json) => Score(
        previousScore: json["previous_score"]?.toDouble(),
        score: json["score"]?.toDouble(),
        skillDescription: json["skill_description"],
        skillId: json["skill_id"],
        skillName: json["skill_name"],
    );

    Map<String, dynamic> toJson() => {
        "previous_score": previousScore,
        "score": score,
        "skill_description": skillDescription,
        "skill_id": skillId,
        "skill_name": skillName,
    };
}

class Team {
    final String? ageGroup;
    final String? level;
    final String name;

    Team({
        required this.ageGroup,
        required this.level,
        required this.name,
    });

    Team copyWith({
        String? ageGroup,
        String? level,
        String? name,
    }) => 
        Team(
            ageGroup: ageGroup ?? this.ageGroup,
            level: level ?? this.level,
            name: name ?? this.name,
        );

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        ageGroup: json["age_group"],
        level: json["level"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "level": level,
        "name": name,
    };
}

enum WeightedRole {
    ASSISTANT_COACH,
    HEAD_COACH,
    OFFSEASON_COACH,
    SKILLS_COACH
}

final weightedRoleValues = EnumValues({
    "assistant_coach": WeightedRole.ASSISTANT_COACH,
    "head_coach": WeightedRole.HEAD_COACH,
    "offseason_coach": WeightedRole.OFFSEASON_COACH,
    "skills_coach": WeightedRole.SKILLS_COACH
});

class GetAssessmentDetailRequest {
    final String assessmentId;

    GetAssessmentDetailRequest({
        required this.assessmentId,
    });

    GetAssessmentDetailRequest copyWith({
        String? assessmentId,
    }) => 
        GetAssessmentDetailRequest(
            assessmentId: assessmentId ?? this.assessmentId,
        );

    factory GetAssessmentDetailRequest.fromJson(Map<String, dynamic> json) => GetAssessmentDetailRequest(
        assessmentId: json["assessment_id"],
    );

    Map<String, dynamic> toJson() => {
        "assessment_id": assessmentId,
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

