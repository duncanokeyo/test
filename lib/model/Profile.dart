// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/utils/constants.dart';

List<Profile> profileFromMap(List<dynamic> items) =>
    List<Profile>.from(items.map((x) => Profile.fromMap(x)));

class Profile {
  Profile(
      {required this.id,
      required this.username,
      required this.gender,
      required this.avatarUrl,
      required this.location,
      required this.phoneNumber,
      required this.about,
      required this.email});

  String id;
  String username;
  String gender;
  String phoneNumber;
  String avatarUrl;
  String location;
  String about;
  String email;

  factory Profile.fromMap(Map<String, dynamic> json) => Profile(
        id: json["id"],
        username: json["username"] ?? "",
        gender: json["gender"] ?? "male",
        avatarUrl: json["avatar_url"] ?? DEFUALT_USER_PROFILE,
        location: json["location"] ?? "",
        about: json["about"] ?? "",
        phoneNumber: json["phone_number"] ?? "",
        email: json["email"] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "username": username ?? "",
        "gender": gender ?? "male",
        "avatar_url": avatarUrl,
        "location": location ?? "",
        "about": about ?? "",
        "email": email??"",
        'phone_number': phoneNumber
      };

  @override
  String toString() {
    // TODO: implement toString
    return "id:$id\nusername:$username:gender:$gender\navatar_url:$avatarUrl\nlocation$location\nabout:$about\nemail:$email\nphoneNumber:$phoneNumber";
  }
}
