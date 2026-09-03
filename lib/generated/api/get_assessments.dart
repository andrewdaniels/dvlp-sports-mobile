// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getAssessmentsData = getAssessmentsDataFromJson(jsonString);
//     final getAssessmentsRequest = getAssessmentsRequestFromJson(jsonString);

import 'dart:convert';

GetAssessmentsData getAssessmentsDataFromJson(String str) => GetAssessmentsData.fromJson(json.decode(str));

String getAssessmentsDataToJson(GetAssessmentsData data) => json.encode(data.toJson());

GetAssessmentsRequest getAssessmentsRequestFromJson(String str) => GetAssessmentsRequest.fromJson(json.decode(str));

String getAssessmentsRequestToJson(GetAssessmentsRequest data) => json.encode(data.toJson());

class GetAssessmentsData {
    final List<Assessment> assessments;

    GetAssessmentsData({
        required this.assessments,
    });

    GetAssessmentsData copyWith({
        List<Assessment>? assessments,
    }) => 
        GetAssessmentsData(
            assessments: assessments ?? this.assessments,
        );

    factory GetAssessmentsData.fromJson(Map<String, dynamic> json) => GetAssessmentsData(
        assessments: List<Assessment>.from(json["assessments"].map((x) => Assessment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "assessments": List<dynamic>.from(assessments.map((x) => x.toJson())),
    };
}

class Assessment {
    final AssessmentType assessmentType;
    final bool athleteRead;
    final Coach coach;
    final String id;
    final String submittedAt;
    final Team team;
    final WeightedRole weightedRole;

    Assessment({
        required this.assessmentType,
        required this.athleteRead,
        required this.coach,
        required this.id,
        required this.submittedAt,
        required this.team,
        required this.weightedRole,
    });

    Assessment copyWith({
        AssessmentType? assessmentType,
        bool? athleteRead,
        Coach? coach,
        String? id,
        String? submittedAt,
        Team? team,
        WeightedRole? weightedRole,
    }) => 
        Assessment(
            assessmentType: assessmentType ?? this.assessmentType,
            athleteRead: athleteRead ?? this.athleteRead,
            coach: coach ?? this.coach,
            id: id ?? this.id,
            submittedAt: submittedAt ?? this.submittedAt,
            team: team ?? this.team,
            weightedRole: weightedRole ?? this.weightedRole,
        );

    factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        assessmentType: assessmentTypeValues.map[json["assessment_type"]]!,
        athleteRead: json["athlete_read"],
        coach: Coach.fromJson(json["coach"]),
        id: json["id"],
        submittedAt: json["submitted_at"],
        team: Team.fromJson(json["team"]),
        weightedRole: weightedRoleValues.map[json["weighted_role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "assessment_type": assessmentTypeValues.reverse[assessmentType],
        "athlete_read": athleteRead,
        "coach": coach.toJson(),
        "id": id,
        "submitted_at": submittedAt,
        "team": team.toJson(),
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

class GetAssessmentsRequest {
    final String? athleteId;

    GetAssessmentsRequest({
        this.athleteId,
    });

    GetAssessmentsRequest copyWith({
        String? athleteId,
    }) => 
        GetAssessmentsRequest(
            athleteId: athleteId ?? this.athleteId,
        );

    factory GetAssessmentsRequest.fromJson(Map<String, dynamic> json) => GetAssessmentsRequest(
        athleteId: json["athlete_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
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

