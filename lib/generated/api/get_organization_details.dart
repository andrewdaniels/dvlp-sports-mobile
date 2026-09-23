// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final coachType = coachTypeFromJson(jsonString);
//     final getOrganizationDetailsData = getOrganizationDetailsDataFromJson(jsonString);
//     final getOrganizationDetailsRequest = getOrganizationDetailsRequestFromJson(jsonString);

import 'dart:convert';

CoachType coachTypeFromJson(String str) => coachTypeValues.map[json.decode(str)]!;

String coachTypeToJson(CoachType data) => json.encode(coachTypeValues.reverse[data]);

GetOrganizationDetailsData getOrganizationDetailsDataFromJson(String str) => GetOrganizationDetailsData.fromJson(json.decode(str));

String getOrganizationDetailsDataToJson(GetOrganizationDetailsData data) => json.encode(data.toJson());

GetOrganizationDetailsRequest getOrganizationDetailsRequestFromJson(String str) => GetOrganizationDetailsRequest.fromJson(json.decode(str));

String getOrganizationDetailsRequestToJson(GetOrganizationDetailsRequest data) => json.encode(data.toJson());

class GetOrganizationDetailsData {
    final String? gmPhone;
    final List<Team> teams;

    GetOrganizationDetailsData({
        required this.gmPhone,
        required this.teams,
    });

    GetOrganizationDetailsData copyWith({
        String? gmPhone,
        List<Team>? teams,
    }) => 
        GetOrganizationDetailsData(
            gmPhone: gmPhone ?? this.gmPhone,
            teams: teams ?? this.teams,
        );

    factory GetOrganizationDetailsData.fromJson(Map<String, dynamic> json) => GetOrganizationDetailsData(
        gmPhone: json["gm_phone"],
        teams: List<Team>.from(json["teams"].map((x) => Team.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "gm_phone": gmPhone,
        "teams": List<dynamic>.from(teams.map((x) => x.toJson())),
    };
}

class Team {
    final String ageGroup;
    final List<Coach> coaches;
    final String id;
    final String levelName;
    final List<Player> players;

    Team({
        required this.ageGroup,
        required this.coaches,
        required this.id,
        required this.levelName,
        required this.players,
    });

    Team copyWith({
        String? ageGroup,
        List<Coach>? coaches,
        String? id,
        String? levelName,
        List<Player>? players,
    }) => 
        Team(
            ageGroup: ageGroup ?? this.ageGroup,
            coaches: coaches ?? this.coaches,
            id: id ?? this.id,
            levelName: levelName ?? this.levelName,
            players: players ?? this.players,
        );

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        ageGroup: json["age_group"],
        coaches: List<Coach>.from(json["coaches"].map((x) => Coach.fromJson(x))),
        id: json["id"],
        levelName: json["level_name"],
        players: List<Player>.from(json["players"].map((x) => Player.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "coaches": List<dynamic>.from(coaches.map((x) => x.toJson())),
        "id": id,
        "level_name": levelName,
        "players": List<dynamic>.from(players.map((x) => x.toJson())),
    };
}

class Coach {
    final String? avatarUrl;
    final CoachType coachType;
    final String firstName;
    final String id;
    final String lastName;

    Coach({
        required this.avatarUrl,
        required this.coachType,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    Coach copyWith({
        String? avatarUrl,
        CoachType? coachType,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        Coach(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            coachType: coachType ?? this.coachType,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        avatarUrl: json["avatar_url"],
        coachType: coachTypeValues.map[json["coach_type"]]!,
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "coach_type": coachTypeValues.reverse[coachType],
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
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

class Player {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;
    final Ranking? ranking;

    Player({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.ranking,
    });

    Player copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
        Ranking? ranking,
    }) => 
        Player(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            ranking: ranking ?? this.ranking,
        );

    factory Player.fromJson(Map<String, dynamic> json) => Player(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        ranking: json["ranking"] == null ? null : Ranking.fromJson(json["ranking"]),
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "ranking": ranking?.toJson(),
    };
}

class Ranking {
    final Band band;
    final double overallScore;
    final int subLevel;

    Ranking({
        required this.band,
        required this.overallScore,
        required this.subLevel,
    });

    Ranking copyWith({
        Band? band,
        double? overallScore,
        int? subLevel,
    }) => 
        Ranking(
            band: band ?? this.band,
            overallScore: overallScore ?? this.overallScore,
            subLevel: subLevel ?? this.subLevel,
        );

    factory Ranking.fromJson(Map<String, dynamic> json) => Ranking(
        band: bandValues.map[json["band"]]!,
        overallScore: json["overall_score"]?.toDouble(),
        subLevel: json["sub_level"],
    );

    Map<String, dynamic> toJson() => {
        "band": bandValues.reverse[band],
        "overall_score": overallScore,
        "sub_level": subLevel,
    };
}

enum Band {
    BEGINNER,
    BRONZE,
    ELITE,
    GOLD,
    SILVER
}

final bandValues = EnumValues({
    "beginner": Band.BEGINNER,
    "bronze": Band.BRONZE,
    "elite": Band.ELITE,
    "gold": Band.GOLD,
    "silver": Band.SILVER
});

class GetOrganizationDetailsRequest {
    final String organizationId;

    GetOrganizationDetailsRequest({
        required this.organizationId,
    });

    GetOrganizationDetailsRequest copyWith({
        String? organizationId,
    }) => 
        GetOrganizationDetailsRequest(
            organizationId: organizationId ?? this.organizationId,
        );

    factory GetOrganizationDetailsRequest.fromJson(Map<String, dynamic> json) => GetOrganizationDetailsRequest(
        organizationId: json["organization_id"],
    );

    Map<String, dynamic> toJson() => {
        "organization_id": organizationId,
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

