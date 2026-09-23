// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final sendSignupCodeData = sendSignupCodeDataFromJson(jsonString);
//     final sendSignupCodeRequest = sendSignupCodeRequestFromJson(jsonString);

import 'dart:convert';

SendSignupCodeData sendSignupCodeDataFromJson(String str) => SendSignupCodeData.fromJson(json.decode(str));

String sendSignupCodeDataToJson(SendSignupCodeData data) => json.encode(data.toJson());

SendSignupCodeRequest sendSignupCodeRequestFromJson(String str) => SendSignupCodeRequest.fromJson(json.decode(str));

String sendSignupCodeRequestToJson(SendSignupCodeRequest data) => json.encode(data.toJson());

class SendSignupCodeData {
    final bool sent;

    SendSignupCodeData({
        required this.sent,
    });

    SendSignupCodeData copyWith({
        bool? sent,
    }) => 
        SendSignupCodeData(
            sent: sent ?? this.sent,
        );

    factory SendSignupCodeData.fromJson(Map<String, dynamic> json) => SendSignupCodeData(
        sent: json["sent"],
    );

    Map<String, dynamic> toJson() => {
        "sent": sent,
    };
}

class SendSignupCodeRequest {
    final String email;

    SendSignupCodeRequest({
        required this.email,
    });

    SendSignupCodeRequest copyWith({
        String? email,
    }) => 
        SendSignupCodeRequest(
            email: email ?? this.email,
        );

    factory SendSignupCodeRequest.fromJson(Map<String, dynamic> json) => SendSignupCodeRequest(
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
    };
}

