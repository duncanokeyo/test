// To parse this JSON data, do
//
//     final statusLog = statusLogFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';
List<StatusLogTherapist> statusLogFromMap(List<dynamic>items) => List<StatusLogTherapist>.from(items.map((x) => StatusLogTherapist.fromMap(x)));
String statusLogToMap(List<StatusLogTherapist> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));
class StatusLogTherapist {
    StatusLogTherapist({
        required this.statusLogs,
    });

    

    List<StatusLogElement> statusLogs;

    factory StatusLogTherapist.fromMap(Map<String, dynamic> json) => StatusLogTherapist(
        statusLogs: json["therapist_status_logs"] == null ? [] : List<StatusLogElement>.from(json["therapist_status_logs"].map((x) => StatusLogElement.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "therapist_status_logs": statusLogs == null ? null : List<dynamic>.from(statusLogs.map((x) => x.toMap())),
    };
}

class StatusLogElement {
    StatusLogElement({
       required this.type,
       required this.date,
    });

    Status type;
    DateTime date;

    factory StatusLogElement.fromMap(Map<String, dynamic> json) => StatusLogElement(
        type: Status.values[json["type"]],
        date: DateTime.parse(json["date"]),
    );

    Map<String, dynamic> toMap() => {
        "type": type.index,
        "date": date.toIso8601String(),
    };

    
}



enum Status{
  NOTIFICATION_SENT,
  CLIENT_TAPPED_ON_NOTIFICAION,
  THERAPIST_INITIATED_CALL,
  THERAPIST_ENDED_CALL,
  CLIENT_ANSWERED_CALL,
}