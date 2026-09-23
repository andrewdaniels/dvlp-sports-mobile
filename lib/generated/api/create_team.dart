// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createTeamData = createTeamDataFromJson(jsonString);
//     final createTeamRequest = createTeamRequestFromJson(jsonString);

import 'dart:convert';

CreateTeamData createTeamDataFromJson(String str) => CreateTeamData.fromJson(json.decode(str));

String createTeamDataToJson(CreateTeamData data) => json.encode(data.toJson());

CreateTeamRequest createTeamRequestFromJson(String str) => CreateTeamRequest.fromJson(json.decode(str));

String createTeamRequestToJson(CreateTeamRequest data) => json.encode(data.toJson());

class CreateTeamData {
    final Team team;

    CreateTeamData({
        required this.team,
    });

    CreateTeamData copyWith({
        Team? team,
    }) => 
        CreateTeamData(
            team: team ?? this.team,
        );

    factory CreateTeamData.fromJson(Map<String, dynamic> json) => CreateTeamData(
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

class CreateTeamRequest {
    final AgeGroup ageGroup;
    final String levelClassificationId;
    final String name;
    final String organizationId;

    CreateTeamRequest({
        required this.ageGroup,
        required this.levelClassificationId,
        required this.name,
        required this.organizationId,
    });

    CreateTeamRequest copyWith({
        AgeGroup? ageGroup,
        String? levelClassificationId,
        String? name,
        String? organizationId,
    }) => 
        CreateTeamRequest(
            ageGroup: ageGroup ?? this.ageGroup,
            levelClassificationId: levelClassificationId ?? this.levelClassificationId,
            name: name ?? this.name,
            organizationId: organizationId ?? this.organizationId,
        );

    factory CreateTeamRequest.fromJson(Map<String, dynamic> json) => CreateTeamRequest(
        ageGroup: ageGroupValues.map[json["age_group"]]!,
        levelClassificationId: json["level_classification_id"],
        name: json["name"],
        organizationId: json["organization_id"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroupValues.reverse[ageGroup],
        "level_classification_id": levelClassificationId,
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

