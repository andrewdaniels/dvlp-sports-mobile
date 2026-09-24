// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createNotificationData = createNotificationDataFromJson(jsonString);
//     final createNotificationRequest = createNotificationRequestFromJson(jsonString);

import 'dart:convert';

CreateNotificationData createNotificationDataFromJson(String str) => CreateNotificationData.fromJson(json.decode(str));

String createNotificationDataToJson(CreateNotificationData data) => json.encode(data.toJson());

CreateNotificationRequest createNotificationRequestFromJson(String str) => CreateNotificationRequest.fromJson(json.decode(str));

String createNotificationRequestToJson(CreateNotificationRequest data) => json.encode(data.toJson());

class CreateNotificationData {
    final String notificationId;

    CreateNotificationData({
        required this.notificationId,
    });

    CreateNotificationData copyWith({
        String? notificationId,
    }) => 
        CreateNotificationData(
            notificationId: notificationId ?? this.notificationId,
        );

    factory CreateNotificationData.fromJson(Map<String, dynamic> json) => CreateNotificationData(
        notificationId: json["notification_id"],
    );

    Map<String, dynamic> toJson() => {
        "notification_id": notificationId,
    };
}

class CreateNotificationRequest {
    final Audience? audience;
    final String? profileId;
    final String? resourceId;
    final String? subtitle;
    final String title;
    final Type type;

    CreateNotificationRequest({
        this.audience,
        this.profileId,
        this.resourceId,
        this.subtitle,
        required this.title,
        required this.type,
    });

    CreateNotificationRequest copyWith({
        Audience? audience,
        String? profileId,
        String? resourceId,
        String? subtitle,
        String? title,
        Type? type,
    }) => 
        CreateNotificationRequest(
            audience: audience ?? this.audience,
            profileId: profileId ?? this.profileId,
            resourceId: resourceId ?? this.resourceId,
            subtitle: subtitle ?? this.subtitle,
            title: title ?? this.title,
            type: type ?? this.type,
        );

    factory CreateNotificationRequest.fromJson(Map<String, dynamic> json) => CreateNotificationRequest(
        audience: json["audience"] == null ? null : Audience.fromJson(json["audience"]),
        profileId: json["profile_id"],
        resourceId: json["resource_id"],
        subtitle: json["subtitle"],
        title: json["title"],
        type: typeValues.map[json["type"]]!,
    );

    Map<String, dynamic> toJson() => {
        "audience": audience?.toJson(),
        "profile_id": profileId,
        "resource_id": resourceId,
        "subtitle": subtitle,
        "title": title,
        "type": typeValues.reverse[type],
    };
}

class Audience {
    final String? organizationId;
    final List<Role> roles;
    final String? teamId;

    Audience({
        this.organizationId,
        required this.roles,
        this.teamId,
    });

    Audience copyWith({
        String? organizationId,
        List<Role>? roles,
        String? teamId,
    }) => 
        Audience(
            organizationId: organizationId ?? this.organizationId,
            roles: roles ?? this.roles,
            teamId: teamId ?? this.teamId,
        );

    factory Audience.fromJson(Map<String, dynamic> json) => Audience(
        organizationId: json["organization_id"],
        roles: List<Role>.from(json["roles"].map((x) => roleValues.map[x]!)),
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "organization_id": organizationId,
        "roles": List<dynamic>.from(roles.map((x) => roleValues.reverse[x])),
        "team_id": teamId,
    };
}

enum Role {
    ADMIN,
    ATHLETE,
    COACH,
    GUARDIAN,
    ORGANIZATION_MANAGER,
    TEAM_MANAGER
}

final roleValues = EnumValues({
    "admin": Role.ADMIN,
    "athlete": Role.ATHLETE,
    "coach": Role.COACH,
    "guardian": Role.GUARDIAN,
    "organization_manager": Role.ORGANIZATION_MANAGER,
    "team_manager": Role.TEAM_MANAGER
});

enum Type {
    ASSESSMENT_REQUESTED_QUICK,
    ASSESSMENT_SUBMITTED_FORMAL,
    ASSESSMENT_SUBMITTED_QUICK,
    GUARDIAN_LINKED,
    ORGANIZATION_APPROVED,
    ORGANIZATION_DENIED
}

final typeValues = EnumValues({
    "assessment_requested_quick": Type.ASSESSMENT_REQUESTED_QUICK,
    "assessment_submitted_formal": Type.ASSESSMENT_SUBMITTED_FORMAL,
    "assessment_submitted_quick": Type.ASSESSMENT_SUBMITTED_QUICK,
    "guardian_linked": Type.GUARDIAN_LINKED,
    "organization_approved": Type.ORGANIZATION_APPROVED,
    "organization_denied": Type.ORGANIZATION_DENIED
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}

