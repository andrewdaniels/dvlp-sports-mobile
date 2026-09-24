// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final emailType = emailTypeFromJson(jsonString);
//     final organizationDecision = organizationDecisionFromJson(jsonString);
//     final sendEmailData = sendEmailDataFromJson(jsonString);
//     final sendEmailRequest = sendEmailRequestFromJson(jsonString);

import 'dart:convert';

EmailType emailTypeFromJson(String str) => emailTypeValues.map[json.decode(str)]!;

String emailTypeToJson(EmailType data) => json.encode(emailTypeValues.reverse[data]);

OrganizationDecision organizationDecisionFromJson(String str) => organizationDecisionValues.map[json.decode(str)]!;

String organizationDecisionToJson(OrganizationDecision data) => json.encode(organizationDecisionValues.reverse[data]);

SendEmailData sendEmailDataFromJson(String str) => SendEmailData.fromJson(json.decode(str));

String sendEmailDataToJson(SendEmailData data) => json.encode(data.toJson());

SendEmailRequest sendEmailRequestFromJson(String str) => SendEmailRequest.fromJson(json.decode(str));

String sendEmailRequestToJson(SendEmailRequest data) => json.encode(data.toJson());

class SendEmailData {
    final String emailId;

    SendEmailData({
        required this.emailId,
    });

    SendEmailData copyWith({
        String? emailId,
    }) => 
        SendEmailData(
            emailId: emailId ?? this.emailId,
        );

    factory SendEmailData.fromJson(Map<String, dynamic> json) => SendEmailData(
        emailId: json["email_id"],
    );

    Map<String, dynamic> toJson() => {
        "email_id": emailId,
    };
}

class SendEmailRequest {
    final String? code;
    final String? expiresAt;
    final String? inviterName;
    final String? organizationName;
    final Role? role;
    final String? teamName;
    final String to;
    final EmailType type;
    final String? athleteName;
    final OrganizationDecision? decision;
    final String? gmFirstName;

    SendEmailRequest({
        this.code,
        this.expiresAt,
        this.inviterName,
        this.organizationName,
        this.role,
        this.teamName,
        required this.to,
        required this.type,
        this.athleteName,
        this.decision,
        this.gmFirstName,
    });

    SendEmailRequest copyWith({
        String? code,
        String? expiresAt,
        String? inviterName,
        String? organizationName,
        Role? role,
        String? teamName,
        String? to,
        EmailType? type,
        String? athleteName,
        OrganizationDecision? decision,
        String? gmFirstName,
    }) => 
        SendEmailRequest(
            code: code ?? this.code,
            expiresAt: expiresAt ?? this.expiresAt,
            inviterName: inviterName ?? this.inviterName,
            organizationName: organizationName ?? this.organizationName,
            role: role ?? this.role,
            teamName: teamName ?? this.teamName,
            to: to ?? this.to,
            type: type ?? this.type,
            athleteName: athleteName ?? this.athleteName,
            decision: decision ?? this.decision,
            gmFirstName: gmFirstName ?? this.gmFirstName,
        );

    factory SendEmailRequest.fromJson(Map<String, dynamic> json) => SendEmailRequest(
        code: json["code"],
        expiresAt: json["expires_at"],
        inviterName: json["inviter_name"],
        organizationName: json["organization_name"],
        role: roleValues.map[json["role"]],
        teamName: json["team_name"],
        to: json["to"],
        type: emailTypeValues.map[json["type"]]!,
        athleteName: json["athlete_name"],
        decision: organizationDecisionValues.map[json["decision"]],
        gmFirstName: json["gm_first_name"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "expires_at": expiresAt,
        "inviter_name": inviterName,
        "organization_name": organizationName,
        "role": roleValues.reverse[role],
        "team_name": teamName,
        "to": to,
        "type": emailTypeValues.reverse[type],
        "athlete_name": athleteName,
        "decision": organizationDecisionValues.reverse[decision],
        "gm_first_name": gmFirstName,
    };
}

enum OrganizationDecision {
    ACTIVE,
    DENIED
}

final organizationDecisionValues = EnumValues({
    "active": OrganizationDecision.ACTIVE,
    "denied": OrganizationDecision.DENIED
});

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

enum EmailType {
    GUARDIAN_INVITE,
    INVITE_CODE,
    ORGANIZATION_STATUS_DECISION,
    SIGNUP_VERIFICATION_CODE
}

final emailTypeValues = EnumValues({
    "guardian_invite": EmailType.GUARDIAN_INVITE,
    "invite_code": EmailType.INVITE_CODE,
    "organization_status_decision": EmailType.ORGANIZATION_STATUS_DECISION,
    "signup_verification_code": EmailType.SIGNUP_VERIFICATION_CODE
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

