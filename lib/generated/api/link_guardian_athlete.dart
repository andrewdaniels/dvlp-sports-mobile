// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final linkGuardianAthleteData = linkGuardianAthleteDataFromJson(jsonString);
//     final linkGuardianAthleteRequest = linkGuardianAthleteRequestFromJson(jsonString);

import 'dart:convert';

LinkGuardianAthleteData linkGuardianAthleteDataFromJson(String str) => LinkGuardianAthleteData.fromJson(json.decode(str));

String linkGuardianAthleteDataToJson(LinkGuardianAthleteData data) => json.encode(data.toJson());

LinkGuardianAthleteRequest linkGuardianAthleteRequestFromJson(String str) => LinkGuardianAthleteRequest.fromJson(json.decode(str));

String linkGuardianAthleteRequestToJson(LinkGuardianAthleteRequest data) => json.encode(data.toJson());

class LinkGuardianAthleteData {
    final Athlete athlete;

    LinkGuardianAthleteData({
        required this.athlete,
    });

    LinkGuardianAthleteData copyWith({
        Athlete? athlete,
    }) => 
        LinkGuardianAthleteData(
            athlete: athlete ?? this.athlete,
        );

    factory LinkGuardianAthleteData.fromJson(Map<String, dynamic> json) => LinkGuardianAthleteData(
        athlete: Athlete.fromJson(json["athlete"]),
    );

    Map<String, dynamic> toJson() => {
        "athlete": athlete.toJson(),
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

class LinkGuardianAthleteRequest {
    final String inviteId;

    LinkGuardianAthleteRequest({
        required this.inviteId,
    });

    LinkGuardianAthleteRequest copyWith({
        String? inviteId,
    }) => 
        LinkGuardianAthleteRequest(
            inviteId: inviteId ?? this.inviteId,
        );

    factory LinkGuardianAthleteRequest.fromJson(Map<String, dynamic> json) => LinkGuardianAthleteRequest(
        inviteId: json["invite_id"],
    );

    Map<String, dynamic> toJson() => {
        "invite_id": inviteId,
    };
}

