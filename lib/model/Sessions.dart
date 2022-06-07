// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<Sessions> sessionsFromMap(List<dynamic> items) =>
    List<Sessions>.from(items.map((x) => Sessions.fromMap(x)));

class Sessions {
  Sessions(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.daysAvailable});

  int id;
  List<int> daysAvailable;
  DateTime startDate;
  DateTime endDate;

  String formatTimeRange() {
    return Utils.humanReadableDate(startDate) +
        " to " +
        Utils.humanReadableDate(endDate);
  }

  factory Sessions.fromMap(Map<String, dynamic> json) => Sessions(
      id: json["id"],
      daysAvailable: json["days_available"] == null
          ? []
          : List<int>.from(json["days_available"].map((x) => x)),
      startDate: DateTime.parse(json["start_date"]),
      endDate: DateTime.parse(json["end_date"]));
}
