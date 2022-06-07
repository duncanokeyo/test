// To parse this JSON data, do
//
//     final journal = journalFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<SessionNote> sessionNotesFromMap(List<dynamic> items) =>
    List<SessionNote>.from(items.map((x) => SessionNote.fromMap(x)));

String journalToMap(List<SessionNote> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class SessionNote {
  SessionNote({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.dateBooked,
    required this.timeBooked,
    required this.content,
    required this.therapistId,
    required this.patientId,
  });

  int id;
  DateTime createdAt;
  DateTime dateBooked;
  TimeOfDay timeBooked;
  String title;
  String content;
  String therapistId;
  String patientId;

  factory SessionNote.fromMap(Map<String, dynamic> json) => SessionNote(
        id: json["id"] == null ? null : json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        title: json["title"] == null ? "" : json["title"],
        dateBooked: DateTime.parse(json["date_booked"]),
        timeBooked: Utils.timeOfDayFromString(json["time_booked"]),
        content: json["content"] == null ? "" : json["content"],
        therapistId: json["therapist_id"],
        patientId: json["patient_id"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "title": title == null ? null : title,
        "content": content == null ? null : content,
        "therapist_id": therapistId,
        "patient_id": patientId
      };
}
