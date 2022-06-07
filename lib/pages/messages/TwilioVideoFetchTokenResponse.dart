// To parse this JSON data, do
//
//     final twilioVideoFetchTokenResponse = twilioVideoFetchTokenResponseFromJson(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/AccurateDateTime.dart';
import 'package:flutter/material.dart';

TwilioVideoFetchTokenResponse twilioVideoFetchTokenResponseFromJson(
        dynamic item) =>
    TwilioVideoFetchTokenResponse.fromJson(item);

String twilioVideoFetchTokenResponseToJson(
        TwilioVideoFetchTokenResponse data) =>
    json.encode(data.toJson());

class TwilioVideoFetchTokenResponse {
  TwilioVideoFetchTokenResponse(
      {required this.date,
      required this.time,
      required this.error,
      required this.content,
      required this.token,
      required this.errorMessage,
      required this.timeRemaining,
      required this.accurateDate,
      required this.accurateTime});

  DateTime date;
  DateTime? accurateDate;
  TimeOfDay? accurateTime;
  String time;
  bool error;
  String content;
  String token;
  String errorMessage;
  String timeRemaining;

  AccurateDateTime accurateDateTimeFrom() {
    return AccurateDateTime(date: accurateDate!, time: accurateTime!);
  }

  int timeRemainingInSeconds() {
    TimeOfDay time = Utils.timeOfDayFromString(timeRemaining);
    int remainingSec = (time.hour * 60 + time.minute) * 60;
    return remainingSec;
  }

  factory TwilioVideoFetchTokenResponse.fromJson(Map<String, dynamic> json) =>
      TwilioVideoFetchTokenResponse(
          date: DateTime.parse(json["date"]),
          time: json["time"] ?? "",
          error: json["error"] ?? "",
          token: json["token"] ?? "",
          content: json["content"] ?? "",
          errorMessage: json["error_message"] ?? "",
          timeRemaining: json["time_remaining"] ?? "",
          accurateDate: json["accurate_date"] != null
              ? DateTime.parse(json["accurate_date"])
              : null,
          accurateTime: json["accurate_time"] != null
              ? Utils.timeOfDayFromString(json["accurate_time"])
              : null);

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "error": error,
        "content": content,
        "error_message": errorMessage,
        "time_remaining": timeRemaining,
      };
}
