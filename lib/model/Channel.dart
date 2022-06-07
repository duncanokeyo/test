// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<Channel> channelFromMap(List<dynamic> items) =>
    List<Channel>.from(items.map((x) => Channel.fromMap(x)));

class Channel {
  Channel(
      {required this.id,
      required this.therapistName,
      required this.therapistId,
      required this.patientName,
      required this.createdAt,
      required this.patientId,
      required this.therapistAvatarUrl,
      required this.patientAvatarUrl,
      required this.lastMessage,
      required this.lastMessageType,
      required this.lastMessageTime});

  int id;
  String therapistName;
  String therapistId;
  DateTime createdAt;
  String patientName;
  String patientId;
  String therapistAvatarUrl;
  String patientAvatarUrl;
  String lastMessage;
  String lastMessageType;
  DateTime lastMessageTime;

  factory Channel.fromMap(Map<String, dynamic> json) => Channel(
      id: json["id"],
      therapistName:
          json["therapist_name"] ?? "",
      createdAt: DateTime.parse(json["created_at"]),
      therapistId: json["therapist_id"],
      patientName: json["patient_name"]??"",
      patientId: json["patient_id"],
      therapistAvatarUrl: json["therapist_avatar_url"] ?? DEFUALT_USER_PROFILE,
      patientAvatarUrl:
          json["patient_avatar_url"] ?? DEFUALT_USER_PROFILE,
      lastMessage: json["last_message"]??"",
      lastMessageTime: DateTime.parse(json["last_message_timestamp"]),
      lastMessageType: json["last_message_type"]);
}
