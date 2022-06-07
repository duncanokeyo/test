class Question {
  final int id;
  final String question;
  final List<String> options;

  Question({required this.id, required this.question, required this.options});

   @override
 bool operator ==(Object other) =>
  identical(this, other) ||
  other is Question &&
  runtimeType == other.runtimeType &&
  id == other.id &&
  question == other.question;

  @override
  int get hashCode => this.question.hashCode;
}

const List sample_data = [
  {
    "id": 1,
    "question": "What gender of specialists will you want to see",
    "options": ['Male', 'Female'],
  },
];
