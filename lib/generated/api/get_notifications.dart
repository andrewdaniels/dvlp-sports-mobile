// GENERATED FILE — do not edit by hand.
// Source: backend/supabase/functions/<function>/schema.ts
// Regenerate: cd backend && npm run gen:dart

// To parse this JSON data, do
//
//     final getNotificationsData = getNotificationsDataFromJson(jsonString);
//     final notification = notificationFromJson(jsonString);

import 'dart:convert';

GetNotificationsData getNotificationsDataFromJson(String str) => GetNotificationsData.fromJson(json.decode(str));

String getNotificationsDataToJson(GetNotificationsData data) => json.encode(data.toJson());

Notification notificationFromJson(String str) => Notification.fromJson(json.decode(str));

String notificationToJson(Notification data) => json.encode(data.toJson());

class GetNotificationsData {
    final List<NotificationElement> notifications;

    GetNotificationsData({
        required this.notifications,
    });

    GetNotificationsData copyWith({
        List<NotificationElement>? notifications,
    }) => 
        GetNotificationsData(
            notifications: notifications ?? this.notifications,
        );

    factory GetNotificationsData.fromJson(Map<String, dynamic> json) => GetNotificationsData(
        notifications: List<NotificationElement>.from(json["notifications"].map((x) => NotificationElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
    };
}

class NotificationElement {
    final String createdAt;
    final String id;
    final String? resourceId;
    final String? subtitle;
    final String title;
    final Type type;

    NotificationElement({
        required this.createdAt,
        required this.id,
        required this.resourceId,
        required this.subtitle,
        required this.title,
        required this.type,
    });

    NotificationElement copyWith({
        String? createdAt,
        String? id,
        String? resourceId,
        String? subtitle,
        String? title,
        Type? type,
    }) => 
        NotificationElement(
            createdAt: createdAt ?? this.createdAt,
            id: id ?? this.id,
            resourceId: resourceId ?? this.resourceId,
            subtitle: subtitle ?? this.subtitle,
            title: title ?? this.title,
            type: type ?? this.type,
        );

    factory NotificationElement.fromJson(Map<String, dynamic> json) => NotificationElement(
        createdAt: json["created_at"],
        id: json["id"],
        resourceId: json["resource_id"],
        subtitle: json["subtitle"],
        title: json["title"],
        type: typeValues.map[json["type"]]!,
    );

    Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "id": id,
        "resource_id": resourceId,
        "subtitle": subtitle,
        "title": title,
        "type": typeValues.reverse[type],
    };
}

enum Type {
    ASSESSMENT_REQUESTED_QUICK,
    ASSESSMENT_SUBMITTED_FORMAL,
    ASSESSMENT_SUBMITTED_QUICK
}

final typeValues = EnumValues({
    "assessment_requested_quick": Type.ASSESSMENT_REQUESTED_QUICK,
    "assessment_submitted_formal": Type.ASSESSMENT_SUBMITTED_FORMAL,
    "assessment_submitted_quick": Type.ASSESSMENT_SUBMITTED_QUICK
});

class Notification {
    final String createdAt;
    final String id;
    final String? resourceId;
    final String? subtitle;
    final String title;
    final Type type;

    Notification({
        required this.createdAt,
        required this.id,
        required this.resourceId,
        required this.subtitle,
        required this.title,
        required this.type,
    });

    Notification copyWith({
        String? createdAt,
        String? id,
        String? resourceId,
        String? subtitle,
        String? title,
        Type? type,
    }) => 
        Notification(
            createdAt: createdAt ?? this.createdAt,
            id: id ?? this.id,
            resourceId: resourceId ?? this.resourceId,
            subtitle: subtitle ?? this.subtitle,
            title: title ?? this.title,
            type: type ?? this.type,
        );

    factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        createdAt: json["created_at"],
        id: json["id"],
        resourceId: json["resource_id"],
        subtitle: json["subtitle"],
        title: json["title"],
        type: typeValues.map[json["type"]]!,
    );

    Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "id": id,
        "resource_id": resourceId,
        "subtitle": subtitle,
        "title": title,
        "type": typeValues.reverse[type],
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

