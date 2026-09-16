// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final validateInviteData = validateInviteDataFromJson(jsonString);
//     final validateInviteRequest = validateInviteRequestFromJson(jsonString);

import 'dart:convert';

ValidateInviteData validateInviteDataFromJson(String str) => ValidateInviteData.fromJson(json.decode(str));

String validateInviteDataToJson(ValidateInviteData data) => json.encode(data.toJson());

ValidateInviteRequest validateInviteRequestFromJson(String str) => ValidateInviteRequest.fromJson(json.decode(str));

String validateInviteRequestToJson(ValidateInviteRequest data) => json.encode(data.toJson());

class ValidateInviteData {
    final String email;
    final DateTime expiresAt;
    final String? firstName;
    final String inviteId;
    final String? lastName;
    final Organization organization;
    final TargetRole targetRole;
    final Team? team;

    ValidateInviteData({
        required this.email,
        required this.expiresAt,
        required this.firstName,
        required this.inviteId,
        required this.lastName,
        required this.organization,
        required this.targetRole,
        required this.team,
    });

    ValidateInviteData copyWith({
        String? email,
        DateTime? expiresAt,
        String? firstName,
        String? inviteId,
        String? lastName,
        Organization? organization,
        TargetRole? targetRole,
        Team? team,
    }) => 
        ValidateInviteData(
            email: email ?? this.email,
            expiresAt: expiresAt ?? this.expiresAt,
            firstName: firstName ?? this.firstName,
            inviteId: inviteId ?? this.inviteId,
            lastName: lastName ?? this.lastName,
            organization: organization ?? this.organization,
            targetRole: targetRole ?? this.targetRole,
            team: team ?? this.team,
        );

    factory ValidateInviteData.fromJson(Map<String, dynamic> json) => ValidateInviteData(
        email: json["email"],
        expiresAt: DateTime.parse(json["expires_at"]),
        firstName: json["first_name"],
        inviteId: json["invite_id"],
        lastName: json["last_name"],
        organization: Organization.fromJson(json["organization"]),
        targetRole: targetRoleValues.map[json["target_role"]]!,
        team: json["team"] == null ? null : Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "expires_at": expiresAt.toIso8601String(),
        "first_name": firstName,
        "invite_id": inviteId,
        "last_name": lastName,
        "organization": organization.toJson(),
        "target_role": targetRoleValues.reverse[targetRole],
        "team": team?.toJson(),
    };
}

class Organization {
    final String id;
    final String name;

    Organization({
        required this.id,
        required this.name,
    });

    Organization copyWith({
        String? id,
        String? name,
    }) => 
        Organization(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

enum TargetRole {
    ADMIN,
    ATHLETE,
    COACH,
    GUARDIAN,
    ORGANIZATION_MANAGER,
    TEAM_MANAGER
}

final targetRoleValues = EnumValues({
    "admin": TargetRole.ADMIN,
    "athlete": TargetRole.ATHLETE,
    "coach": TargetRole.COACH,
    "guardian": TargetRole.GUARDIAN,
    "organization_manager": TargetRole.ORGANIZATION_MANAGER,
    "team_manager": TargetRole.TEAM_MANAGER
});

class Team {
    final String? ageGroup;
    final String id;
    final String? levelClassification;
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
        String? levelClassification,
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

class ValidateInviteRequest {
    final List<TargetRole>? allowedRoles;
    final String code;

    ValidateInviteRequest({
        this.allowedRoles,
        required this.code,
    });

    ValidateInviteRequest copyWith({
        List<TargetRole>? allowedRoles,
        String? code,
    }) => 
        ValidateInviteRequest(
            allowedRoles: allowedRoles ?? this.allowedRoles,
            code: code ?? this.code,
        );

    factory ValidateInviteRequest.fromJson(Map<String, dynamic> json) => ValidateInviteRequest(
        allowedRoles: json["allowed_roles"] == null ? [] : List<TargetRole>.from(json["allowed_roles"]!.map((x) => targetRoleValues.map[x]!)),
        code: json["code"],
    );

    Map<String, dynamic> toJson() => {
        "allowed_roles": allowedRoles == null ? [] : List<dynamic>.from(allowedRoles!.map((x) => targetRoleValues.reverse[x])),
        "code": code,
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

