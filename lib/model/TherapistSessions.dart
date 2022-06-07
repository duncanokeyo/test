// To parse this JSON data, do
//
//     final therapistSessions = therapistSessionsFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<TherapistSessions> therapistSessionsFromMap(List<dynamic> items) =>
    List<TherapistSessions>.from(
        items.map((x) => TherapistSessions.fromMap(x)));

class SessionTimes {
  int id;
  TimeOfDay startTime;
  TimeOfDay endTime;
  double price;
  String period;
  int slotSize;
  int sessionId;

  SessionTimes(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.price,
      required this.period,
      required this.slotSize,
      required this.sessionId});

  @override
  String toString() {
    return "id:$id -- startTime:$startTime -- endTime:$endTime -- price:$price -- period:$period -- slotsize:$slotSize --sessionId:$sessionId";
  }

  static List<SessionTimes> getSessionTimes(List<String> items) {
    List<SessionTimes> results = [];

    if (items.isEmpty) {
      return results;
    }

    items.forEach((element) {
      var split = element.split("-");
      print(split.length);
      var id = int.parse(split[0]);
      var start = Utils.timeOfDayFromString(split[1]);
      var end = Utils.timeOfDayFromString(split[2]);
      var price = double.parse(split[3]);
      var period = split[4];
      var slotSize = int.parse(split[5]);
      var sessionId = int.parse(split[6]);

      results.add(SessionTimes(
          id: id,
          startTime: start,
          endTime: end,
          price: price,
          period: period,
          slotSize: slotSize,
          sessionId: sessionId));
    });

    return results;
  }
}

class TherapistSessions {
  TherapistSessions({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.daysAvailable,
    required this.sessionTimes,
    required this.accurateDate,
    required this.accurateTime
  });

  int id;
  DateTime startDate;
  DateTime endDate;
  List<int> daysAvailable;
  List<SessionTimes> sessionTimes;
  DateTime accurateDate;
  TimeOfDay accurateTime;

  @override
  String toString() {
    return "id:$id\nstartDate:$startDate\nendDate:$endDate\ndaysAvailable:$daysAvailable\nsessionTimes$sessionTimes\n";
  }

  factory TherapistSessions.fromMap(Map<String, dynamic> json) =>
      TherapistSessions(
        id: json["id"] == null ? null : json["id"],
        accurateDate: DateTime.parse(json["accurate_date"]),
        accurateTime: Utils.timeOfDayFromString(json['accurate_time']),
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        daysAvailable: List<int>.from(json["days_available"].map((x) => x)),
        sessionTimes: json["session_times"] == null
            ? SessionTimes.getSessionTimes([])
            : SessionTimes.getSessionTimes(
                List<String>.from(
                  json["session_times"].map((x) => x),
                ),
              ),
      );
}
