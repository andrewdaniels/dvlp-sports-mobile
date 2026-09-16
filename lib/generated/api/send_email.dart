// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final emailType = emailTypeFromJson(jsonString);
//     final sendEmailData = sendEmailDataFromJson(jsonString);
//     final sendEmailRequest = sendEmailRequestFromJson(jsonString);

import 'dart:convert';

EmailType emailTypeFromJson(String str) => emailTypeValues.map[json.decode(str)]!;

String emailTypeToJson(EmailType data) => json.encode(emailTypeValues.reverse[data]);

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
    final String code;
    final String? expiresAt;
    final String? inviterName;
    final String? recipientName;
    final Role role;
    final String to;
    final EmailType type;

    SendEmailRequest({
        required this.code,
        this.expiresAt,
        this.inviterName,
        this.recipientName,
        required this.role,
        required this.to,
        required this.type,
    });

    SendEmailRequest copyWith({
        String? code,
        String? expiresAt,
        String? inviterName,
        String? recipientName,
        Role? role,
        String? to,
        EmailType? type,
    }) => 
        SendEmailRequest(
            code: code ?? this.code,
            expiresAt: expiresAt ?? this.expiresAt,
            inviterName: inviterName ?? this.inviterName,
            recipientName: recipientName ?? this.recipientName,
            role: role ?? this.role,
            to: to ?? this.to,
            type: type ?? this.type,
        );

    factory SendEmailRequest.fromJson(Map<String, dynamic> json) => SendEmailRequest(
        code: json["code"],
        expiresAt: json["expires_at"],
        inviterName: json["inviter_name"],
        recipientName: json["recipient_name"],
        role: roleValues.map[json["role"]]!,
        to: json["to"],
        type: emailTypeValues.map[json["type"]]!,
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "expires_at": expiresAt,
        "inviter_name": inviterName,
        "recipient_name": recipientName,
        "role": roleValues.reverse[role],
        "to": to,
        "type": emailTypeValues.reverse[type],
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

enum EmailType {
    INVITE_CODE
}

final emailTypeValues = EnumValues({
    "invite_code": EmailType.INVITE_CODE
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

