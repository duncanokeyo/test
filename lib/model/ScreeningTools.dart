// To parse this JSON data, do
//
//     final screeningTools = screeningToolsFromJson(jsonString);

import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

List<ScreeningTools> screeningToolsFromJson(List<dynamic> items) =>
    List<ScreeningTools>.from(items.map((x) => ScreeningTools.fromJson(x)));

String screeningToolsToJson(List<ScreeningTools> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuestionnaireAnswerCountFlatten {
  QuestionnaireAnswerCount questionnaireAnswerCount;
  int questionnaireTypeId;
  String questionnaireTitle;
  bool hideQuestionnaire;
  int questionnaireQuestionCount;

  QuestionnaireAnswerCountFlatten(
      {required this.questionnaireAnswerCount,
      required this.questionnaireTypeId,
      required this.questionnaireTitle,
      required this.hideQuestionnaire,
      required this.questionnaireQuestionCount});
}

class QuestionnaireAnswerCount {
  int sessionBookingId;
  DateTime dateBooked;
  TimeOfDay timeBooked;
  int answerCount;
  int questionAnswerId;

  String sessionTitle() {
    return "Session @ ${Utils.humanReadableDate(dateBooked)} ${Utils.humanReadableTimeOfDay(timeBooked)}";
  }

  QuestionnaireAnswerCount(
      {required this.sessionBookingId,
      required this.dateBooked,
      required this.timeBooked,
      required this.questionAnswerId,
      required this.answerCount});

  static QuestionnaireAnswerCount from(String questionnaireAnswerCount) {
    var split = questionnaireAnswerCount.split(" ");
    int sessionBookingId = int.parse(split[0]);
    DateTime dateBooked = DateTime.parse(split[1]);
    TimeOfDay timeBooked = Utils.timeOfDayFromString(split[2]);
    int answerCount = int.parse(split[3]);
    int questionAnswerId = int.parse(split[4]);
    return QuestionnaireAnswerCount(
        sessionBookingId: sessionBookingId,
        dateBooked: dateBooked,
        timeBooked: timeBooked,
        questionAnswerId: questionAnswerId,
        answerCount: answerCount);
  }
}

class ScreeningTools {
  ScreeningTools({
    required this.questionnaireTypeId,
    required this.questionnaireTitle,
    required this.hideQuestionnaire,
    required this.isOptionalQuestionnaire,
    required this.questionnaireQuestionCount,
    required this.questionnaireAnswerCount,
  });

  int questionnaireTypeId;
  String questionnaireTitle;
  bool hideQuestionnaire;
  bool isOptionalQuestionnaire;
  int questionnaireQuestionCount;
  List<QuestionnaireAnswerCount> questionnaireAnswerCount;

  factory ScreeningTools.fromJson(Map<String, dynamic> json) => ScreeningTools(
        questionnaireTypeId: json["questionnaire_type_id"],
        questionnaireTitle: json["questionnaire_title"],
        hideQuestionnaire: json["hide_questionnaire"],
        isOptionalQuestionnaire: json["is_optional_questionnaire"],
        questionnaireQuestionCount: json["questionnaire_question_count"] ?? 0,
        questionnaireAnswerCount: json["questionnaire_answer_count"]==null?[]:  List<QuestionnaireAnswerCount>.from(
            json["questionnaire_answer_count"]
                .map((x) => QuestionnaireAnswerCount.from(x))),
        //questionnaireAnswerCount: json["questionnaire_answer_count"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "questionnaire_type_id": questionnaireTypeId,
        "questionnaire_title": questionnaireTitle,
        "hide_questionnaire": hideQuestionnaire,
        "is_optional_questionnaire": isOptionalQuestionnaire,
        "questionnaire_question_count": questionnaireQuestionCount,
        "questionnaire_answer_count": questionnaireAnswerCount,
      };
}
