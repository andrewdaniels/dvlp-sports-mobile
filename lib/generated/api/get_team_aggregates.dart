// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getTeamAggregatesData = getTeamAggregatesDataFromJson(jsonString);
//     final getTeamAggregatesRequest = getTeamAggregatesRequestFromJson(jsonString);

import 'dart:convert';

GetTeamAggregatesData getTeamAggregatesDataFromJson(String str) => GetTeamAggregatesData.fromJson(json.decode(str));

String getTeamAggregatesDataToJson(GetTeamAggregatesData data) => json.encode(data.toJson());

GetTeamAggregatesRequest getTeamAggregatesRequestFromJson(String str) => GetTeamAggregatesRequest.fromJson(json.decode(str));

String getTeamAggregatesRequestToJson(GetTeamAggregatesRequest data) => json.encode(data.toJson());

class GetTeamAggregatesData {
    final AvgTier? avgTier;
    final List<SkillAverage> skillAverages;

    GetTeamAggregatesData({
        required this.avgTier,
        required this.skillAverages,
    });

    GetTeamAggregatesData copyWith({
        AvgTier? avgTier,
        List<SkillAverage>? skillAverages,
    }) => 
        GetTeamAggregatesData(
            avgTier: avgTier ?? this.avgTier,
            skillAverages: skillAverages ?? this.skillAverages,
        );

    factory GetTeamAggregatesData.fromJson(Map<String, dynamic> json) => GetTeamAggregatesData(
        avgTier: json["avg_tier"] == null ? null : AvgTier.fromJson(json["avg_tier"]),
        skillAverages: List<SkillAverage>.from(json["skill_averages"].map((x) => SkillAverage.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "avg_tier": avgTier?.toJson(),
        "skill_averages": List<dynamic>.from(skillAverages.map((x) => x.toJson())),
    };
}

class AvgTier {
    final Band band;
    final double overallScore;
    final int subLevel;

    AvgTier({
        required this.band,
        required this.overallScore,
        required this.subLevel,
    });

    AvgTier copyWith({
        Band? band,
        double? overallScore,
        int? subLevel,
    }) => 
        AvgTier(
            band: band ?? this.band,
            overallScore: overallScore ?? this.overallScore,
            subLevel: subLevel ?? this.subLevel,
        );

    factory AvgTier.fromJson(Map<String, dynamic> json) => AvgTier(
        band: bandValues.map[json["band"]]!,
        overallScore: json["overall_score"]?.toDouble(),
        subLevel: json["sub_level"],
    );

    Map<String, dynamic> toJson() => {
        "band": bandValues.reverse[band],
        "overall_score": overallScore,
        "sub_level": subLevel,
    };
}

enum Band {
    BEGINNER,
    BRONZE,
    ELITE,
    GOLD,
    SILVER
}

final bandValues = EnumValues({
    "beginner": Band.BEGINNER,
    "bronze": Band.BRONZE,
    "elite": Band.ELITE,
    "gold": Band.GOLD,
    "silver": Band.SILVER
});

class SkillAverage {
    final double? avgScore;
    final String name;
    final String skillId;

    SkillAverage({
        required this.avgScore,
        required this.name,
        required this.skillId,
    });

    SkillAverage copyWith({
        double? avgScore,
        String? name,
        String? skillId,
    }) => 
        SkillAverage(
            avgScore: avgScore ?? this.avgScore,
            name: name ?? this.name,
            skillId: skillId ?? this.skillId,
        );

    factory SkillAverage.fromJson(Map<String, dynamic> json) => SkillAverage(
        avgScore: json["avg_score"]?.toDouble(),
        name: json["name"],
        skillId: json["skill_id"],
    );

    Map<String, dynamic> toJson() => {
        "avg_score": avgScore,
        "name": name,
        "skill_id": skillId,
    };
}

class GetTeamAggregatesRequest {
    final String teamId;

    GetTeamAggregatesRequest({
        required this.teamId,
    });

    GetTeamAggregatesRequest copyWith({
        String? teamId,
    }) => 
        GetTeamAggregatesRequest(
            teamId: teamId ?? this.teamId,
        );

    factory GetTeamAggregatesRequest.fromJson(Map<String, dynamic> json) => GetTeamAggregatesRequest(
        teamId: json["team_id"],
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
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

