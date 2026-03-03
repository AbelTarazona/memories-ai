import 'package:memories_web_admin/data/models/daily_mood_model.dart';

class InsightsModel {
  final String peopleMentionedQuantity;
  final String feelingPredominant;
  final String currentStreak;
  final String lastMemoryDate;
  final List<DailyMoodModel> dailyMood;

  InsightsModel({
    required this.peopleMentionedQuantity,
    required this.feelingPredominant,
    required this.currentStreak,
    required this.lastMemoryDate,
    this.dailyMood = const [],
  });
}
