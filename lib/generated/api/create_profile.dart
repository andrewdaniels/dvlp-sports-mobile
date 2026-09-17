// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createAthleteRequest = createAthleteRequestFromJson(jsonString);
//     final createCoachRequest = createCoachRequestFromJson(jsonString);
//     final createGuardianRequest = createGuardianRequestFromJson(jsonString);
//     final createProfileData = createProfileDataFromJson(jsonString);
//     final createProfileRequest = createProfileRequestFromJson(jsonString);

import 'dart:convert';

CreateAthleteRequest createAthleteRequestFromJson(String str) => CreateAthleteRequest.fromJson(json.decode(str));

String createAthleteRequestToJson(CreateAthleteRequest data) => json.encode(data.toJson());

CreateCoachRequest createCoachRequestFromJson(String str) => CreateCoachRequest.fromJson(json.decode(str));

String createCoachRequestToJson(CreateCoachRequest data) => json.encode(data.toJson());

CreateGuardianRequest createGuardianRequestFromJson(String str) => CreateGuardianRequest.fromJson(json.decode(str));

String createGuardianRequestToJson(CreateGuardianRequest data) => json.encode(data.toJson());

CreateProfileData createProfileDataFromJson(String str) => CreateProfileData.fromJson(json.decode(str));

String createProfileDataToJson(CreateProfileData data) => json.encode(data.toJson());

CreateProfileRequest createProfileRequestFromJson(String str) => CreateProfileRequest.fromJson(json.decode(str));

String createProfileRequestToJson(CreateProfileRequest data) => json.encode(data.toJson());

class CreateAthleteRequest {
    final CreateAthleteRequestAthleteDetails athleteDetails;
    final String dateOfBirth;
    final String email;
    final String firstName;
    final String? guardianEmail;
    final String? inviteId;
    final String lastName;
    final String password;
    final CreateAthleteRequestRole role;

    CreateAthleteRequest({
        required this.athleteDetails,
        required this.dateOfBirth,
        required this.email,
        required this.firstName,
        this.guardianEmail,
        this.inviteId,
        required this.lastName,
        required this.password,
        required this.role,
    });

    CreateAthleteRequest copyWith({
        CreateAthleteRequestAthleteDetails? athleteDetails,
        String? dateOfBirth,
        String? email,
        String? firstName,
        String? guardianEmail,
        String? inviteId,
        String? lastName,
        String? password,
        CreateAthleteRequestRole? role,
    }) => 
        CreateAthleteRequest(
            athleteDetails: athleteDetails ?? this.athleteDetails,
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            guardianEmail: guardianEmail ?? this.guardianEmail,
            inviteId: inviteId ?? this.inviteId,
            lastName: lastName ?? this.lastName,
            password: password ?? this.password,
            role: role ?? this.role,
        );

    factory CreateAthleteRequest.fromJson(Map<String, dynamic> json) => CreateAthleteRequest(
        athleteDetails: CreateAthleteRequestAthleteDetails.fromJson(json["athlete_details"]),
        dateOfBirth: json["date_of_birth"],
        email: json["email"],
        firstName: json["first_name"],
        guardianEmail: json["guardian_email"],
        inviteId: json["invite_id"],
        lastName: json["last_name"],
        password: json["password"],
        role: createAthleteRequestRoleValues.map[json["role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "athlete_details": athleteDetails.toJson(),
        "date_of_birth": dateOfBirth,
        "email": email,
        "first_name": firstName,
        "guardian_email": guardianEmail,
        "invite_id": inviteId,
        "last_name": lastName,
        "password": password,
        "role": createAthleteRequestRoleValues.reverse[role],
    };
}

class CreateAthleteRequestAthleteDetails {
    final DominantSide? dominantSide;
    final double? heightCm;
    final String? positionId;
    final double? weightKg;

    CreateAthleteRequestAthleteDetails({
        required this.dominantSide,
        required this.heightCm,
        required this.positionId,
        required this.weightKg,
    });

    CreateAthleteRequestAthleteDetails copyWith({
        DominantSide? dominantSide,
        double? heightCm,
        String? positionId,
        double? weightKg,
    }) => 
        CreateAthleteRequestAthleteDetails(
            dominantSide: dominantSide ?? this.dominantSide,
            heightCm: heightCm ?? this.heightCm,
            positionId: positionId ?? this.positionId,
            weightKg: weightKg ?? this.weightKg,
        );

    factory CreateAthleteRequestAthleteDetails.fromJson(Map<String, dynamic> json) => CreateAthleteRequestAthleteDetails(
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

enum CreateAthleteRequestRole {
    ATHLETE
}

final createAthleteRequestRoleValues = EnumValues({
    "athlete": CreateAthleteRequestRole.ATHLETE
});

class CreateCoachRequest {
    final String? dateOfBirth;
    final String email;
    final String firstName;
    final String? inviteId;
    final String lastName;
    final String password;
    final CreateCoachRequestRole role;

    CreateCoachRequest({
        this.dateOfBirth,
        required this.email,
        required this.firstName,
        this.inviteId,
        required this.lastName,
        required this.password,
        required this.role,
    });

    CreateCoachRequest copyWith({
        String? dateOfBirth,
        String? email,
        String? firstName,
        String? inviteId,
        String? lastName,
        String? password,
        CreateCoachRequestRole? role,
    }) => 
        CreateCoachRequest(
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            inviteId: inviteId ?? this.inviteId,
            lastName: lastName ?? this.lastName,
            password: password ?? this.password,
            role: role ?? this.role,
        );

    factory CreateCoachRequest.fromJson(Map<String, dynamic> json) => CreateCoachRequest(
        dateOfBirth: json["date_of_birth"],
        email: json["email"],
        firstName: json["first_name"],
        inviteId: json["invite_id"],
        lastName: json["last_name"],
        password: json["password"],
        role: createCoachRequestRoleValues.map[json["role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "date_of_birth": dateOfBirth,
        "email": email,
        "first_name": firstName,
        "invite_id": inviteId,
        "last_name": lastName,
        "password": password,
        "role": createCoachRequestRoleValues.reverse[role],
    };
}

enum CreateCoachRequestRole {
    COACH
}

final createCoachRequestRoleValues = EnumValues({
    "coach": CreateCoachRequestRole.COACH
});

class CreateGuardianRequest {
    final String dateOfBirth;
    final String email;
    final String firstName;
    final String inviteId;
    final String? lastName;
    final String password;
    final String? phone;
    final CreateGuardianRequestRole role;

    CreateGuardianRequest({
        required this.dateOfBirth,
        required this.email,
        required this.firstName,
        required this.inviteId,
        this.lastName,
        required this.password,
        this.phone,
        required this.role,
    });

    CreateGuardianRequest copyWith({
        String? dateOfBirth,
        String? email,
        String? firstName,
        String? inviteId,
        String? lastName,
        String? password,
        String? phone,
        CreateGuardianRequestRole? role,
    }) => 
        CreateGuardianRequest(
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            inviteId: inviteId ?? this.inviteId,
            lastName: lastName ?? this.lastName,
            password: password ?? this.password,
            phone: phone ?? this.phone,
            role: role ?? this.role,
        );

    factory CreateGuardianRequest.fromJson(Map<String, dynamic> json) => CreateGuardianRequest(
        dateOfBirth: json["date_of_birth"],
        email: json["email"],
        firstName: json["first_name"],
        inviteId: json["invite_id"],
        lastName: json["last_name"],
        password: json["password"],
        phone: json["phone"],
        role: createGuardianRequestRoleValues.map[json["role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "date_of_birth": dateOfBirth,
        "email": email,
        "first_name": firstName,
        "invite_id": inviteId,
        "last_name": lastName,
        "password": password,
        "phone": phone,
        "role": createGuardianRequestRoleValues.reverse[role],
    };
}

enum CreateGuardianRequestRole {
    GUARDIAN
}

final createGuardianRequestRoleValues = EnumValues({
    "guardian": CreateGuardianRequestRole.GUARDIAN
});

class CreateProfileData {
    final CreateProfileDataAthleteDetails? athleteDetails;
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

    CreateProfileData({
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

    CreateProfileData copyWith({
        CreateProfileDataAthleteDetails? athleteDetails,
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
        CreateProfileData(
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

    factory CreateProfileData.fromJson(Map<String, dynamic> json) => CreateProfileData(
        athleteDetails: json["athlete_details"] == null ? null : CreateProfileDataAthleteDetails.fromJson(json["athlete_details"]),
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

class CreateProfileDataAthleteDetails {
    final DominantSide? dominantSide;
    final double? heightCm;
    final Position? position;
    final double? weightKg;

    CreateProfileDataAthleteDetails({
        required this.dominantSide,
        required this.heightCm,
        required this.position,
        required this.weightKg,
    });

    CreateProfileDataAthleteDetails copyWith({
        DominantSide? dominantSide,
        double? heightCm,
        Position? position,
        double? weightKg,
    }) => 
        CreateProfileDataAthleteDetails(
            dominantSide: dominantSide ?? this.dominantSide,
            heightCm: heightCm ?? this.heightCm,
            position: position ?? this.position,
            weightKg: weightKg ?? this.weightKg,
        );

    factory CreateProfileDataAthleteDetails.fromJson(Map<String, dynamic> json) => CreateProfileDataAthleteDetails(
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

class CreateProfileRequest {
    final CreateProfileRequestAthleteDetails? athleteDetails;
    final String? dateOfBirth;
    final String email;
    final String firstName;
    final String? guardianEmail;
    final String? inviteId;
    final String? lastName;
    final String password;
    final CreateProfileRequestRole role;
    final String? phone;

    CreateProfileRequest({
        this.athleteDetails,
        this.dateOfBirth,
        required this.email,
        required this.firstName,
        this.guardianEmail,
        this.inviteId,
        this.lastName,
        required this.password,
        required this.role,
        this.phone,
    });

    CreateProfileRequest copyWith({
        CreateProfileRequestAthleteDetails? athleteDetails,
        String? dateOfBirth,
        String? email,
        String? firstName,
        String? guardianEmail,
        String? inviteId,
        String? lastName,
        String? password,
        CreateProfileRequestRole? role,
        String? phone,
    }) => 
        CreateProfileRequest(
            athleteDetails: athleteDetails ?? this.athleteDetails,
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            guardianEmail: guardianEmail ?? this.guardianEmail,
            inviteId: inviteId ?? this.inviteId,
            lastName: lastName ?? this.lastName,
            password: password ?? this.password,
            role: role ?? this.role,
            phone: phone ?? this.phone,
        );

    factory CreateProfileRequest.fromJson(Map<String, dynamic> json) => CreateProfileRequest(
        athleteDetails: json["athlete_details"] == null ? null : CreateProfileRequestAthleteDetails.fromJson(json["athlete_details"]),
        dateOfBirth: json["date_of_birth"],
        email: json["email"],
        firstName: json["first_name"],
        guardianEmail: json["guardian_email"],
        inviteId: json["invite_id"],
        lastName: json["last_name"],
        password: json["password"],
        role: createProfileRequestRoleValues.map[json["role"]]!,
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_details": athleteDetails?.toJson(),
        "date_of_birth": dateOfBirth,
        "email": email,
        "first_name": firstName,
        "guardian_email": guardianEmail,
        "invite_id": inviteId,
        "last_name": lastName,
        "password": password,
        "role": createProfileRequestRoleValues.reverse[role],
        "phone": phone,
    };
}

class CreateProfileRequestAthleteDetails {
    final DominantSide? dominantSide;
    final double? heightCm;
    final String? positionId;
    final double? weightKg;

    CreateProfileRequestAthleteDetails({
        required this.dominantSide,
        required this.heightCm,
        required this.positionId,
        required this.weightKg,
    });

    CreateProfileRequestAthleteDetails copyWith({
        DominantSide? dominantSide,
        double? heightCm,
        String? positionId,
        double? weightKg,
    }) => 
        CreateProfileRequestAthleteDetails(
            dominantSide: dominantSide ?? this.dominantSide,
            heightCm: heightCm ?? this.heightCm,
            positionId: positionId ?? this.positionId,
            weightKg: weightKg ?? this.weightKg,
        );

    factory CreateProfileRequestAthleteDetails.fromJson(Map<String, dynamic> json) => CreateProfileRequestAthleteDetails(
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

enum CreateProfileRequestRole {
    ATHLETE,
    COACH,
    GUARDIAN
}

final createProfileRequestRoleValues = EnumValues({
    "athlete": CreateProfileRequestRole.ATHLETE,
    "coach": CreateProfileRequestRole.COACH,
    "guardian": CreateProfileRequestRole.GUARDIAN
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}

