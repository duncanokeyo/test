import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';

List<SessionBookings> sessionBookingsFromMap(List<dynamic> items) =>
    List<SessionBookings>.from(items.map((x) => SessionBookings.fromMap(x)));

class SessionBookings {
  SessionBookings(
      {required this.id,
      required this.amount,
      required this.dateBooked,
      required this.time,
      required this.username,
      required this.avatarUrl,
      required this.refNo,
      required this.amountPaid,
      required this.completed,
      required this.slotSize,
      required this.specialization,
      required this.patientId});

  int id;
  String patientId;
  double amount;
  double amountPaid;
  int slotSize;
  String refNo;
  DateTime dateBooked;
  TimeOfDay time;
  String username;
  bool completed;
  String avatarUrl;
  List<String> specialization;

  isPaid() {
    return amountPaid >= amount;
  }

  Map<String, dynamic> toMap(
          String therapistId, String therapistAvatar, String therapistName) =>
      {
        "id": id,
        "therapist_id": therapistId,
        "amount": amount,
        "amount_paid": amountPaid,
        "slotSize": slotSize,
        "dateBooked": Utils.getParamTimeFormat(dateBooked),
        "time": Utils.getTimeOfDayParam(time),
        "refNo": refNo,
        "completed":completed,
        "type": "audiovideocall",
        "username": therapistName,
        "avatarUrl": therapistAvatar,
      };

  factory SessionBookings.fromMap(Map<String, dynamic> json) => SessionBookings(
        id: json["id"] == null ? null : json["id"],
        patientId: json["patient_id"],
        amountPaid: json["amount_paid"] == null
            ? 0.0
            : double.parse(json["amount_paid"].toString()),
        slotSize: json["slot_size"],
        completed: json["completed"],
        username: json["username"] == null ? "" : json["username"],
        dateBooked: DateTime.parse(json["date_booked"]),
        amount: double.parse(json["amount"].toString()),
        refNo: json["ref_no"],
        time: Utils.timeOfDayFromString(json["time_"]),
        avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
        specialization: json["specialization"] == null
            ? []
            : List<String>.from(json["specialization"].map((x) => x)),
      );
}
