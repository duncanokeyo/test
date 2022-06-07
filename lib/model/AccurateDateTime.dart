// To parse this JSON data, do
//
//     final accurateDateTime = accurateDateTimeFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<AccurateDateTime> accurateDateTimeFromMap(List<dynamic> items) =>
    List<AccurateDateTime>.from(items.map((x) => AccurateDateTime.fromMap(x)));

String accurateDateTimeToMap(List<AccurateDateTime> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class AccurateDateTime {
  AccurateDateTime({
    required this.date,
    required this.time,
  });

  DateTime date;
  TimeOfDay time;

  DateTime getDateWithTime() {
    return DateTime(date.year,date.month,date.day,time.hour,time.minute);
  }

  factory AccurateDateTime.fromMap(Map<String, dynamic> json) =>
      AccurateDateTime(
        date: DateTime.parse(json["date_"]),
        time: Utils.timeOfDayFromString(json["time_"]),
      );

  Map<String, dynamic> toMap() => {
        "date_": date == null
            ? null
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time_": time == null ? null : time,
      };
}
