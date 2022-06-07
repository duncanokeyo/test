// To parse this JSON data, do
//
//     final therapist = therapistFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<Patient> patientFromMap(List<dynamic> items) =>
    List<Patient>.from(items.map((x) => Patient.fromMap(x)));

String patientToMap(List<Patient> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Patient {
  Patient(
      {required this.id,
      required this.username,
      required this.about,
      required this.location,
      required this.avatarUrl,
      required this.gender,
     });

  String id;
  String username;
  String about;
  String location;
  String avatarUrl;
  String gender;
  



  @override
  String toString() {
    return "id :$id\nusername$username gender$gender";
  }

  static bool getAvailability(String? avaialabilityString) {
    if (avaialabilityString == 'f') {
      return false;
    }
    if (avaialabilityString == 't') {
      return true;
    }

    if (avaialabilityString == null) {
      return false;
    }
    return false;
  }

  factory Patient.fromMap(Map<String, dynamic> json) => Patient(
      id: json["id"],
      username: json["username"] ?? "",
      about: json["about"] ?? "",
      location: json["location"] ?? "",
      avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,  
      gender: json["gender"] ?? "");

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "about": about,
        "location": location,
        "avatar_url": avatarUrl,
        "gender": gender,
      };
}
