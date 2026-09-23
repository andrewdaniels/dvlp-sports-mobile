// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final updateTeamData = updateTeamDataFromJson(jsonString);
//     final updateTeamRequest = updateTeamRequestFromJson(jsonString);
//     final updateTeamTeam = updateTeamTeamFromJson(jsonString);

import 'dart:convert';

UpdateTeamData updateTeamDataFromJson(String str) => UpdateTeamData.fromJson(json.decode(str));

String updateTeamDataToJson(UpdateTeamData data) => json.encode(data.toJson());

UpdateTeamRequest updateTeamRequestFromJson(String str) => UpdateTeamRequest.fromJson(json.decode(str));

String updateTeamRequestToJson(UpdateTeamRequest data) => json.encode(data.toJson());

UpdateTeamTeam updateTeamTeamFromJson(String str) => UpdateTeamTeam.fromJson(json.decode(str));

String updateTeamTeamToJson(UpdateTeamTeam data) => json.encode(data.toJson());

class UpdateTeamData {
    final Team team;

    UpdateTeamData({
        required this.team,
    });

    UpdateTeamData copyWith({
        Team? team,
    }) => 
        UpdateTeamData(
            team: team ?? this.team,
        );

    factory UpdateTeamData.fromJson(Map<String, dynamic> json) => UpdateTeamData(
        team: Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "team": team.toJson(),
    };
}

class Team {
    final AgeGroup ageGroup;
    final String id;
    final String name;
    final String organizationId;

    Team({
        required this.ageGroup,
        required this.id,
        required this.name,
        required this.organizationId,
    });

    Team copyWith({
        AgeGroup? ageGroup,
        String? id,
        String? name,
        String? organizationId,
    }) => 
        Team(
            ageGroup: ageGroup ?? this.ageGroup,
            id: id ?? this.id,
            name: name ?? this.name,
            organizationId: organizationId ?? this.organizationId,
        );

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        ageGroup: ageGroupValues.map[json["age_group"]]!,
        id: json["id"],
        name: json["name"],
        organizationId: json["organization_id"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroupValues.reverse[ageGroup],
        "id": id,
        "name": name,
        "organization_id": organizationId,
    };
}

enum AgeGroup {
    U10,
    U11,
    U12,
    U13,
    U14,
    U15,
    U16,
    U17,
    U18,
    U7,
    U8,
    U9
}

final ageGroupValues = EnumValues({
    "U10": AgeGroup.U10,
    "U11": AgeGroup.U11,
    "U12": AgeGroup.U12,
    "U13": AgeGroup.U13,
    "U14": AgeGroup.U14,
    "U15": AgeGroup.U15,
    "U16": AgeGroup.U16,
    "U17": AgeGroup.U17,
    "U18": AgeGroup.U18,
    "U7": AgeGroup.U7,
    "U8": AgeGroup.U8,
    "U9": AgeGroup.U9
});

class UpdateTeamRequest {
    final AgeGroup? ageGroup;
    final String? levelClassificationId;
    final String? name;
    final String teamId;

    UpdateTeamRequest({
        this.ageGroup,
        this.levelClassificationId,
        this.name,
        required this.teamId,
    });

    UpdateTeamRequest copyWith({
        AgeGroup? ageGroup,
        String? levelClassificationId,
        String? name,
        String? teamId,
    }) => 
        UpdateTeamRequest(
            ageGroup: ageGroup ?? this.ageGroup,
            levelClassificationId: levelClassificationId ?? this.levelClassificationId,
            name: name ?? this.name,
            teamId: teamId ?? this.teamId,
        );

    factory UpdateTeamRequest.fromJson(Map<String, dynamic> json) => UpdateTeamRequest(
        ageGroup: ageGroupValues.map[json["age_group"]],
        levelClassificationId: json["level_classification_id"],
        name: json["name"],
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroupValues.reverse[ageGroup],
        "level_classification_id": levelClassificationId,
        "name": name,
        "team_id": teamId,
    };
}

class UpdateTeamTeam {
    final AgeGroup ageGroup;
    final String id;
    final String name;
    final String organizationId;

    UpdateTeamTeam({
        required this.ageGroup,
        required this.id,
        required this.name,
        required this.organizationId,
    });

    UpdateTeamTeam copyWith({
        AgeGroup? ageGroup,
        String? id,
        String? name,
        String? organizationId,
    }) => 
        UpdateTeamTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            id: id ?? this.id,
            name: name ?? this.name,
            organizationId: organizationId ?? this.organizationId,
        );

    factory UpdateTeamTeam.fromJson(Map<String, dynamic> json) => UpdateTeamTeam(
        ageGroup: ageGroupValues.map[json["age_group"]]!,
        id: json["id"],
        name: json["name"],
        organizationId: json["organization_id"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroupValues.reverse[ageGroup],
        "id": id,
        "name": name,
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

