// To parse this JSON data, do
//
//     final topPicks = topPicksFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<TopPicks> topPicksFromMap(List<dynamic> items) =>
    List<TopPicks>.from(items.map((x) => TopPicks.fromMap(x)));

class TopPicks {
  TopPicks({
    required this.date,
    required this.title,
    required this.description,
    required this.content,
    required this.links,
    required this.username,
    required this.avatarUrl,
    required this.category,
  });

  DateTime date;
  String title;
  String description;
  String content;
  String username;
  dynamic avatarUrl;
  String category;

  Map<String, dynamic>? links;

  getBannerUrl() {
    if (links == null) {
      return "";
    }
    var results = "";
    links?.forEach((key, value) {
      results = value;
    });
    return results;
  }

  factory TopPicks.fromMap(Map<String, dynamic> json) => TopPicks(
        date: DateTime.parse(json["date_created"]),
        title: json["title"],
        description: json["description"] == null ? "" : json["description"],
        content: json["content"] == null ? "" : json["content"],
        links: json["links"] == null ? [] : json["links"],
        username: json["username"] == null ? "" : json["username"],
        avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
        category: json["category"] == null ? null : json["category"],
      );
}
