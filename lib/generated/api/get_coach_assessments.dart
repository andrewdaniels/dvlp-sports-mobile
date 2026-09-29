// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getCoachAssessmentsData = getCoachAssessmentsDataFromJson(jsonString);
//     final getCoachAssessmentsRequest = getCoachAssessmentsRequestFromJson(jsonString);

import 'dart:convert';

GetCoachAssessmentsData getCoachAssessmentsDataFromJson(String str) => GetCoachAssessmentsData.fromJson(json.decode(str));

String getCoachAssessmentsDataToJson(GetCoachAssessmentsData data) => json.encode(data.toJson());

GetCoachAssessmentsRequest getCoachAssessmentsRequestFromJson(String str) => GetCoachAssessmentsRequest.fromJson(json.decode(str));

String getCoachAssessmentsRequestToJson(GetCoachAssessmentsRequest data) => json.encode(data.toJson());

class GetCoachAssessmentsData {
    final List<Assessment> assessments;

    GetCoachAssessmentsData({
        required this.assessments,
    });

    GetCoachAssessmentsData copyWith({
        List<Assessment>? assessments,
    }) => 
        GetCoachAssessmentsData(
            assessments: assessments ?? this.assessments,
        );

    factory GetCoachAssessmentsData.fromJson(Map<String, dynamic> json) => GetCoachAssessmentsData(
        assessments: List<Assessment>.from(json["assessments"].map((x) => Assessment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "assessments": List<dynamic>.from(assessments.map((x) => x.toJson())),
    };
}

class Assessment {
    final AccessScope accessScope;
    final AssessmentType assessmentType;
    final Athlete? athlete;
    final bool athleteRead;
    final String id;
    final String submittedAt;
    final Team team;
    final WeightedRole weightedRole;

    Assessment({
        required this.accessScope,
        required this.assessmentType,
        required this.athlete,
        required this.athleteRead,
        required this.id,
        required this.submittedAt,
        required this.team,
        required this.weightedRole,
    });

    Assessment copyWith({
        AccessScope? accessScope,
        AssessmentType? assessmentType,
        Athlete? athlete,
        bool? athleteRead,
        String? id,
        String? submittedAt,
        Team? team,
        WeightedRole? weightedRole,
    }) => 
        Assessment(
            accessScope: accessScope ?? this.accessScope,
            assessmentType: assessmentType ?? this.assessmentType,
            athlete: athlete ?? this.athlete,
            athleteRead: athleteRead ?? this.athleteRead,
            id: id ?? this.id,
            submittedAt: submittedAt ?? this.submittedAt,
            team: team ?? this.team,
            weightedRole: weightedRole ?? this.weightedRole,
        );

    factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        accessScope: accessScopeValues.map[json["access_scope"]]!,
        assessmentType: assessmentTypeValues.map[json["assessment_type"]]!,
        athlete: json["athlete"] == null ? null : Athlete.fromJson(json["athlete"]),
        athleteRead: json["athlete_read"],
        id: json["id"],
        submittedAt: json["submitted_at"],
        team: Team.fromJson(json["team"]),
        weightedRole: weightedRoleValues.map[json["weighted_role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "access_scope": accessScopeValues.reverse[accessScope],
        "assessment_type": assessmentTypeValues.reverse[assessmentType],
        "athlete": athlete?.toJson(),
        "athlete_read": athleteRead,
        "id": id,
        "submitted_at": submittedAt,
        "team": team.toJson(),
        "weighted_role": weightedRoleValues.reverse[weightedRole],
    };
}

enum AccessScope {
    EXTERNAL,
    TEAM
}

final accessScopeValues = EnumValues({
    "external": AccessScope.EXTERNAL,
    "team": AccessScope.TEAM
});

enum AssessmentType {
    FORMAL,
    QUICK
}

final assessmentTypeValues = EnumValues({
    "formal": AssessmentType.FORMAL,
    "quick": AssessmentType.QUICK
});

class Athlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;

    Athlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    Athlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        Athlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory Athlete.fromJson(Map<String, dynamic> json) => Athlete(
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
    final String id;
    final LevelClassification? levelClassification;
    final String name;

    Team({
        required this.ageGroup,
        required this.id,
        required this.levelClassification,
        required this.name,
    });

    Team copyWith({
        String? ageGroup,
        String? id,
        LevelClassification? levelClassification,
        String? name,
    }) => 
        Team(
            ageGroup: ageGroup ?? this.ageGroup,
            id: id ?? this.id,
            levelClassification: levelClassification ?? this.levelClassification,
            name: name ?? this.name,
        );

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        ageGroup: json["age_group"],
        id: json["id"],
        levelClassification: json["level_classification"] == null ? null : LevelClassification.fromJson(json["level_classification"]),
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "id": id,
        "level_classification": levelClassification?.toJson(),
        "name": name,
    };
}

class LevelClassification {
    final String id;
    final String name;
    final int tierOrder;

    LevelClassification({
        required this.id,
        required this.name,
        required this.tierOrder,
    });

    LevelClassification copyWith({
        String? id,
        String? name,
        int? tierOrder,
    }) => 
        LevelClassification(
            id: id ?? this.id,
            name: name ?? this.name,
            tierOrder: tierOrder ?? this.tierOrder,
        );

    factory LevelClassification.fromJson(Map<String, dynamic> json) => LevelClassification(
        id: json["id"],
        name: json["name"],
        tierOrder: json["tier_order"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "tier_order": tierOrder,
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

class GetCoachAssessmentsRequest {
    final String coachId;

    GetCoachAssessmentsRequest({
        required this.coachId,
    });

    GetCoachAssessmentsRequest copyWith({
        String? coachId,
    }) => 
        GetCoachAssessmentsRequest(
            coachId: coachId ?? this.coachId,
        );

    factory GetCoachAssessmentsRequest.fromJson(Map<String, dynamic> json) => GetCoachAssessmentsRequest(
        coachId: json["coach_id"],
    );

    Map<String, dynamic> toJson() => {
        "coach_id": coachId,
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

