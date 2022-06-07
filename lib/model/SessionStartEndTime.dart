// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<SessionStartEndTime> sessionStartEndTimeFromMap(List<dynamic> items) =>
    List<SessionStartEndTime>.from(items.map((x) => SessionStartEndTime.fromMap(x)));

class SessionStartEndTime {
  SessionStartEndTime({required this.startDate, required this.endDate});

  DateTime startDate;
  DateTime endDate;

  factory SessionStartEndTime.fromMap(Map<String, dynamic> json) =>
      SessionStartEndTime(
          startDate: DateTime.parse(json["start_date"]),
          endDate: DateTime.parse(json["end_date"]));
}
