// To parse this JSON data, do
//
//     final healthConcern = healthConcernFromMap(jsonString);

import 'dart:convert';

List<HealthConcern> healthConcernFromMap(List<dynamic>items) => List<HealthConcern>.from(items.map((x) => HealthConcern.fromMap(x)));

String healthConcernToMap(List<HealthConcern> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class HealthConcern {
    HealthConcern({
        required this.id,
        required this.createdAt,
        required this.concern,
        required this.iconUrl,
    });

    int id;
    DateTime createdAt;
    String concern;
    String iconUrl;

    factory HealthConcern.fromMap(Map<String, dynamic> json) => HealthConcern(
        id: json["id"] == null ? null : json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        concern: json["concern"] == null ? null : json["concern"],
        iconUrl: json["icon_url"] == null ? "" : json["icon_url"],
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "concern": concern == null ? null : concern,
        "icon_url": iconUrl == null ? null : iconUrl,
    };
}
