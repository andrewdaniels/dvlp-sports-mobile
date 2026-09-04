// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getJournalEntriesData = getJournalEntriesDataFromJson(jsonString);
//     final getJournalEntriesRequest = getJournalEntriesRequestFromJson(jsonString);

import 'dart:convert';

GetJournalEntriesData getJournalEntriesDataFromJson(String str) => GetJournalEntriesData.fromJson(json.decode(str));

String getJournalEntriesDataToJson(GetJournalEntriesData data) => json.encode(data.toJson());

GetJournalEntriesRequest getJournalEntriesRequestFromJson(String str) => GetJournalEntriesRequest.fromJson(json.decode(str));

String getJournalEntriesRequestToJson(GetJournalEntriesRequest data) => json.encode(data.toJson());

class GetJournalEntriesData {
    final List<Entry> entries;

    GetJournalEntriesData({
        required this.entries,
    });

    GetJournalEntriesData copyWith({
        List<Entry>? entries,
    }) => 
        GetJournalEntriesData(
            entries: entries ?? this.entries,
        );

    factory GetJournalEntriesData.fromJson(Map<String, dynamic> json) => GetJournalEntriesData(
        entries: List<Entry>.from(json["entries"].map((x) => Entry.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "entries": List<dynamic>.from(entries.map((x) => x.toJson())),
    };
}

class Entry {
    final String? additionalNotes;
    final String createdAt;
    final String id;
    final String? nextFocus;
    final String? performanceReflection;
    final String? skillsWorkedOn;

    Entry({
        required this.additionalNotes,
        required this.createdAt,
        required this.id,
        required this.nextFocus,
        required this.performanceReflection,
        required this.skillsWorkedOn,
    });

    Entry copyWith({
        String? additionalNotes,
        String? createdAt,
        String? id,
        String? nextFocus,
        String? performanceReflection,
        String? skillsWorkedOn,
    }) => 
        Entry(
            additionalNotes: additionalNotes ?? this.additionalNotes,
            createdAt: createdAt ?? this.createdAt,
            id: id ?? this.id,
            nextFocus: nextFocus ?? this.nextFocus,
            performanceReflection: performanceReflection ?? this.performanceReflection,
            skillsWorkedOn: skillsWorkedOn ?? this.skillsWorkedOn,
        );

    factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        additionalNotes: json["additional_notes"],
        createdAt: json["created_at"],
        id: json["id"],
        nextFocus: json["next_focus"],
        performanceReflection: json["performance_reflection"],
        skillsWorkedOn: json["skills_worked_on"],
    );

    Map<String, dynamic> toJson() => {
        "additional_notes": additionalNotes,
        "created_at": createdAt,
        "id": id,
        "next_focus": nextFocus,
        "performance_reflection": performanceReflection,
        "skills_worked_on": skillsWorkedOn,
    };
}

class GetJournalEntriesRequest {
    final String? athleteId;

    GetJournalEntriesRequest({
        this.athleteId,
    });

    GetJournalEntriesRequest copyWith({
        String? athleteId,
    }) => 
        GetJournalEntriesRequest(
            athleteId: athleteId ?? this.athleteId,
        );

    factory GetJournalEntriesRequest.fromJson(Map<String, dynamic> json) => GetJournalEntriesRequest(
        athleteId: json["athlete_id"],
    );

    Map<String, dynamic> toJson() => {
        "athlete_id": athleteId,
    };
}

