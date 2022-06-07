// To parse this JSON data, do
//
//     final chatRoomReplies = chatRoomRepliesFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<ChatRoomReplies> chatRoomRepliesFromMap(List<dynamic> items) =>
    List<ChatRoomReplies>.from(items.map((x) => ChatRoomReplies.fromMap(x)));

String chatRoomRepliesToMap(List<ChatRoomReplies> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ChatRoomReplies {
  ChatRoomReplies({
    required this.id,
    required this.reply,
    required this.profiles,
    required this.userId,
  });

  int id;
  String reply;
  Profiles profiles;
  String userId;

  factory ChatRoomReplies.fromMap(Map<String, dynamic> json) => ChatRoomReplies(
        reply: json["reply"] == null ? null : json["reply"],
        userId: json["user_id"],
        id:json["id"],
        profiles: Profiles.fromMap(json["profiles"]),
      );

  Map<String, dynamic> toMap() => {
        "reply": reply == null ? null : reply,
        "profiles": profiles == null ? null : profiles.toMap(),
      };
}

class Profiles {
  Profiles({
    required this.username,
    required this.avatarUrl,
  });

  String username;
  String avatarUrl;

  factory Profiles.fromMap(Map<String, dynamic> json) => Profiles(
        username: json["username"] == null ? null : json["username"],
        avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
      );

  Map<String, dynamic> toMap() => {
        "username": username == null ? null : username,
        "avatar_url": avatarUrl ?? DEFUALT_USER_PROFILE,
      };
}
