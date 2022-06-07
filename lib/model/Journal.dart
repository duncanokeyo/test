// To parse this JSON data, do
//
//     final journal = journalFromMap(jsonString);

import 'dart:convert';

List<Journal> journalFromMap(List<dynamic> items) => List<Journal>.from(items.map((x) => Journal.fromMap(x)));

String journalToMap(List<Journal> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Journal {
    Journal({
      required  this.id,
      required this.createdAt,
        this.title,
      required this.content,
        this.image,
        this.color,
      required this.userId,
    });

    int id;
    DateTime createdAt;
    String? title;
    String content;
    dynamic image;
    dynamic color;
    String userId;

    factory Journal.fromMap(Map<String, dynamic> json) => Journal(
        id: json["id"] == null ? null : json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        title: json["title"] == null ? null : json["title"],
        content: json["content"] == null ? null : json["content"],
        image: json["image"],
        color: json["color"],
        userId: json["user_id"] == null ? null : json["user_id"],
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "title": title == null ? null : title,
        "content": content == null ? null : content,
        "image": image,
        "color": color,
        "user_id": userId == null ? null : userId,
    };
}
