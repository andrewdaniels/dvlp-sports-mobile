// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getProfileData = getProfileDataFromJson(jsonString);
//     final getProfileRequest = getProfileRequestFromJson(jsonString);

import 'dart:convert';

GetProfileData getProfileDataFromJson(String str) => GetProfileData.fromJson(json.decode(str));

String getProfileDataToJson(GetProfileData data) => json.encode(data.toJson());

GetProfileRequest getProfileRequestFromJson(String str) => GetProfileRequest.fromJson(json.decode(str));

String getProfileRequestToJson(GetProfileRequest data) => json.encode(data.toJson());

class GetProfileData {
    final AthleteDetails? athleteDetails;
    final String? avatarUrl;
    final DateTime createdAt;
    final String? dateOfBirth;
    final String email;
    final String firstName;
    final String id;
    final String lastName;
    final String? phone;
    final ProfileStatus profileStatus;
    final RoleTier roleTier;
    final List<TeamMembership> teamMemberships;
    final DateTime updatedAt;

    GetProfileData({
        required this.athleteDetails,
        required this.avatarUrl,
        required this.createdAt,
        required this.dateOfBirth,
        required this.email,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.phone,
        required this.profileStatus,
        required this.roleTier,
        required this.teamMemberships,
        required this.updatedAt,
    });

    GetProfileData copyWith({
        AthleteDetails? athleteDetails,
        String? avatarUrl,
        DateTime? createdAt,
        String? dateOfBirth,
        String? email,
        String? firstName,
        String? id,
        String? lastName,
        String? phone,
        ProfileStatus? profileStatus,
        RoleTier? roleTier,
        List<TeamMembership>? teamMemberships,
        DateTime? updatedAt,
    }) => 
        GetProfileData(
            athleteDetails: athleteDetails ?? this.athleteDetails,
            avatarUrl: avatarUrl ?? this.avatarUrl,
            createdAt: createdAt ?? this.createdAt,
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            phone: phone ?? this.phone,
            profileStatus: profileStatus ?? this.profileStatus,
            roleTier: roleTier ?? this.roleTier,
            teamMemberships: teamMemberships ?? this.teamMemberships,
            updatedAt: updatedAt ?? this.updatedAt,
        );

    factory GetProfileData.fromJson(Map<String, dynamic> json) => GetProfileData(
        athleteDetails: json["athlete_details"] == null ? null : AthleteDetails.fromJson(json["athlete_details"]),
        avatarUrl: json["avatar_url"],
        createdAt: DateTime.parse(json["created_at"]),
        dateOfBirth: json["date_of_birth"],
        email: json["email"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        phone: json["phone"],
        profileStatus: profileStatusValues.map[json["profile_status"]]!,
        roleTier: roleTierValues.map[json["role_tier"]]!,
        teamMemberships: List<TeamMembership>.from(json["team_memberships"].map((x) => TeamMembership.fromJson(x))),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "athlete_details": athleteDetails?.toJson(),
        "avatar_url": avatarUrl,
        "created_at": createdAt.toIso8601String(),
        "date_of_birth": dateOfBirth,
        "email": email,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
        "phone": phone,
        "profile_status": profileStatusValues.reverse[profileStatus],
        "role_tier": roleTierValues.reverse[roleTier],
        "team_memberships": List<dynamic>.from(teamMemberships.map((x) => x.toJson())),
        "updated_at": updatedAt.toIso8601String(),
    };
}

class AthleteDetails {
    final DominantSide? dominantSide;
    final double? heightCm;
    final Position? position;
    final double? weightKg;

    AthleteDetails({
        required this.dominantSide,
        required this.heightCm,
        required this.position,
        required this.weightKg,
    });

    AthleteDetails copyWith({
        DominantSide? dominantSide,
        double? heightCm,
        Position? position,
        double? weightKg,
    }) => 
        AthleteDetails(
            dominantSide: dominantSide ?? this.dominantSide,
            heightCm: heightCm ?? this.heightCm,
            position: position ?? this.position,
            weightKg: weightKg ?? this.weightKg,
        );

    factory AthleteDetails.fromJson(Map<String, dynamic> json) => AthleteDetails(
        dominantSide: dominantSideValues.map[json["dominant_side"]],
        heightCm: json["height_cm"]?.toDouble(),
        position: json["position"] == null ? null : Position.fromJson(json["position"]),
        weightKg: json["weight_kg"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "dominant_side": dominantSideValues.reverse[dominantSide],
        "height_cm": heightCm,
        "position": position?.toJson(),
        "weight_kg": weightKg,
    };
}

enum DominantSide {
    AMBIDEXTROUS,
    LEFT,
    RIGHT
}

final dominantSideValues = EnumValues({
    "ambidextrous": DominantSide.AMBIDEXTROUS,
    "left": DominantSide.LEFT,
    "right": DominantSide.RIGHT
});

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

enum ProfileStatus {
    ACTIVE,
    PENDING,
    REJECTED
}

final profileStatusValues = EnumValues({
    "active": ProfileStatus.ACTIVE,
    "pending": ProfileStatus.PENDING,
    "rejected": ProfileStatus.REJECTED
});

enum RoleTier {
    ADMIN,
    ATHLETE,
    COACH,
    GUARDIAN,
    ORGANIZATION_MANAGER,
    TEAM_MANAGER
}

final roleTierValues = EnumValues({
    "admin": RoleTier.ADMIN,
    "athlete": RoleTier.ATHLETE,
    "coach": RoleTier.COACH,
    "guardian": RoleTier.GUARDIAN,
    "organization_manager": RoleTier.ORGANIZATION_MANAGER,
    "team_manager": RoleTier.TEAM_MANAGER
});

class TeamMembership {
    final CoachType? coachType;
    final DateTime joinedAt;
    final Organization organization;
    final Team team;

    TeamMembership({
        required this.coachType,
        required this.joinedAt,
        required this.organization,
        required this.team,
    });

    TeamMembership copyWith({
        CoachType? coachType,
        DateTime? joinedAt,
        Organization? organization,
        Team? team,
    }) => 
        TeamMembership(
            coachType: coachType ?? this.coachType,
            joinedAt: joinedAt ?? this.joinedAt,
            organization: organization ?? this.organization,
            team: team ?? this.team,
        );

    factory TeamMembership.fromJson(Map<String, dynamic> json) => TeamMembership(
        coachType: coachTypeValues.map[json["coach_type"]],
        joinedAt: DateTime.parse(json["joined_at"]),
        organization: Organization.fromJson(json["organization"]),
        team: Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "coach_type": coachTypeValues.reverse[coachType],
        "joined_at": joinedAt.toIso8601String(),
        "organization": organization.toJson(),
        "team": team.toJson(),
    };
}

enum CoachType {
    ASSISTANT_COACH,
    HEAD_COACH,
    OFFSEASON_COACH,
    SKILLS_COACH
}

final coachTypeValues = EnumValues({
    "assistant_coach": CoachType.ASSISTANT_COACH,
    "head_coach": CoachType.HEAD_COACH,
    "offseason_coach": CoachType.OFFSEASON_COACH,
    "skills_coach": CoachType.SKILLS_COACH
});

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

class Team {
    final String? ageGroup;
    final AssessmentCadence assessmentCadence;
    final String id;
    final String? levelClassification;
    final String name;
    final int? ranking;

    Team({
        required this.ageGroup,
        required this.assessmentCadence,
        required this.id,
        required this.levelClassification,
        required this.name,
        required this.ranking,
    });

    Team copyWith({
        String? ageGroup,
        AssessmentCadence? assessmentCadence,
        String? id,
        String? levelClassification,
        String? name,
        int? ranking,
    }) => 
        Team(
            ageGroup: ageGroup ?? this.ageGroup,
            assessmentCadence: assessmentCadence ?? this.assessmentCadence,
            id: id ?? this.id,
            levelClassification: levelClassification ?? this.levelClassification,
            name: name ?? this.name,
            ranking: ranking ?? this.ranking,
        );

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        ageGroup: json["age_group"],
        assessmentCadence: assessmentCadenceValues.map[json["assessment_cadence"]]!,
        id: json["id"],
        levelClassification: json["level_classification"],
        name: json["name"],
        ranking: json["ranking"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroup,
        "assessment_cadence": assessmentCadenceValues.reverse[assessmentCadence],
        "id": id,
        "level_classification": levelClassification,
        "name": name,
        "ranking": ranking,
    };
}

enum AssessmentCadence {
    ANNUAL,
    BI_MONTHLY,
    BI_WEEKLY,
    MONTHLY,
    QUARTERLY,
    SEMI_ANNUAL,
    WEEKLY
}

final assessmentCadenceValues = EnumValues({
    "annual": AssessmentCadence.ANNUAL,
    "bi_monthly": AssessmentCadence.BI_MONTHLY,
    "bi_weekly": AssessmentCadence.BI_WEEKLY,
    "monthly": AssessmentCadence.MONTHLY,
    "quarterly": AssessmentCadence.QUARTERLY,
    "semi_annual": AssessmentCadence.SEMI_ANNUAL,
    "weekly": AssessmentCadence.WEEKLY
});

class GetProfileRequest {
    final String? athleteId;

    GetProfileRequest({
        this.athleteId,
    });

    GetProfileRequest copyWith({
        String? athleteId,
    }) => 
        GetProfileRequest(
            athleteId: athleteId ?? this.athleteId,
        );

    factory GetProfileRequest.fromJson(Map<String, dynamic> json) => GetProfileRequest(
        athleteId: json["athlete_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
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

