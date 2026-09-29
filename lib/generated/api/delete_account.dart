// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final deleteAccountData = deleteAccountDataFromJson(jsonString);

import 'dart:convert';

DeleteAccountData deleteAccountDataFromJson(String str) => DeleteAccountData.fromJson(json.decode(str));

String deleteAccountDataToJson(DeleteAccountData data) => json.encode(data.toJson());

class DeleteAccountData {
    final bool emailSent;
    final bool ok;

    DeleteAccountData({
        required this.emailSent,
        required this.ok,
    });

    DeleteAccountData copyWith({
        bool? emailSent,
        bool? ok,
    }) => 
        DeleteAccountData(
            emailSent: emailSent ?? this.emailSent,
            ok: ok ?? this.ok,
        );

    factory DeleteAccountData.fromJson(Map<String, dynamic> json) => DeleteAccountData(
        emailSent: json["email_sent"],
        ok: json["ok"],
    );

    Map<String, dynamic> toJson() => {
        "email_sent": emailSent,
        "ok": ok,
    };
}

