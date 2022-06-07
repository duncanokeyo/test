// To parse this JSON data, do
//
//     final post = postFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:equatable/equatable.dart';

List<Post> postFromMap(List<dynamic> items) =>
    List<Post>.from(items.map((x) => Post.fromMap(x)));
String postToMap(List<Post> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Post extends Equatable {
  Post({
    required this.id,
    required this.createdAt,
    required this.username,
    this.avatarUrl,
    required this.posts,
    required this.userId,
  });

  int id;
  DateTime createdAt;
  String username;
  String? avatarUrl;
  List<PostElement> posts;
  String userId;

  factory Post.fromMap(Map<String, dynamic> json) => Post(
        id: json["id"] ?? null,
        createdAt: DateTime.parse(json["created_at"]),
        username: json["username"] ?? null,
        avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
        posts: List<PostElement>.from(
            json["posts"].map((x) => PostElement.fromMap(x))),
        userId: json["user_id"] ?? null,
      );

  Map<String, dynamic> toMap() => {
        "id": id ?? null,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "username": username ?? null,
        "avatar_url": avatarUrl ?? DEFUALT_USER_PROFILE,
        "posts": posts == null
            ? null
            : List<dynamic>.from(posts.map((x) => x.toMap())),
        "user_id": userId ?? null,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [userId];
}

enum MediaType { image, video, text }

class PostElement {
  String? uniqueKey;

  PostElement({
    required this.id,
    required this.when,
    this.color,
    this.media,
    this.caption,
    this.duration,
    required this.avatarUrl,
    required this.userName,
    required this.userId,
    required this.mediaType,
  });
  String id;
  DateTime when;
  String? color;
  String? avatarUrl;
  String userName;
  String? media;
  String? caption;
  String? userId;
  String? duration;
  MediaType mediaType;

  String getTimeAgo() {
    return Utils.getTimeAgo(when);
  }

  static MediaType getMediaType(String? type) {
    print("type is ------------> $type");
    if (type == "image") {
      return MediaType.image;
    }
    if (type == "video") {
      return MediaType.video;
    }
    return MediaType.text;
  }

  static String convertMediaType(MediaType type) {
    if (type == MediaType.image) {
      return "image";
    }
    if (type == MediaType.video) {
      return "video";
    }
    return "text";
  }

  factory PostElement.fromMap(Map<String, dynamic> json) => PostElement(
        id: json["id"],
        when: DateTime.parse(
            json["when"]), //json["when"] == null ? null : json["when"],
        color: json["color"] ?? null,
        userId: json["user_id"],
        media: json["media"] ?? null,
        userName: json["user_name"],
        avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
        caption: json["caption"] ?? null,
        duration: json["duration"].toString() ?? null,
        mediaType: getMediaType(json['mediaType']),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "when": when == null ? null : when.toIso8601String(),
        "color": color ?? null,
        "media": media ?? null,
        "caption": caption ?? null,
        "duration": duration ?? null,
        "mediaType": convertMediaType(mediaType),
      };
}
