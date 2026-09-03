// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getPositionsData = getPositionsDataFromJson(jsonString);
//     final getPositionsRequest = getPositionsRequestFromJson(jsonString);
//     final position = positionFromJson(jsonString);

import 'dart:convert';

GetPositionsData getPositionsDataFromJson(String str) => GetPositionsData.fromJson(json.decode(str));

String getPositionsDataToJson(GetPositionsData data) => json.encode(data.toJson());

GetPositionsRequest getPositionsRequestFromJson(String str) => GetPositionsRequest.fromJson(json.decode(str));

String getPositionsRequestToJson(GetPositionsRequest data) => json.encode(data.toJson());

Position positionFromJson(String str) => Position.fromJson(json.decode(str));

String positionToJson(Position data) => json.encode(data.toJson());

class GetPositionsData {
    final List<PositionElement> positions;
    final Sport sport;

    GetPositionsData({
        required this.positions,
        required this.sport,
    });

    GetPositionsData copyWith({
        List<PositionElement>? positions,
        Sport? sport,
    }) => 
        GetPositionsData(
            positions: positions ?? this.positions,
            sport: sport ?? this.sport,
        );

    factory GetPositionsData.fromJson(Map<String, dynamic> json) => GetPositionsData(
        positions: List<PositionElement>.from(json["positions"].map((x) => PositionElement.fromJson(x))),
        sport: Sport.fromJson(json["sport"]),
    );

    Map<String, dynamic> toJson() => {
        "positions": List<dynamic>.from(positions.map((x) => x.toJson())),
        "sport": sport.toJson(),
    };
}

class PositionElement {
    final String id;
    final String name;

    PositionElement({
        required this.id,
        required this.name,
    });

    PositionElement copyWith({
        String? id,
        String? name,
    }) => 
        PositionElement(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory PositionElement.fromJson(Map<String, dynamic> json) => PositionElement(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
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

class GetPositionsRequest {
    final String? sportId;

    GetPositionsRequest({
        this.sportId,
    });

    GetPositionsRequest copyWith({
        String? sportId,
    }) => 
        GetPositionsRequest(
            sportId: sportId ?? this.sportId,
        );

    factory GetPositionsRequest.fromJson(Map<String, dynamic> json) => GetPositionsRequest(
        sportId: json["sport_id"],
    );

    Map<String, dynamic> toJson() => {
        "sport_id": sportId,
    };
}

class Position {
    final String id;
    final String name;

    Position({
        required this.id,
        required this.name,
    });

    Position copyWith({
        String? id,
        String? name,
    }) => 
        Position(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory Position.fromJson(Map<String, dynamic> json) => Position(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

