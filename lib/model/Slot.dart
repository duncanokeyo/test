// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

List<Slot> slotFromMap(List<dynamic> items) =>
    List<Slot>.from(items.map((x) => Slot.fromMap(x)));

class Slot extends Equatable {
  Slot(
      {required this.id,
      required this.slot,
      required this.accurateDate,
      required this.accurateTime});

  int id;
  int slot;
  DateTime accurateDate;
  TimeOfDay accurateTime;

  factory Slot.fromMap(Map<String, dynamic> json) => Slot(
      id: json["id"],
      slot: json["slot"],
      accurateDate: DateTime.parse(json["current_date_"]),
      accurateTime: Utils.timeOfDayFromString(json["current_time_"]));

  @override
  // TODO: implement props
  List<Object?> get props => [slot];
}
