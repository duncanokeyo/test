// To parse this JSON data, do
//
//     final sessionNoteSessionBooking = sessionNoteSessionBookingFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<SessionNoteSessionBooking> sessionNoteSessionBookingFromMap(List<dynamic>items) => List<SessionNoteSessionBooking>.from(items.map((x) => SessionNoteSessionBooking.fromMap(x)));

String sessionNoteSessionBookingToMap(List<SessionNoteSessionBooking> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class SessionNoteSessionBooking {
    SessionNoteSessionBooking({
       required this.id,
       required this.dateBooked,
       required  this.timeBooked,
    });

    int id;
    DateTime dateBooked;
    TimeOfDay timeBooked;

    factory SessionNoteSessionBooking.fromMap(Map<String, dynamic> json) => SessionNoteSessionBooking(
        id: json["id"],
        dateBooked: DateTime.parse(json["date_booked"]),
        timeBooked: Utils.timeOfDayFromString(json["time_booked"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "date_booked": dateBooked == null ? null : "${dateBooked.year.toString().padLeft(4, '0')}-${dateBooked.month.toString().padLeft(2, '0')}-${dateBooked.day.toString().padLeft(2, '0')}",
        "time_booked": timeBooked == null ? null : timeBooked,
    };
}
