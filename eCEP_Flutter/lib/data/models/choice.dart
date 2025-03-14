class Choice {
  final String id;
  final String text;

  Choice({
    required this.id,
    required this.text,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'],
      text: json['text'],
    );
  }
}