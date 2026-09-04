// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getCoachesData = getCoachesDataFromJson(jsonString);
//     final getCoachesRequest = getCoachesRequestFromJson(jsonString);

import 'dart:convert';

GetCoachesData getCoachesDataFromJson(String str) => GetCoachesData.fromJson(json.decode(str));

String getCoachesDataToJson(GetCoachesData data) => json.encode(data.toJson());

GetCoachesRequest getCoachesRequestFromJson(String str) => GetCoachesRequest.fromJson(json.decode(str));

String getCoachesRequestToJson(GetCoachesRequest data) => json.encode(data.toJson());

class GetCoachesData {
    final List<Coach> coaches;

    GetCoachesData({
        required this.coaches,
    });

    GetCoachesData copyWith({
        List<Coach>? coaches,
    }) => 
        GetCoachesData(
            coaches: coaches ?? this.coaches,
        );

    factory GetCoachesData.fromJson(Map<String, dynamic> json) => GetCoachesData(
        coaches: List<Coach>.from(json["coaches"].map((x) => Coach.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "coaches": List<dynamic>.from(coaches.map((x) => x.toJson())),
    };
}

class Coach {
    final String? avatarUrl;
    final CoachType coachType;
    final String firstName;
    final String id;
    final String lastName;
    final Team team;

    Coach({
        required this.avatarUrl,
        required this.coachType,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.team,
    });

    Coach copyWith({
        String? avatarUrl,
        CoachType? coachType,
        String? firstName,
        String? id,
        String? lastName,
        Team? team,
    }) => 
        Coach(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            coachType: coachType ?? this.coachType,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            team: team ?? this.team,
        );

    factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        avatarUrl: json["avatar_url"],
        coachType: coachTypeValues.map[json["coach_type"]]!,
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        team: Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "coach_type": coachTypeValues.reverse[coachType],
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "team": team.toJson(),
    };
}

enum CoachType {
    ASSISTANT_COACH,
    HEAD_COACH,
    OFFSEASON_COACH,
    SKILLS_COACH
}

final coachTypeValues = EnumValues({
    "assistant_coach": CoachType.ASSISTANT_COACH,
    "head_coach": CoachType.HEAD_COACH,
    "offseason_coach": CoachType.OFFSEASON_COACH,
    "skills_coach": CoachType.SKILLS_COACH
});

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

class GetCoachesRequest {
    final String? organizationId;
    final String? teamId;

    GetCoachesRequest({
        this.organizationId,
        this.teamId,
    });

    GetCoachesRequest copyWith({
        String? organizationId,
        String? teamId,
    }) => 
        GetCoachesRequest(
            organizationId: organizationId ?? this.organizationId,
            teamId: teamId ?? this.teamId,
        );

    factory GetCoachesRequest.fromJson(Map<String, dynamic> json) => GetCoachesRequest(
        organizationId: json["organization_id"],
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "organization_id": organizationId,
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

