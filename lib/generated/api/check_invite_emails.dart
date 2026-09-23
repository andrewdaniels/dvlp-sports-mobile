// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final checkInviteEmailsData = checkInviteEmailsDataFromJson(jsonString);
//     final checkInviteEmailsRequest = checkInviteEmailsRequestFromJson(jsonString);
//     final inviteEmailResult = inviteEmailResultFromJson(jsonString);
//     final inviteEmailStatus = inviteEmailStatusFromJson(jsonString);

import 'dart:convert';

CheckInviteEmailsData checkInviteEmailsDataFromJson(String str) => CheckInviteEmailsData.fromJson(json.decode(str));

String checkInviteEmailsDataToJson(CheckInviteEmailsData data) => json.encode(data.toJson());

CheckInviteEmailsRequest checkInviteEmailsRequestFromJson(String str) => CheckInviteEmailsRequest.fromJson(json.decode(str));

String checkInviteEmailsRequestToJson(CheckInviteEmailsRequest data) => json.encode(data.toJson());

InviteEmailResult inviteEmailResultFromJson(String str) => InviteEmailResult.fromJson(json.decode(str));

String inviteEmailResultToJson(InviteEmailResult data) => json.encode(data.toJson());

InviteEmailStatus inviteEmailStatusFromJson(String str) => inviteEmailStatusValues.map[json.decode(str)]!;

String inviteEmailStatusToJson(InviteEmailStatus data) => json.encode(inviteEmailStatusValues.reverse[data]);

class CheckInviteEmailsData {
    final List<Result> results;

    CheckInviteEmailsData({
        required this.results,
    });

    CheckInviteEmailsData copyWith({
        List<Result>? results,
    }) => 
        CheckInviteEmailsData(
            results: results ?? this.results,
        );

    factory CheckInviteEmailsData.fromJson(Map<String, dynamic> json) => CheckInviteEmailsData(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    final String email;
    final InviteEmailStatus status;

    Result({
        required this.email,
        required this.status,
    });

    Result copyWith({
        String? email,
        InviteEmailStatus? status,
    }) => 
        Result(
            email: email ?? this.email,
            status: status ?? this.status,
        );

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        email: json["email"],
        status: inviteEmailStatusValues.map[json["status"]]!,
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "status": inviteEmailStatusValues.reverse[status],
    };
}

enum InviteEmailStatus {
    AVAILABLE,
    TAKEN
}

final inviteEmailStatusValues = EnumValues({
    "available": InviteEmailStatus.AVAILABLE,
    "taken": InviteEmailStatus.TAKEN
});

class CheckInviteEmailsRequest {
    final List<String> emails;
    final String organizationId;
    final TargetRole targetRole;

    CheckInviteEmailsRequest({
        required this.emails,
        required this.organizationId,
        required this.targetRole,
    });

    CheckInviteEmailsRequest copyWith({
        List<String>? emails,
        String? organizationId,
        TargetRole? targetRole,
    }) => 
        CheckInviteEmailsRequest(
            emails: emails ?? this.emails,
            organizationId: organizationId ?? this.organizationId,
            targetRole: targetRole ?? this.targetRole,
        );

    factory CheckInviteEmailsRequest.fromJson(Map<String, dynamic> json) => CheckInviteEmailsRequest(
        emails: List<String>.from(json["emails"].map((x) => x)),
        organizationId: json["organization_id"],
        targetRole: targetRoleValues.map[json["target_role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "emails": List<dynamic>.from(emails.map((x) => x)),
        "organization_id": organizationId,
        "target_role": targetRoleValues.reverse[targetRole],
    };
}

enum TargetRole {
    ATHLETE,
    COACH,
    GUARDIAN,
    ORGANIZATION_MANAGER,
    TEAM_MANAGER
}

final targetRoleValues = EnumValues({
    "athlete": TargetRole.ATHLETE,
    "coach": TargetRole.COACH,
    "guardian": TargetRole.GUARDIAN,
    "organization_manager": TargetRole.ORGANIZATION_MANAGER,
    "team_manager": TargetRole.TEAM_MANAGER
});

class InviteEmailResult {
    final String email;
    final InviteEmailStatus status;

    InviteEmailResult({
        required this.email,
        required this.status,
    });

    InviteEmailResult copyWith({
        String? email,
        InviteEmailStatus? status,
    }) => 
        InviteEmailResult(
            email: email ?? this.email,
            status: status ?? this.status,
        );

    factory InviteEmailResult.fromJson(Map<String, dynamic> json) => InviteEmailResult(
        email: json["email"],
        status: inviteEmailStatusValues.map[json["status"]]!,
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "status": inviteEmailStatusValues.reverse[status],
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

