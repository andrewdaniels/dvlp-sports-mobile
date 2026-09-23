// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final validateSignupCodeData = validateSignupCodeDataFromJson(jsonString);
//     final validateSignupCodeRequest = validateSignupCodeRequestFromJson(jsonString);

import 'dart:convert';

ValidateSignupCodeData validateSignupCodeDataFromJson(String str) => ValidateSignupCodeData.fromJson(json.decode(str));

String validateSignupCodeDataToJson(ValidateSignupCodeData data) => json.encode(data.toJson());

ValidateSignupCodeRequest validateSignupCodeRequestFromJson(String str) => ValidateSignupCodeRequest.fromJson(json.decode(str));

String validateSignupCodeRequestToJson(ValidateSignupCodeRequest data) => json.encode(data.toJson());

class ValidateSignupCodeData {
    final String verificationToken;

    ValidateSignupCodeData({
        required this.verificationToken,
    });

    ValidateSignupCodeData copyWith({
        String? verificationToken,
    }) => 
        ValidateSignupCodeData(
            verificationToken: verificationToken ?? this.verificationToken,
        );

    factory ValidateSignupCodeData.fromJson(Map<String, dynamic> json) => ValidateSignupCodeData(
        verificationToken: json["verification_token"],
    );

    Map<String, dynamic> toJson() => {
        "verification_token": verificationToken,
    };
}

class ValidateSignupCodeRequest {
    final String code;
    final String email;

    ValidateSignupCodeRequest({
        required this.code,
        required this.email,
    });

    ValidateSignupCodeRequest copyWith({
        String? code,
        String? email,
    }) => 
        ValidateSignupCodeRequest(
            code: code ?? this.code,
            email: email ?? this.email,
        );

    factory ValidateSignupCodeRequest.fromJson(Map<String, dynamic> json) => ValidateSignupCodeRequest(
        code: json["code"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "email": email,
    };
}

