// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getTeamRosterData = getTeamRosterDataFromJson(jsonString);
//     final getTeamRosterRequest = getTeamRosterRequestFromJson(jsonString);

import 'dart:convert';

GetTeamRosterData getTeamRosterDataFromJson(String str) => GetTeamRosterData.fromJson(json.decode(str));

String getTeamRosterDataToJson(GetTeamRosterData data) => json.encode(data.toJson());

GetTeamRosterRequest getTeamRosterRequestFromJson(String str) => GetTeamRosterRequest.fromJson(json.decode(str));

String getTeamRosterRequestToJson(GetTeamRosterRequest data) => json.encode(data.toJson());

class GetTeamRosterData {
    final List<ExternalConnection> externalConnections;
    final List<Roster> roster;

    GetTeamRosterData({
        required this.externalConnections,
        required this.roster,
    });

    GetTeamRosterData copyWith({
        List<ExternalConnection>? externalConnections,
        List<Roster>? roster,
    }) => 
        GetTeamRosterData(
            externalConnections: externalConnections ?? this.externalConnections,
            roster: roster ?? this.roster,
        );

    factory GetTeamRosterData.fromJson(Map<String, dynamic> json) => GetTeamRosterData(
        externalConnections: List<ExternalConnection>.from(json["external_connections"].map((x) => ExternalConnection.fromJson(x))),
        roster: List<Roster>.from(json["roster"].map((x) => Roster.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "external_connections": List<dynamic>.from(externalConnections.map((x) => x.toJson())),
        "roster": List<dynamic>.from(roster.map((x) => x.toJson())),
    };
}

class ExternalConnection {
    final ExternalConnectionAthlete athlete;
    final CurrentTeam? currentTeam;
    final ExternalConnectionRanking? ranking;

    ExternalConnection({
        required this.athlete,
        required this.currentTeam,
        required this.ranking,
    });

    ExternalConnection copyWith({
        ExternalConnectionAthlete? athlete,
        CurrentTeam? currentTeam,
        ExternalConnectionRanking? ranking,
    }) => 
        ExternalConnection(
            athlete: athlete ?? this.athlete,
            currentTeam: currentTeam ?? this.currentTeam,
            ranking: ranking ?? this.ranking,
        );

    factory ExternalConnection.fromJson(Map<String, dynamic> json) => ExternalConnection(
        athlete: ExternalConnectionAthlete.fromJson(json["athlete"]),
        currentTeam: json["current_team"] == null ? null : CurrentTeam.fromJson(json["current_team"]),
        ranking: json["ranking"] == null ? null : ExternalConnectionRanking.fromJson(json["ranking"]),
    );

    Map<String, dynamic> toJson() => {
        "athlete": athlete.toJson(),
        "current_team": currentTeam?.toJson(),
        "ranking": ranking?.toJson(),
    };
}

class ExternalConnectionAthlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;
    final PurplePosition? position;

    ExternalConnectionAthlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.position,
    });

    ExternalConnectionAthlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
        PurplePosition? position,
    }) => 
        ExternalConnectionAthlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            position: position ?? this.position,
        );

    factory ExternalConnectionAthlete.fromJson(Map<String, dynamic> json) => ExternalConnectionAthlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        position: json["position"] == null ? null : PurplePosition.fromJson(json["position"]),
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "position": position?.toJson(),
    };
}

class PurplePosition {
    final String id;
    final String name;

    PurplePosition({
        required this.id,
        required this.name,
    });

    PurplePosition copyWith({
        String? id,
        String? name,
    }) => 
        PurplePosition(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory PurplePosition.fromJson(Map<String, dynamic> json) => PurplePosition(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class CurrentTeam {
    final String? ageGroup;
    final String id;
    final String? levelClassification;
    final String name;

    CurrentTeam({
        required this.ageGroup,
        required this.id,
        required this.levelClassification,
        required this.name,
    });

    CurrentTeam copyWith({
        String? ageGroup,
        String? id,
        String? levelClassification,
        String? name,
    }) => 
        CurrentTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            id: id ?? this.id,
            levelClassification: levelClassification ?? this.levelClassification,
            name: name ?? this.name,
        );

    factory CurrentTeam.fromJson(Map<String, dynamic> json) => CurrentTeam(
        ageGroup: json["age_group"],
        id: json["id"],
        levelClassification: json["level_classification"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "id": id,
        "level_classification": levelClassification,
        "name": name,
    };
}

class ExternalConnectionRanking {
    final int assessmentCount;
    final Band band;
    final double overallScore;
    final int subLevel;

    ExternalConnectionRanking({
        required this.assessmentCount,
        required this.band,
        required this.overallScore,
        required this.subLevel,
    });

    ExternalConnectionRanking copyWith({
        int? assessmentCount,
        Band? band,
        double? overallScore,
        int? subLevel,
    }) => 
        ExternalConnectionRanking(
            assessmentCount: assessmentCount ?? this.assessmentCount,
            band: band ?? this.band,
            overallScore: overallScore ?? this.overallScore,
            subLevel: subLevel ?? this.subLevel,
        );

    factory ExternalConnectionRanking.fromJson(Map<String, dynamic> json) => ExternalConnectionRanking(
        assessmentCount: json["assessment_count"],
        band: bandValues.map[json["band"]]!,
        overallScore: json["overall_score"]?.toDouble(),
        subLevel: json["sub_level"],
    );

    Map<String, dynamic> toJson() => {
        "assessment_count": assessmentCount,
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

class Roster {
    final RosterAthlete athlete;
    final RosterRanking? ranking;

    Roster({
        required this.athlete,
        required this.ranking,
    });

    Roster copyWith({
        RosterAthlete? athlete,
        RosterRanking? ranking,
    }) => 
        Roster(
            athlete: athlete ?? this.athlete,
            ranking: ranking ?? this.ranking,
        );

    factory Roster.fromJson(Map<String, dynamic> json) => Roster(
        athlete: RosterAthlete.fromJson(json["athlete"]),
        ranking: json["ranking"] == null ? null : RosterRanking.fromJson(json["ranking"]),
    );

    Map<String, dynamic> toJson() => {
        "athlete": athlete.toJson(),
        "ranking": ranking?.toJson(),
    };
}

class RosterAthlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;
    final FluffyPosition? position;

    RosterAthlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.position,
    });

    RosterAthlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
        FluffyPosition? position,
    }) => 
        RosterAthlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            position: position ?? this.position,
        );

    factory RosterAthlete.fromJson(Map<String, dynamic> json) => RosterAthlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        position: json["position"] == null ? null : FluffyPosition.fromJson(json["position"]),
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "position": position?.toJson(),
    };
}

class FluffyPosition {
    final String id;
    final String name;

    FluffyPosition({
        required this.id,
        required this.name,
    });

    FluffyPosition copyWith({
        String? id,
        String? name,
    }) => 
        FluffyPosition(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory FluffyPosition.fromJson(Map<String, dynamic> json) => FluffyPosition(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class RosterRanking {
    final int assessmentCount;
    final Band band;
    final double overallScore;
    final int subLevel;

    RosterRanking({
        required this.assessmentCount,
        required this.band,
        required this.overallScore,
        required this.subLevel,
    });

    RosterRanking copyWith({
        int? assessmentCount,
        Band? band,
        double? overallScore,
        int? subLevel,
    }) => 
        RosterRanking(
            assessmentCount: assessmentCount ?? this.assessmentCount,
            band: band ?? this.band,
            overallScore: overallScore ?? this.overallScore,
            subLevel: subLevel ?? this.subLevel,
        );

    factory RosterRanking.fromJson(Map<String, dynamic> json) => RosterRanking(
        assessmentCount: json["assessment_count"],
        band: bandValues.map[json["band"]]!,
        overallScore: json["overall_score"]?.toDouble(),
        subLevel: json["sub_level"],
    );

    Map<String, dynamic> toJson() => {
        "assessment_count": assessmentCount,
        "band": bandValues.reverse[band],
        "overall_score": overallScore,
        "sub_level": subLevel,
    };
}

class GetTeamRosterRequest {
    final String teamId;

    GetTeamRosterRequest({
        required this.teamId,
    });

    GetTeamRosterRequest copyWith({
        String? teamId,
    }) => 
        GetTeamRosterRequest(
            teamId: teamId ?? this.teamId,
        );

    factory GetTeamRosterRequest.fromJson(Map<String, dynamic> json) => GetTeamRosterRequest(
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
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

