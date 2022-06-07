// To parse this JSON data, do
//
//     final sessionNoteSessionBooking = sessionNoteSessionBookingFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<ScreeningToolsSessionBooking> screeningToolsSessionBookingFromMap(List<dynamic>items) => List<ScreeningToolsSessionBooking>.from(items.map((x) => ScreeningToolsSessionBooking.fromMap(x)));

// String sessionNoteSessionBookingToMap(List<ScreeningToolsSessionBooking> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ScreeningToolsSessionBooking {
    ScreeningToolsSessionBooking({
       required this.id,
       required this.dateBooked,
       required  this.timeBooked,
    });

    int id;
    DateTime dateBooked;
    TimeOfDay timeBooked;

    factory ScreeningToolsSessionBooking.fromMap(Map<String, dynamic> json) => ScreeningToolsSessionBooking(
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
