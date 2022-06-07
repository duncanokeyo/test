// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<ChatRoom> chatRoomFromMap(List<dynamic> items) =>
    List<ChatRoom>.from(items.map((x) => ChatRoom.fromMap(x)));

class ChatRoom {
  ChatRoom(
      {required this.id,
      required this.userName,
      required this.createdAt,
      required this.message,
      required this.avatarUrl,
      required this.userId,
      required this.categoryID,
      required this.commentCount});

  int id;
  String userName;
  String userId;
  DateTime createdAt;
  String message;
  String avatarUrl;
  int categoryID;
  int commentCount;

  factory ChatRoom.fromMap(Map<String, dynamic> json) => ChatRoom(
      id: json["id"] == null ? null : json["id"],
      userName: json["username"] == null ? null : json["username"],
      createdAt: DateTime.parse(json["created_at"]),
      message: json["message"],
      userId: json["user_id"],
      avatarUrl: json["avatar_url"]??DEFUALT_USER_PROFILE,
      categoryID: json["category_id"],
      commentCount: json["comment_count"]);
}
