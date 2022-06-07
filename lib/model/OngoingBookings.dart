import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<OnGoingBookings> ongoingBookingsFromMap(List<dynamic> items) =>
    List<OnGoingBookings>.from(items.map((x) => OnGoingBookings.fromMap(x)));

class OnGoingBookings {
  OnGoingBookings(
      {
      required this.dateBooked,
      required this.time,
    });


  DateTime dateBooked;
  TimeOfDay time;


  factory OnGoingBookings.fromMap(Map<String, dynamic> json) => OnGoingBookings(
       
        dateBooked: DateTime.parse(json["date_booked"]),
     
        time: Utils.timeOfDayFromString(json["time"]),
      );
}
