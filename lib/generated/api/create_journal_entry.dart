// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final createJournalEntryData = createJournalEntryDataFromJson(jsonString);
//     final createJournalEntryRequest = createJournalEntryRequestFromJson(jsonString);

import 'dart:convert';

CreateJournalEntryData createJournalEntryDataFromJson(String str) => CreateJournalEntryData.fromJson(json.decode(str));

String createJournalEntryDataToJson(CreateJournalEntryData data) => json.encode(data.toJson());

CreateJournalEntryRequest createJournalEntryRequestFromJson(String str) => CreateJournalEntryRequest.fromJson(json.decode(str));

String createJournalEntryRequestToJson(CreateJournalEntryRequest data) => json.encode(data.toJson());

class CreateJournalEntryData {
    final Entry entry;

    CreateJournalEntryData({
        required this.entry,
    });

    CreateJournalEntryData copyWith({
        Entry? entry,
    }) => 
        CreateJournalEntryData(
            entry: entry ?? this.entry,
        );

    factory CreateJournalEntryData.fromJson(Map<String, dynamic> json) => CreateJournalEntryData(
        entry: Entry.fromJson(json["entry"]),
    );

    Map<String, dynamic> toJson() => {
        "entry": entry.toJson(),
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

class CreateJournalEntryRequest {
    final String? additionalNotes;
    final String? nextFocus;
    final String? performanceReflection;
    final String? skillsWorkedOn;

    CreateJournalEntryRequest({
        this.additionalNotes,
        this.nextFocus,
        this.performanceReflection,
        this.skillsWorkedOn,
    });

    CreateJournalEntryRequest copyWith({
        String? additionalNotes,
        String? nextFocus,
        String? performanceReflection,
        String? skillsWorkedOn,
    }) => 
        CreateJournalEntryRequest(
            additionalNotes: additionalNotes ?? this.additionalNotes,
            nextFocus: nextFocus ?? this.nextFocus,
            performanceReflection: performanceReflection ?? this.performanceReflection,
            skillsWorkedOn: skillsWorkedOn ?? this.skillsWorkedOn,
        );

    factory CreateJournalEntryRequest.fromJson(Map<String, dynamic> json) => CreateJournalEntryRequest(
        additionalNotes: json["additional_notes"],
        nextFocus: json["next_focus"],
        performanceReflection: json["performance_reflection"],
        skillsWorkedOn: json["skills_worked_on"],
    );

    Map<String, dynamic> toJson() => {
        "additional_notes": additionalNotes,
        "next_focus": nextFocus,
        "performance_reflection": performanceReflection,
        "skills_worked_on": skillsWorkedOn,
    };
}

