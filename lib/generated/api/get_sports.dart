// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getSportsData = getSportsDataFromJson(jsonString);
//     final sportRef = sportRefFromJson(jsonString);

import 'dart:convert';

GetSportsData getSportsDataFromJson(String str) => GetSportsData.fromJson(json.decode(str));

String getSportsDataToJson(GetSportsData data) => json.encode(data.toJson());

SportRef sportRefFromJson(String str) => SportRef.fromJson(json.decode(str));

String sportRefToJson(SportRef data) => json.encode(data.toJson());

class GetSportsData {
    final List<Sport> sports;

    GetSportsData({
        required this.sports,
    });

    GetSportsData copyWith({
        List<Sport>? sports,
    }) => 
        GetSportsData(
            sports: sports ?? this.sports,
        );

    factory GetSportsData.fromJson(Map<String, dynamic> json) => GetSportsData(
        sports: List<Sport>.from(json["sports"].map((x) => Sport.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "sports": List<dynamic>.from(sports.map((x) => x.toJson())),
    };
}

class Sport {
    final String id;
    final String name;

    Sport({
        required this.id,
        required this.name,
    });

    Sport copyWith({
        String? id,
        String? name,
    }) => 
        Sport(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory Sport.fromJson(Map<String, dynamic> json) => Sport(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class SportRef {
    final String id;
    final String name;

    SportRef({
        required this.id,
        required this.name,
    });

    SportRef copyWith({
        String? id,
        String? name,
    }) => 
        SportRef(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory SportRef.fromJson(Map<String, dynamic> json) => SportRef(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

