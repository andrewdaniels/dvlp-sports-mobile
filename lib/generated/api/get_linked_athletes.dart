// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getLinkedAthletesData = getLinkedAthletesDataFromJson(jsonString);
//     final linkedAthlete = linkedAthleteFromJson(jsonString);

import 'dart:convert';

GetLinkedAthletesData getLinkedAthletesDataFromJson(String str) => GetLinkedAthletesData.fromJson(json.decode(str));

String getLinkedAthletesDataToJson(GetLinkedAthletesData data) => json.encode(data.toJson());

LinkedAthlete linkedAthleteFromJson(String str) => LinkedAthlete.fromJson(json.decode(str));

String linkedAthleteToJson(LinkedAthlete data) => json.encode(data.toJson());

class GetLinkedAthletesData {
    final List<Athlete> athletes;

    GetLinkedAthletesData({
        required this.athletes,
    });

    GetLinkedAthletesData copyWith({
        List<Athlete>? athletes,
    }) => 
        GetLinkedAthletesData(
            athletes: athletes ?? this.athletes,
        );

    factory GetLinkedAthletesData.fromJson(Map<String, dynamic> json) => GetLinkedAthletesData(
        athletes: List<Athlete>.from(json["athletes"].map((x) => Athlete.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "athletes": List<dynamic>.from(athletes.map((x) => x.toJson())),
    };
}

class Athlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;
    final AthletePosition? position;
    final AthleteTeam? team;

    Athlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.position,
        required this.team,
    });

    Athlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
        AthletePosition? position,
        AthleteTeam? team,
    }) => 
        Athlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            position: position ?? this.position,
            team: team ?? this.team,
        );

    factory Athlete.fromJson(Map<String, dynamic> json) => Athlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        position: json["position"] == null ? null : AthletePosition.fromJson(json["position"]),
        team: json["team"] == null ? null : AthleteTeam.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "position": position?.toJson(),
        "team": team?.toJson(),
    };
}

class AthletePosition {
    final String name;

    AthletePosition({
        required this.name,
    });

    AthletePosition copyWith({
        String? name,
    }) => 
        AthletePosition(
            name: name ?? this.name,
        );

    factory AthletePosition.fromJson(Map<String, dynamic> json) => AthletePosition(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class AthleteTeam {
    final String? ageGroup;
    final String? levelClassification;
    final String name;

    AthleteTeam({
        required this.ageGroup,
        required this.levelClassification,
        required this.name,
    });

    AthleteTeam copyWith({
        String? ageGroup,
        String? levelClassification,
        String? name,
    }) => 
        AthleteTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            levelClassification: levelClassification ?? this.levelClassification,
            name: name ?? this.name,
        );

    factory AthleteTeam.fromJson(Map<String, dynamic> json) => AthleteTeam(
        ageGroup: json["age_group"],
        levelClassification: json["level_classification"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "level_classification": levelClassification,
        "name": name,
    };
}

class LinkedAthlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;
    final LinkedAthletePosition? position;
    final LinkedAthleteTeam? team;

    LinkedAthlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.position,
        required this.team,
    });

    LinkedAthlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
        LinkedAthletePosition? position,
        LinkedAthleteTeam? team,
    }) => 
        LinkedAthlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            position: position ?? this.position,
            team: team ?? this.team,
        );

    factory LinkedAthlete.fromJson(Map<String, dynamic> json) => LinkedAthlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        position: json["position"] == null ? null : LinkedAthletePosition.fromJson(json["position"]),
        team: json["team"] == null ? null : LinkedAthleteTeam.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "position": position?.toJson(),
        "team": team?.toJson(),
    };
}

class LinkedAthletePosition {
    final String name;

    LinkedAthletePosition({
        required this.name,
    });

    LinkedAthletePosition copyWith({
        String? name,
    }) => 
        LinkedAthletePosition(
            name: name ?? this.name,
        );

    factory LinkedAthletePosition.fromJson(Map<String, dynamic> json) => LinkedAthletePosition(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class LinkedAthleteTeam {
    final String? ageGroup;
    final String? levelClassification;
    final String name;

    LinkedAthleteTeam({
        required this.ageGroup,
        required this.levelClassification,
        required this.name,
    });

    LinkedAthleteTeam copyWith({
        String? ageGroup,
        String? levelClassification,
        String? name,
    }) => 
        LinkedAthleteTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            levelClassification: levelClassification ?? this.levelClassification,
            name: name ?? this.name,
        );

    factory LinkedAthleteTeam.fromJson(Map<String, dynamic> json) => LinkedAthleteTeam(
        ageGroup: json["age_group"],
        levelClassification: json["level_classification"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "level_classification": levelClassification,
        "name": name,
    };
}

