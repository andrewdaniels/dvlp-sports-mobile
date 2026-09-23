// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final ageGroup = ageGroupFromJson(jsonString);
//     final createOrganizationData = createOrganizationDataFromJson(jsonString);
//     final createOrganizationRequest = createOrganizationRequestFromJson(jsonString);
//     final createOrganizationTeam = createOrganizationTeamFromJson(jsonString);

import 'dart:convert';

AgeGroup ageGroupFromJson(String str) => ageGroupValues.map[json.decode(str)]!;

String ageGroupToJson(AgeGroup data) => json.encode(ageGroupValues.reverse[data]);

CreateOrganizationData createOrganizationDataFromJson(String str) => CreateOrganizationData.fromJson(json.decode(str));

String createOrganizationDataToJson(CreateOrganizationData data) => json.encode(data.toJson());

CreateOrganizationRequest createOrganizationRequestFromJson(String str) => CreateOrganizationRequest.fromJson(json.decode(str));

String createOrganizationRequestToJson(CreateOrganizationRequest data) => json.encode(data.toJson());

CreateOrganizationTeam createOrganizationTeamFromJson(String str) => CreateOrganizationTeam.fromJson(json.decode(str));

String createOrganizationTeamToJson(CreateOrganizationTeam data) => json.encode(data.toJson());

class CreateOrganizationData {
    final Profile profile;

    CreateOrganizationData({
        required this.profile,
    });

    CreateOrganizationData copyWith({
        Profile? profile,
    }) => 
        CreateOrganizationData(
            profile: profile ?? this.profile,
        );

    factory CreateOrganizationData.fromJson(Map<String, dynamic> json) => CreateOrganizationData(
        profile: Profile.fromJson(json["profile"]),
    );

    Map<String, dynamic> toJson() => {
        "profile": profile.toJson(),
    };
}

class Profile {
    final AthleteDetails? athleteDetails;
    final String? avatarUrl;
    final DateTime createdAt;
    final String? dateOfBirth;
    final String email;
    final String firstName;
    final String id;
    final String lastName;
    final List<ManagedOrganization> managedOrganizations;
    final String? phone;
    final ProfileStatus profileStatus;
    final RoleTier roleTier;
    final List<TeamMembership> teamMemberships;
    final DateTime updatedAt;

    Profile({
        required this.athleteDetails,
        required this.avatarUrl,
        required this.createdAt,
        required this.dateOfBirth,
        required this.email,
        required this.firstName,
        required this.id,
        required this.lastName,
        required this.managedOrganizations,
        required this.phone,
        required this.profileStatus,
        required this.roleTier,
        required this.teamMemberships,
        required this.updatedAt,
    });

    Profile copyWith({
        AthleteDetails? athleteDetails,
        String? avatarUrl,
        DateTime? createdAt,
        String? dateOfBirth,
        String? email,
        String? firstName,
        String? id,
        String? lastName,
        List<ManagedOrganization>? managedOrganizations,
        String? phone,
        ProfileStatus? profileStatus,
        RoleTier? roleTier,
        List<TeamMembership>? teamMemberships,
        DateTime? updatedAt,
    }) => 
        Profile(
            athleteDetails: athleteDetails ?? this.athleteDetails,
            avatarUrl: avatarUrl ?? this.avatarUrl,
            createdAt: createdAt ?? this.createdAt,
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
            managedOrganizations: managedOrganizations ?? this.managedOrganizations,
            phone: phone ?? this.phone,
            profileStatus: profileStatus ?? this.profileStatus,
            roleTier: roleTier ?? this.roleTier,
            teamMemberships: teamMemberships ?? this.teamMemberships,
            updatedAt: updatedAt ?? this.updatedAt,
        );

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        athleteDetails: json["athlete_details"] == null ? null : AthleteDetails.fromJson(json["athlete_details"]),
        avatarUrl: json["avatar_url"],
        createdAt: DateTime.parse(json["created_at"]),
        dateOfBirth: json["date_of_birth"],
        email: json["email"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
        managedOrganizations: List<ManagedOrganization>.from(json["managed_organizations"].map((x) => ManagedOrganization.fromJson(x))),
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
        "managed_organizations": List<dynamic>.from(managedOrganizations.map((x) => x.toJson())),
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

class ManagedOrganization {
    final String id;
    final String name;
    final Status status;

    ManagedOrganization({
        required this.id,
        required this.name,
        required this.status,
    });

    ManagedOrganization copyWith({
        String? id,
        String? name,
        Status? status,
    }) => 
        ManagedOrganization(
            id: id ?? this.id,
            name: name ?? this.name,
            status: status ?? this.status,
        );

    factory ManagedOrganization.fromJson(Map<String, dynamic> json) => ManagedOrganization(
        id: json["id"],
        name: json["name"],
        status: statusValues.map[json["status"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": statusValues.reverse[status],
    };
}

enum Status {
    ACTIVE,
    DENIED,
    PENDING
}

final statusValues = EnumValues({
    "active": Status.ACTIVE,
    "denied": Status.DENIED,
    "pending": Status.PENDING
});

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
    final TeamMembershipTeam team;

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
        TeamMembershipTeam? team,
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
        team: TeamMembershipTeam.fromJson(json["team"]),
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

class TeamMembershipTeam {
    final String? ageGroup;
    final AssessmentCadence assessmentCadence;
    final String id;
    final String? levelClassification;
    final String name;
    final int? ranking;

    TeamMembershipTeam({
        required this.ageGroup,
        required this.assessmentCadence,
        required this.id,
        required this.levelClassification,
        required this.name,
        required this.ranking,
    });

    TeamMembershipTeam copyWith({
        String? ageGroup,
        AssessmentCadence? assessmentCadence,
        String? id,
        String? levelClassification,
        String? name,
        int? ranking,
    }) => 
        TeamMembershipTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            assessmentCadence: assessmentCadence ?? this.assessmentCadence,
            id: id ?? this.id,
            levelClassification: levelClassification ?? this.levelClassification,
            name: name ?? this.name,
            ranking: ranking ?? this.ranking,
        );

    factory TeamMembershipTeam.fromJson(Map<String, dynamic> json) => TeamMembershipTeam(
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

class CreateOrganizationRequest {
    final String email;
    final String firstName;
    final String lastName;
    final String orgName;
    final String password;
    final String? phone;
    final String sportId;
    final CreateOrganizationRequestTeam team;
    final String verificationToken;

    CreateOrganizationRequest({
        required this.email,
        required this.firstName,
        required this.lastName,
        required this.orgName,
        required this.password,
        this.phone,
        required this.sportId,
        required this.team,
        required this.verificationToken,
    });

    CreateOrganizationRequest copyWith({
        String? email,
        String? firstName,
        String? lastName,
        String? orgName,
        String? password,
        String? phone,
        String? sportId,
        CreateOrganizationRequestTeam? team,
        String? verificationToken,
    }) => 
        CreateOrganizationRequest(
            email: email ?? this.email,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            orgName: orgName ?? this.orgName,
            password: password ?? this.password,
            phone: phone ?? this.phone,
            sportId: sportId ?? this.sportId,
            team: team ?? this.team,
            verificationToken: verificationToken ?? this.verificationToken,
        );

    factory CreateOrganizationRequest.fromJson(Map<String, dynamic> json) => CreateOrganizationRequest(
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        orgName: json["org_name"],
        password: json["password"],
        phone: json["phone"],
        sportId: json["sport_id"],
        team: CreateOrganizationRequestTeam.fromJson(json["team"]),
        verificationToken: json["verification_token"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "org_name": orgName,
        "password": password,
        "phone": phone,
        "sport_id": sportId,
        "team": team.toJson(),
        "verification_token": verificationToken,
    };
}

class CreateOrganizationRequestTeam {
    final AgeGroup ageGroup;
    final String levelClassificationId;
    final String name;

    CreateOrganizationRequestTeam({
        required this.ageGroup,
        required this.levelClassificationId,
        required this.name,
    });

    CreateOrganizationRequestTeam copyWith({
        AgeGroup? ageGroup,
        String? levelClassificationId,
        String? name,
    }) => 
        CreateOrganizationRequestTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            levelClassificationId: levelClassificationId ?? this.levelClassificationId,
            name: name ?? this.name,
        );

    factory CreateOrganizationRequestTeam.fromJson(Map<String, dynamic> json) => CreateOrganizationRequestTeam(
        ageGroup: ageGroupValues.map[json["age_group"]]!,
        levelClassificationId: json["level_classification_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroupValues.reverse[ageGroup],
        "level_classification_id": levelClassificationId,
        "name": name,
    };
}

enum AgeGroup {
    U10,
    U11,
    U12,
    U13,
    U14,
    U15,
    U16,
    U17,
    U18,
    U7,
    U8,
    U9
}

final ageGroupValues = EnumValues({
    "U10": AgeGroup.U10,
    "U11": AgeGroup.U11,
    "U12": AgeGroup.U12,
    "U13": AgeGroup.U13,
    "U14": AgeGroup.U14,
    "U15": AgeGroup.U15,
    "U16": AgeGroup.U16,
    "U17": AgeGroup.U17,
    "U18": AgeGroup.U18,
    "U7": AgeGroup.U7,
    "U8": AgeGroup.U8,
    "U9": AgeGroup.U9
});

class CreateOrganizationTeam {
    final AgeGroup ageGroup;
    final String levelClassificationId;
    final String name;

    CreateOrganizationTeam({
        required this.ageGroup,
        required this.levelClassificationId,
        required this.name,
    });

    CreateOrganizationTeam copyWith({
        AgeGroup? ageGroup,
        String? levelClassificationId,
        String? name,
    }) => 
        CreateOrganizationTeam(
            ageGroup: ageGroup ?? this.ageGroup,
            levelClassificationId: levelClassificationId ?? this.levelClassificationId,
            name: name ?? this.name,
        );

    factory CreateOrganizationTeam.fromJson(Map<String, dynamic> json) => CreateOrganizationTeam(
        ageGroup: ageGroupValues.map[json["age_group"]]!,
        levelClassificationId: json["level_classification_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "age_group": ageGroupValues.reverse[ageGroup],
        "level_classification_id": levelClassificationId,
        "name": name,
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

