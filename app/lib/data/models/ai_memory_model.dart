import 'dart:convert';

class AiMemoryModel {
  final String title;
  final List<String> people;
  final List<String> feelings;
  final List<String> representativeMoments;
  final String mainRepresentativeMoment;
  final List<String> places;
  final Map<String, String> peopleRoles;
  final List<String> objects;
  final List<String> actions;
  final String temporalContext;
  final String overallTone;
  final List<String> category;
  final List<String> keyTopics;
  final String highlightedQuote;
  final List<Map<String, String>> sensorialElements;
  final List<String> lessonsLearned;
  final int emotionalIntensity; // 1 to 10 scale
  final String eventDuration; // e.g., "2 hours", "3 days"
  final String normalizedDate; // ISO 8601 format (YYYY-MM-DD)

  const AiMemoryModel({
    required this.title,
    required this.people,
    required this.peopleRoles,
    required this.feelings,
    required this.representativeMoments,
    required this.mainRepresentativeMoment,
    required this.places,
    required this.objects,
    required this.actions,
    required this.temporalContext,
    required this.overallTone,
    required this.category,
    required this.keyTopics,
    required this.highlightedQuote,
    required this.sensorialElements,
    required this.lessonsLearned,
    required this.emotionalIntensity,
    required this.eventDuration,
    required this.normalizedDate,
  });

  /// Construye desde un Map (ya decodificado del JSON interior).
  factory AiMemoryModel.fromMap(Map<String, dynamic> map) {
    return AiMemoryModel(
      title: map['title'] as String? ?? '',
      people: (map['people'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      peopleRoles: (map['people_roles'] as Map<String, dynamic>? ?? const {}).map((k, v) => MapEntry(k, v.toString())),
      feelings: (map['feelings'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      representativeMoments: (map['representative_moments'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      mainRepresentativeMoment: map['main_representative_moment'] as String? ?? '',
      places: (map['places'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      objects: (map['objects'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      actions: (map['actions'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      temporalContext: map['temporal_context'] as String? ?? '',
      overallTone: map['overall_tone'] as String? ?? '',
      category: (map['category'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      keyTopics: (map['key_topics'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      highlightedQuote: map['highlighted_quote'] as String? ?? '',
      lessonsLearned: (map['lessons_learned'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      emotionalIntensity: map['emotional_intensity'] as int? ?? 0,
      eventDuration: map['event_duration'] as String? ?? '',
      sensorialElements: (map['sensorial_elements'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString())))
          .toList(),
      normalizedDate: map['normalized_date'] as String? ?? '',
    );
  }

  /// Construye directamente desde el JSON interior (String).
  factory AiMemoryModel.fromInnerJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return AiMemoryModel.fromMap(map);
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'people': people,
    'people_roles': peopleRoles,
    'feelings': feelings,
    'representative_moments': representativeMoments,
    'main_representative_moment': mainRepresentativeMoment,
    'places': places,
    'objects': objects,
    'actions': actions,
    'temporal_context': temporalContext,
    'overall_tone': overallTone,
    'category': category,
    'key_topics': keyTopics,
    'highlighted_quote': highlightedQuote,
    'sensorial_elements': sensorialElements,
    'lessons_learned': lessonsLearned,
    'emotional_intensity': emotionalIntensity,
    'event_duration': eventDuration,
    'normalized_date': normalizedDate,
  };

  String toJson() => json.encode(toMap());
}
