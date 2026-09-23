// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getLevelsData = getLevelsDataFromJson(jsonString);
//     final getLevelsRequest = getLevelsRequestFromJson(jsonString);
//     final levelClassificationRef = levelClassificationRefFromJson(jsonString);

import 'dart:convert';

GetLevelsData getLevelsDataFromJson(String str) => GetLevelsData.fromJson(json.decode(str));

String getLevelsDataToJson(GetLevelsData data) => json.encode(data.toJson());

GetLevelsRequest getLevelsRequestFromJson(String str) => GetLevelsRequest.fromJson(json.decode(str));

String getLevelsRequestToJson(GetLevelsRequest data) => json.encode(data.toJson());

LevelClassificationRef levelClassificationRefFromJson(String str) => LevelClassificationRef.fromJson(json.decode(str));

String levelClassificationRefToJson(LevelClassificationRef data) => json.encode(data.toJson());

class GetLevelsData {
    final List<Level> levels;

    GetLevelsData({
        required this.levels,
    });

    GetLevelsData copyWith({
        List<Level>? levels,
    }) => 
        GetLevelsData(
            levels: levels ?? this.levels,
        );

    factory GetLevelsData.fromJson(Map<String, dynamic> json) => GetLevelsData(
        levels: List<Level>.from(json["levels"].map((x) => Level.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "levels": List<dynamic>.from(levels.map((x) => x.toJson())),
    };
}

class Level {
    final String id;
    final String name;
    final int tierOrder;

    Level({
        required this.id,
        required this.name,
        required this.tierOrder,
    });

    Level copyWith({
        String? id,
        String? name,
        int? tierOrder,
    }) => 
        Level(
            id: id ?? this.id,
            name: name ?? this.name,
            tierOrder: tierOrder ?? this.tierOrder,
        );

    factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json["id"],
        name: json["name"],
        tierOrder: json["tier_order"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "tier_order": tierOrder,
    };
}

class GetLevelsRequest {
    final String sportId;

    GetLevelsRequest({
        required this.sportId,
    });

    GetLevelsRequest copyWith({
        String? sportId,
    }) => 
        GetLevelsRequest(
            sportId: sportId ?? this.sportId,
        );

    factory GetLevelsRequest.fromJson(Map<String, dynamic> json) => GetLevelsRequest(
        sportId: json["sport_id"],
    );

    Map<String, dynamic> toJson() => {
        "sport_id": sportId,
    };
}

class LevelClassificationRef {
    final String id;
    final String name;
    final int tierOrder;

    LevelClassificationRef({
        required this.id,
        required this.name,
        required this.tierOrder,
    });

    LevelClassificationRef copyWith({
        String? id,
        String? name,
        int? tierOrder,
    }) => 
        LevelClassificationRef(
            id: id ?? this.id,
            name: name ?? this.name,
            tierOrder: tierOrder ?? this.tierOrder,
        );

    factory LevelClassificationRef.fromJson(Map<String, dynamic> json) => LevelClassificationRef(
        id: json["id"],
        name: json["name"],
        tierOrder: json["tier_order"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "tier_order": tierOrder,
    };
}

