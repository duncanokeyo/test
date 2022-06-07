// To parse this JSON data, do
//
//     final topPicks = topPicksFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<Articles> articlesFromMap(List<dynamic> items) =>
    List<Articles>.from(items.map((x) => Articles.fromMap(x)));

class Articles {
  Articles({
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
    String url = "";
    links?.forEach((key, value) {
      url = value;
    });
    return url;
  }

  factory Articles.fromMap(Map<String, dynamic> json) => Articles(
        date: DateTime.parse(json["date_created"]),
        title: json["title"],
        description: json["description"] == null ? "" : json["description"],
        content: json["content"] == null ? "" : json["content"],
        links: json["links"] == null ? [] : json["links"],
        username: json["username"] == null ? "" : json["username"],
        avatarUrl: json["avatar_url"] == null ? DEFUALT_USER_PROFILE : json["avatar_url"],
        category: json["category"] == null ? null : json["category"],
      );
}
