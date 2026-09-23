// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getOrganizationsData = getOrganizationsDataFromJson(jsonString);

import 'dart:convert';

GetOrganizationsData getOrganizationsDataFromJson(String str) => GetOrganizationsData.fromJson(json.decode(str));

String getOrganizationsDataToJson(GetOrganizationsData data) => json.encode(data.toJson());

class GetOrganizationsData {
    final List<Organization> organizations;

    GetOrganizationsData({
        required this.organizations,
    });

    GetOrganizationsData copyWith({
        List<Organization>? organizations,
    }) => 
        GetOrganizationsData(
            organizations: organizations ?? this.organizations,
        );

    factory GetOrganizationsData.fromJson(Map<String, dynamic> json) => GetOrganizationsData(
        organizations: List<Organization>.from(json["organizations"].map((x) => Organization.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "organizations": List<dynamic>.from(organizations.map((x) => x.toJson())),
    };
}

class Organization {
    final int coachCount;
    final String createdAt;
    final Gm? gm;
    final String id;
    final String name;
    final int playerCount;
    final Sport? sport;
    final Status status;
    final List<Team> teams;

    Organization({
        required this.coachCount,
        required this.createdAt,
        required this.gm,
        required this.id,
        required this.name,
        required this.playerCount,
        required this.sport,
        required this.status,
        required this.teams,
    });

    Organization copyWith({
        int? coachCount,
        String? createdAt,
        Gm? gm,
        String? id,
        String? name,
        int? playerCount,
        Sport? sport,
        Status? status,
        List<Team>? teams,
    }) => 
        Organization(
            coachCount: coachCount ?? this.coachCount,
            createdAt: createdAt ?? this.createdAt,
            gm: gm ?? this.gm,
            id: id ?? this.id,
            name: name ?? this.name,
            playerCount: playerCount ?? this.playerCount,
            sport: sport ?? this.sport,
            status: status ?? this.status,
            teams: teams ?? this.teams,
        );

    factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        coachCount: json["coach_count"],
        createdAt: json["created_at"],
        gm: json["gm"] == null ? null : Gm.fromJson(json["gm"]),
        id: json["id"],
        name: json["name"],
        playerCount: json["player_count"],
        sport: json["sport"] == null ? null : Sport.fromJson(json["sport"]),
        status: statusValues.map[json["status"]]!,
        teams: List<Team>.from(json["teams"].map((x) => Team.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "coach_count": coachCount,
        "created_at": createdAt,
        "gm": gm?.toJson(),
        "id": id,
        "name": name,
        "player_count": playerCount,
        "sport": sport?.toJson(),
        "status": statusValues.reverse[status],
        "teams": List<dynamic>.from(teams.map((x) => x.toJson())),
    };
}

class Gm {
    final String email;
    final String firstName;
    final String id;
    final String lastName;

    Gm({
        required this.email,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    Gm copyWith({
        String? email,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        Gm(
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory Gm.fromJson(Map<String, dynamic> json) => Gm(
        email: json["email"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
    };
}

class Sport {
    final String id;
    final String name;

    Sport({
        required this.id,
        required this.name,
    });

    Sport copyWith({
        String? id,
        String? name,
    }) => 
        Sport(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory Sport.fromJson(Map<String, dynamic> json) => Sport(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

enum Status {
    ACTIVE,
    DENIED,
    PENDING
}

final statusValues = EnumValues({
    "active": Status.ACTIVE,
    "denied": Status.DENIED,
    "pending": Status.PENDING
});

class Team {
    final String ageGroup;
    final String id;
    final String? levelName;
    final String name;

    Team({
        required this.ageGroup,
        required this.id,
        required this.levelName,
        required this.name,
    });

    Team copyWith({
        String? ageGroup,
        String? id,
        String? levelName,
        String? name,
    }) => 
        Team(
            ageGroup: ageGroup ?? this.ageGroup,
            id: id ?? this.id,
            levelName: levelName ?? this.levelName,
            name: name ?? this.name,
        );

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        ageGroup: json["age_group"],
        id: json["id"],
        levelName: json["level_name"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "id": id,
        "level_name": levelName,
        "name": name,
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

