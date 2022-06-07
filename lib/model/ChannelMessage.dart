// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:collection';
import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<ChannelMessage> channelMessagesFromMap(List<dynamic> items) =>
    List<ChannelMessage>.from(items.map((x) => ChannelMessage.fromMap(x)));

class ChannelMessage {
  ChannelMessage(
      {required this.id,
      required this.createdAt,
      required this.channelId,
      required this.type,
      required this.avatarUrl,
      required this.userId,
      required this.status,
      required this.userName,
      required this.text,
      required this.meta,
      required this.isScreenToolMessage});

  int id;
  DateTime createdAt;
  int channelId;
  String type;
  String avatarUrl;
  String userId;
  String status;
  String userName;
  String text;
  bool isScreenToolMessage;
  Map<String, dynamic> meta;

  Map<String, dynamic> chatFormat() {
    Map<String, dynamic> results = HashMap();
    results["created_at"] = createdAt.millisecondsSinceEpoch;
    results["id"] = channelId.toString();
    results["status"] = status;

    if (isScreenToolMessage) {
      var appendUserIdentifier =
          "${text.trim()}&user=${supabase.auth.currentUser!.id}";
      results["text"] = appendUserIdentifier;
    } else {
      results["text"] = text;
    }

    results["type"] = type;

    Map<String, dynamic> author = HashMap();
    author["firstName"] = userName;
    author["id"] = userId;
    author["imageUrl"] = avatarUrl;

    results["author"] = author;

    if (type == "image") {
      results["size"] = meta["size"];
      results["uri"] = meta["uri"];
      results["width"] = meta["width"];
      results["name"] = meta["name"];
      results["height"] = meta["height"];
    }

    return results;
  }

  factory ChannelMessage.fromMap(Map<String, dynamic> json) => ChannelMessage(
      id: json["id"],
      createdAt: DateTime.parse(json["created_at"]),
      channelId: json["channel_id"],
      type: json["type"],
      avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
      userId: json["user_id"],
      status: json["status"],
      userName: json["username"],
      isScreenToolMessage: json["is_screen_tool_message"],
      meta: json["meta"] == null ? HashMap() : jsonDecode(json["meta"]),
      text: json["text"]);

  @override
  String toString() {
    return "\n\nid:$id\ncreated_at:$createdAt\nchannelid:$channelId\ntype:$type\navatar url:$avatarUrl\nuser id:$userId\nstatus:$status\nuserName:$userName\ntext$text\n";
  }
}
