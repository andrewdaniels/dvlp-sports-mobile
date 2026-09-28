// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final acceptExternalInviteData = acceptExternalInviteDataFromJson(jsonString);
//     final acceptExternalInviteRequest = acceptExternalInviteRequestFromJson(jsonString);

import 'dart:convert';

AcceptExternalInviteData acceptExternalInviteDataFromJson(String str) => AcceptExternalInviteData.fromJson(json.decode(str));

String acceptExternalInviteDataToJson(AcceptExternalInviteData data) => json.encode(data.toJson());

AcceptExternalInviteRequest acceptExternalInviteRequestFromJson(String str) => AcceptExternalInviteRequest.fromJson(json.decode(str));

String acceptExternalInviteRequestToJson(AcceptExternalInviteRequest data) => json.encode(data.toJson());

class AcceptExternalInviteData {
    final bool alreadyAccepted;
    final List<Athlete> athletes;
    final String inviteId;
    final Organization organization;

    AcceptExternalInviteData({
        required this.alreadyAccepted,
        required this.athletes,
        required this.inviteId,
        required this.organization,
    });

    AcceptExternalInviteData copyWith({
        bool? alreadyAccepted,
        List<Athlete>? athletes,
        String? inviteId,
        Organization? organization,
    }) => 
        AcceptExternalInviteData(
            alreadyAccepted: alreadyAccepted ?? this.alreadyAccepted,
            athletes: athletes ?? this.athletes,
            inviteId: inviteId ?? this.inviteId,
            organization: organization ?? this.organization,
        );

    factory AcceptExternalInviteData.fromJson(Map<String, dynamic> json) => AcceptExternalInviteData(
        alreadyAccepted: json["already_accepted"],
        athletes: List<Athlete>.from(json["athletes"].map((x) => Athlete.fromJson(x))),
        inviteId: json["invite_id"],
        organization: Organization.fromJson(json["organization"]),
    );

    Map<String, dynamic> toJson() => {
        "already_accepted": alreadyAccepted,
        "athletes": List<dynamic>.from(athletes.map((x) => x.toJson())),
        "invite_id": inviteId,
        "organization": organization.toJson(),
    };
}

class Athlete {
    final String firstName;
    final String id;
    final String lastName;

    Athlete({
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    Athlete copyWith({
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        Athlete(
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory Athlete.fromJson(Map<String, dynamic> json) => Athlete(
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
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

class AcceptExternalInviteRequest {
    final String code;

    AcceptExternalInviteRequest({
        required this.code,
    });

    AcceptExternalInviteRequest copyWith({
        String? code,
    }) => 
        AcceptExternalInviteRequest(
            code: code ?? this.code,
        );

    factory AcceptExternalInviteRequest.fromJson(Map<String, dynamic> json) => AcceptExternalInviteRequest(
        code: json["code"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
    };
}

