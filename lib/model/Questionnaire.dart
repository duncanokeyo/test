// To parse this JSON data, do
//
//     final questionnaire = questionnaireFromMap(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

List<Questionnaire> questionnaireFromMap(List<dynamic> item) =>
    List<Questionnaire>.from(item.map((x) => Questionnaire.fromMap(x)));

String questionnaireToMap(List<Questionnaire> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Questionnaire extends Equatable {
  Questionnaire({
    required this.id,
    required this.count,
    required this.question,
    required this.optionsWithPoints,
  });

  int id;
  int count;
  String question;
  Map<String, dynamic> optionsWithPoints;
  @override
  // TODO: implement props
  List<Object?> get props => [id, question];

  factory Questionnaire.fromMap(Map<String, dynamic> _json) => Questionnaire(
      id: _json["id"] == null ? null : _json["id"],
      count: _json["count"],
      question: _json["question"],
      optionsWithPoints: _json['options_with_points']);

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
      
        "question": question == null ? null : question,
      };


}
