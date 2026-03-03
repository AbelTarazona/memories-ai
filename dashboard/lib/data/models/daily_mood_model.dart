class DailyMoodModel {
  final DateTime date;
  final int mood;

  DailyMoodModel({
    required this.date,
    required this.mood,
  });

  factory DailyMoodModel.fromJson(Map<String, dynamic> json) {
    return DailyMoodModel(
      date: DateTime.parse(json['day'] as String),
      mood: json['mood'] as int,
    );
  }
}
