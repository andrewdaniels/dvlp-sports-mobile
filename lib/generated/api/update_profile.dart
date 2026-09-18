// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final updateProfileData = updateProfileDataFromJson(jsonString);
//     final updateProfileRequest = updateProfileRequestFromJson(jsonString);

import 'dart:convert';

UpdateProfileData updateProfileDataFromJson(String str) => UpdateProfileData.fromJson(json.decode(str));

String updateProfileDataToJson(UpdateProfileData data) => json.encode(data.toJson());

UpdateProfileRequest updateProfileRequestFromJson(String str) => UpdateProfileRequest.fromJson(json.decode(str));

String updateProfileRequestToJson(UpdateProfileRequest data) => json.encode(data.toJson());

class UpdateProfileData {
    final UpdateProfileDataAthleteDetails? athleteDetails;
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

    UpdateProfileData({
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

    UpdateProfileData copyWith({
        UpdateProfileDataAthleteDetails? athleteDetails,
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
        UpdateProfileData(
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

    factory UpdateProfileData.fromJson(Map<String, dynamic> json) => UpdateProfileData(
        athleteDetails: json["athlete_details"] == null ? null : UpdateProfileDataAthleteDetails.fromJson(json["athlete_details"]),
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

class UpdateProfileDataAthleteDetails {
    final DominantSide? dominantSide;
    final double? heightCm;
    final Position? position;
    final double? weightKg;

    UpdateProfileDataAthleteDetails({
        required this.dominantSide,
        required this.heightCm,
        required this.position,
        required this.weightKg,
    });

    UpdateProfileDataAthleteDetails copyWith({
        DominantSide? dominantSide,
        double? heightCm,
        Position? position,
        double? weightKg,
    }) => 
        UpdateProfileDataAthleteDetails(
            dominantSide: dominantSide ?? this.dominantSide,
            heightCm: heightCm ?? this.heightCm,
            position: position ?? this.position,
            weightKg: weightKg ?? this.weightKg,
        );

    factory UpdateProfileDataAthleteDetails.fromJson(Map<String, dynamic> json) => UpdateProfileDataAthleteDetails(
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

class UpdateProfileRequest {
    final UpdateProfileRequestAthleteDetails? athleteDetails;
    final String? avatarBase64;
    final String? avatarMime;
    final String? dateOfBirth;
    final String? firstName;
    final String? lastName;
    final String? phone;

    UpdateProfileRequest({
        this.athleteDetails,
        this.avatarBase64,
        this.avatarMime,
        this.dateOfBirth,
        this.firstName,
        this.lastName,
        this.phone,
    });

    UpdateProfileRequest copyWith({
        UpdateProfileRequestAthleteDetails? athleteDetails,
        String? avatarBase64,
        String? avatarMime,
        String? dateOfBirth,
        String? firstName,
        String? lastName,
        String? phone,
    }) => 
        UpdateProfileRequest(
            athleteDetails: athleteDetails ?? this.athleteDetails,
            avatarBase64: avatarBase64 ?? this.avatarBase64,
            avatarMime: avatarMime ?? this.avatarMime,
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            phone: phone ?? this.phone,
        );

    factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => UpdateProfileRequest(
        athleteDetails: json["athlete_details"] == null ? null : UpdateProfileRequestAthleteDetails.fromJson(json["athlete_details"]),
        avatarBase64: json["avatar_base64"],
        avatarMime: json["avatar_mime"],
        dateOfBirth: json["date_of_birth"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_details": athleteDetails?.toJson(),
        "avatar_base64": avatarBase64,
        "avatar_mime": avatarMime,
        "date_of_birth": dateOfBirth,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
    };
}

class UpdateProfileRequestAthleteDetails {
    final DominantSide? dominantSide;
    final double? heightCm;
    final String? positionId;
    final double? weightKg;

    UpdateProfileRequestAthleteDetails({
        this.dominantSide,
        this.heightCm,
        this.positionId,
        this.weightKg,
    });

    UpdateProfileRequestAthleteDetails copyWith({
        DominantSide? dominantSide,
        double? heightCm,
        String? positionId,
        double? weightKg,
    }) => 
        UpdateProfileRequestAthleteDetails(
            dominantSide: dominantSide ?? this.dominantSide,
            heightCm: heightCm ?? this.heightCm,
            positionId: positionId ?? this.positionId,
            weightKg: weightKg ?? this.weightKg,
        );

    factory UpdateProfileRequestAthleteDetails.fromJson(Map<String, dynamic> json) => UpdateProfileRequestAthleteDetails(
        dominantSide: dominantSideValues.map[json["dominant_side"]],
        heightCm: json["height_cm"]?.toDouble(),
        positionId: json["position_id"],
        weightKg: json["weight_kg"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "dominant_side": dominantSideValues.reverse[dominantSide],
        "height_cm": heightCm,
        "position_id": positionId,
        "weight_kg": weightKg,
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

