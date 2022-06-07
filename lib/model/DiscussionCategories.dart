// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

List<DiscussionCategories> discussionCategoriesFromMap(List<dynamic> items) =>
    List<DiscussionCategories>.from(
        items.map((x) => DiscussionCategories.fromMap(x)));

class DiscussionCategories {
  DiscussionCategories({required this.id, required this.category});

  int id;
  String category;

  factory DiscussionCategories.fromMap(Map<String, dynamic> json) =>
      DiscussionCategories(
          id: json["id"] == null ? null : json["id"],
          category: json["category"]);
}
