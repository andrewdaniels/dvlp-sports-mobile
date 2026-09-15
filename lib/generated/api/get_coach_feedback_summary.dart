// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getCoachFeedbackSummaryData = getCoachFeedbackSummaryDataFromJson(jsonString);

import 'dart:convert';

GetCoachFeedbackSummaryData getCoachFeedbackSummaryDataFromJson(String str) => GetCoachFeedbackSummaryData.fromJson(json.decode(str));

String getCoachFeedbackSummaryDataToJson(GetCoachFeedbackSummaryData data) => json.encode(data.toJson());

class GetCoachFeedbackSummaryData {
    final FormalCadence formalCadence;
    final List<QuickFeedbackRequest> quickFeedbackRequests;
    final List<RecentCompleted> recentCompleted;

    GetCoachFeedbackSummaryData({
        required this.formalCadence,
        required this.quickFeedbackRequests,
        required this.recentCompleted,
    });

    GetCoachFeedbackSummaryData copyWith({
        FormalCadence? formalCadence,
        List<QuickFeedbackRequest>? quickFeedbackRequests,
        List<RecentCompleted>? recentCompleted,
    }) => 
        GetCoachFeedbackSummaryData(
            formalCadence: formalCadence ?? this.formalCadence,
            quickFeedbackRequests: quickFeedbackRequests ?? this.quickFeedbackRequests,
            recentCompleted: recentCompleted ?? this.recentCompleted,
        );

    factory GetCoachFeedbackSummaryData.fromJson(Map<String, dynamic> json) => GetCoachFeedbackSummaryData(
        formalCadence: FormalCadence.fromJson(json["formal_cadence"]),
        quickFeedbackRequests: List<QuickFeedbackRequest>.from(json["quick_feedback_requests"].map((x) => QuickFeedbackRequest.fromJson(x))),
        recentCompleted: List<RecentCompleted>.from(json["recent_completed"].map((x) => RecentCompleted.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "formal_cadence": formalCadence.toJson(),
        "quick_feedback_requests": List<dynamic>.from(quickFeedbackRequests.map((x) => x.toJson())),
        "recent_completed": List<dynamic>.from(recentCompleted.map((x) => x.toJson())),
    };
}

class FormalCadence {
    final int completedCount;
    final List<PendingAthlete> pendingAthletes;
    final Period period;
    final int totalAthletes;

    FormalCadence({
        required this.completedCount,
        required this.pendingAthletes,
        required this.period,
        required this.totalAthletes,
    });

    FormalCadence copyWith({
        int? completedCount,
        List<PendingAthlete>? pendingAthletes,
        Period? period,
        int? totalAthletes,
    }) => 
        FormalCadence(
            completedCount: completedCount ?? this.completedCount,
            pendingAthletes: pendingAthletes ?? this.pendingAthletes,
            period: period ?? this.period,
            totalAthletes: totalAthletes ?? this.totalAthletes,
        );

    factory FormalCadence.fromJson(Map<String, dynamic> json) => FormalCadence(
        completedCount: json["completed_count"],
        pendingAthletes: List<PendingAthlete>.from(json["pending_athletes"].map((x) => PendingAthlete.fromJson(x))),
        period: Period.fromJson(json["period"]),
        totalAthletes: json["total_athletes"],
    );

    Map<String, dynamic> toJson() => {
        "completed_count": completedCount,
        "pending_athletes": List<dynamic>.from(pendingAthletes.map((x) => x.toJson())),
        "period": period.toJson(),
        "total_athletes": totalAthletes,
    };
}

class PendingAthlete {
    final PendingAthleteAthlete athlete;

    PendingAthlete({
        required this.athlete,
    });

    PendingAthlete copyWith({
        PendingAthleteAthlete? athlete,
    }) => 
        PendingAthlete(
            athlete: athlete ?? this.athlete,
        );

    factory PendingAthlete.fromJson(Map<String, dynamic> json) => PendingAthlete(
        athlete: PendingAthleteAthlete.fromJson(json["athlete"]),
    );

    Map<String, dynamic> toJson() => {
        "athlete": athlete.toJson(),
    };
}

class PendingAthleteAthlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;

    PendingAthleteAthlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    PendingAthleteAthlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        PendingAthleteAthlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory PendingAthleteAthlete.fromJson(Map<String, dynamic> json) => PendingAthleteAthlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
    };
}

class Period {
    final Cadence cadence;
    final String endIso;
    final String label;
    final String startIso;

    Period({
        required this.cadence,
        required this.endIso,
        required this.label,
        required this.startIso,
    });

    Period copyWith({
        Cadence? cadence,
        String? endIso,
        String? label,
        String? startIso,
    }) => 
        Period(
            cadence: cadence ?? this.cadence,
            endIso: endIso ?? this.endIso,
            label: label ?? this.label,
            startIso: startIso ?? this.startIso,
        );

    factory Period.fromJson(Map<String, dynamic> json) => Period(
        cadence: cadenceValues.map[json["cadence"]]!,
        endIso: json["end_iso"],
        label: json["label"],
        startIso: json["start_iso"],
    );

    Map<String, dynamic> toJson() => {
        "cadence": cadenceValues.reverse[cadence],
        "end_iso": endIso,
        "label": label,
        "start_iso": startIso,
    };
}

enum Cadence {
    ANNUAL,
    BI_MONTHLY,
    BI_WEEKLY,
    MONTHLY,
    QUARTERLY,
    SEMI_ANNUAL,
    WEEKLY
}

final cadenceValues = EnumValues({
    "annual": Cadence.ANNUAL,
    "bi_monthly": Cadence.BI_MONTHLY,
    "bi_weekly": Cadence.BI_WEEKLY,
    "monthly": Cadence.MONTHLY,
    "quarterly": Cadence.QUARTERLY,
    "semi_annual": Cadence.SEMI_ANNUAL,
    "weekly": Cadence.WEEKLY
});

class QuickFeedbackRequest {
    final QuickFeedbackRequestAthlete athlete;
    final String requestId;
    final String requestedAt;

    QuickFeedbackRequest({
        required this.athlete,
        required this.requestId,
        required this.requestedAt,
    });

    QuickFeedbackRequest copyWith({
        QuickFeedbackRequestAthlete? athlete,
        String? requestId,
        String? requestedAt,
    }) => 
        QuickFeedbackRequest(
            athlete: athlete ?? this.athlete,
            requestId: requestId ?? this.requestId,
            requestedAt: requestedAt ?? this.requestedAt,
        );

    factory QuickFeedbackRequest.fromJson(Map<String, dynamic> json) => QuickFeedbackRequest(
        athlete: QuickFeedbackRequestAthlete.fromJson(json["athlete"]),
        requestId: json["request_id"],
        requestedAt: json["requested_at"],
    );

    Map<String, dynamic> toJson() => {
        "athlete": athlete.toJson(),
        "request_id": requestId,
        "requested_at": requestedAt,
    };
}

class QuickFeedbackRequestAthlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;

    QuickFeedbackRequestAthlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    QuickFeedbackRequestAthlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        QuickFeedbackRequestAthlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory QuickFeedbackRequestAthlete.fromJson(Map<String, dynamic> json) => QuickFeedbackRequestAthlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
    };
}

class RecentCompleted {
    final String assessmentId;
    final AssessmentType assessmentType;
    final RecentCompletedAthlete athlete;
    final String submittedAt;

    RecentCompleted({
        required this.assessmentId,
        required this.assessmentType,
        required this.athlete,
        required this.submittedAt,
    });

    RecentCompleted copyWith({
        String? assessmentId,
        AssessmentType? assessmentType,
        RecentCompletedAthlete? athlete,
        String? submittedAt,
    }) => 
        RecentCompleted(
            assessmentId: assessmentId ?? this.assessmentId,
            assessmentType: assessmentType ?? this.assessmentType,
            athlete: athlete ?? this.athlete,
            submittedAt: submittedAt ?? this.submittedAt,
        );

    factory RecentCompleted.fromJson(Map<String, dynamic> json) => RecentCompleted(
        assessmentId: json["assessment_id"],
        assessmentType: assessmentTypeValues.map[json["assessment_type"]]!,
        athlete: RecentCompletedAthlete.fromJson(json["athlete"]),
        submittedAt: json["submitted_at"],
    );

    Map<String, dynamic> toJson() => {
        "assessment_id": assessmentId,
        "assessment_type": assessmentTypeValues.reverse[assessmentType],
        "athlete": athlete.toJson(),
        "submitted_at": submittedAt,
    };
}

enum AssessmentType {
    FORMAL,
    QUICK
}

final assessmentTypeValues = EnumValues({
    "formal": AssessmentType.FORMAL,
    "quick": AssessmentType.QUICK
});

class RecentCompletedAthlete {
    final String? avatarUrl;
    final String firstName;
    final String id;
    final String lastName;

    RecentCompletedAthlete({
        required this.avatarUrl,
        required this.firstName,
        required this.id,
        required this.lastName,
    });

    RecentCompletedAthlete copyWith({
        String? avatarUrl,
        String? firstName,
        String? id,
        String? lastName,
    }) => 
        RecentCompletedAthlete(
            avatarUrl: avatarUrl ?? this.avatarUrl,
            firstName: firstName ?? this.firstName,
            id: id ?? this.id,
            lastName: lastName ?? this.lastName,
        );

    factory RecentCompletedAthlete.fromJson(Map<String, dynamic> json) => RecentCompletedAthlete(
        avatarUrl: json["avatar_url"],
        firstName: json["first_name"],
        id: json["id"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "first_name": firstName,
        "id": id,
        "last_name": lastName,
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

