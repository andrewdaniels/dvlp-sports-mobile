// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final coachType = coachTypeFromJson(jsonString);
//     final createInviteData = createInviteDataFromJson(jsonString);
//     final createInviteRequest = createInviteRequestFromJson(jsonString);
//     final inviteTargetRole = inviteTargetRoleFromJson(jsonString);

import 'dart:convert';

CoachType coachTypeFromJson(String str) => coachTypeValues.map[json.decode(str)]!;

String coachTypeToJson(CoachType data) => json.encode(coachTypeValues.reverse[data]);

CreateInviteData createInviteDataFromJson(String str) => CreateInviteData.fromJson(json.decode(str));

String createInviteDataToJson(CreateInviteData data) => json.encode(data.toJson());

CreateInviteRequest createInviteRequestFromJson(String str) => CreateInviteRequest.fromJson(json.decode(str));

String createInviteRequestToJson(CreateInviteRequest data) => json.encode(data.toJson());

InviteTargetRole inviteTargetRoleFromJson(String str) => inviteTargetRoleValues.map[json.decode(str)]!;

String inviteTargetRoleToJson(InviteTargetRole data) => json.encode(inviteTargetRoleValues.reverse[data]);

class CreateInviteData {
    final String code;
    final String expiresAt;
    final String inviteId;
    final bool resent;

    CreateInviteData({
        required this.code,
        required this.expiresAt,
        required this.inviteId,
        required this.resent,
    });

    CreateInviteData copyWith({
        String? code,
        String? expiresAt,
        String? inviteId,
        bool? resent,
    }) => 
        CreateInviteData(
            code: code ?? this.code,
            expiresAt: expiresAt ?? this.expiresAt,
            inviteId: inviteId ?? this.inviteId,
            resent: resent ?? this.resent,
        );

    factory CreateInviteData.fromJson(Map<String, dynamic> json) => CreateInviteData(
        code: json["code"],
        expiresAt: json["expires_at"],
        inviteId: json["invite_id"],
        resent: json["resent"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "expires_at": expiresAt,
        "invite_id": inviteId,
        "resent": resent,
    };
}

class CreateInviteRequest {
    final CoachType? coachType;
    final String email;
    final String? firstName;
    final String? lastName;
    final String? onBehalfOf;
    final String organizationId;
    final InviteTargetRole targetRole;
    final String? teamId;

    CreateInviteRequest({
        this.coachType,
        required this.email,
        this.firstName,
        this.lastName,
        this.onBehalfOf,
        required this.organizationId,
        required this.targetRole,
        this.teamId,
    });

    CreateInviteRequest copyWith({
        CoachType? coachType,
        String? email,
        String? firstName,
        String? lastName,
        String? onBehalfOf,
        String? organizationId,
        InviteTargetRole? targetRole,
        String? teamId,
    }) => 
        CreateInviteRequest(
            coachType: coachType ?? this.coachType,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            onBehalfOf: onBehalfOf ?? this.onBehalfOf,
            organizationId: organizationId ?? this.organizationId,
            targetRole: targetRole ?? this.targetRole,
            teamId: teamId ?? this.teamId,
        );

    factory CreateInviteRequest.fromJson(Map<String, dynamic> json) => CreateInviteRequest(
        coachType: coachTypeValues.map[json["coach_type"]],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        onBehalfOf: json["on_behalf_of"],
        organizationId: json["organization_id"],
        targetRole: inviteTargetRoleValues.map[json["target_role"]]!,
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "coach_type": coachTypeValues.reverse[coachType],
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "on_behalf_of": onBehalfOf,
        "organization_id": organizationId,
        "target_role": inviteTargetRoleValues.reverse[targetRole],
        "team_id": teamId,
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

enum InviteTargetRole {
    ATHLETE,
    COACH,
    GUARDIAN,
    ORGANIZATION_MANAGER,
    TEAM_MANAGER
}

final inviteTargetRoleValues = EnumValues({
    "athlete": InviteTargetRole.ATHLETE,
    "coach": InviteTargetRole.COACH,
    "guardian": InviteTargetRole.GUARDIAN,
    "organization_manager": InviteTargetRole.ORGANIZATION_MANAGER,
    "team_manager": InviteTargetRole.TEAM_MANAGER
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

