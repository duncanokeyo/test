// To parse this JSON data, do
//
//     final linkTemplate = linkTemplateFromJson(jsonString);

import 'dart:convert';

List<LinkTemplate> linkTemplateFromJson(List<dynamic>items) => List<LinkTemplate>.from(items.map((x) => LinkTemplate.fromJson(x)));

String linkTemplateToJson(List<LinkTemplate> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LinkTemplate {
    LinkTemplate({
        required this.id,
        required this.createdAt,
        this.screeningToolInput,
        this.screeningToolResults,
    });

    int id;
    DateTime createdAt;
    String ?screeningToolInput;
    String ?screeningToolResults;

    factory LinkTemplate.fromJson(Map<String, dynamic> json) => LinkTemplate(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        screeningToolInput: json["screening_tool_input"],
        screeningToolResults: json["screening_tool_results"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "screening_tool_input": screeningToolInput,
        "screening_tool_results": screeningToolResults,
    };
}
