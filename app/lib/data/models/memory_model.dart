class MemoryModel {
  final int id;
  final String content;
  final DateTime createdAt;
  final String? aiImage;
  final String? aiTitle;
  final List<String>? aiFeelings;
  final List<String>? aiRepresentativeMoments;
  final String? aiMainRepresentativeMoment;
  final String? aiImagePrompt;
  final List<String>? aiPeople;
  final Map<String, dynamic>? aiPeopleRoles;
  final List<String>? aiPlaces;
  final List<String>? aiObjects;
  final List<String>? aiActions;
  final String? aiTemporalContext;
  final String? aiOverallTone;
  final List<String>? aiCategory;
  final List<String>? aiKeyTopics;
  final String? aiHighlightedQuote;
  final List<Map<String, dynamic>?>? aiSensorialElements;
  final List<String>? aiLessonsLearned;
  final int? aiEmotionalIntensity;
  final String? aiEventDuration;

  MemoryModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.aiImage,
    this.aiTitle,
    this.aiFeelings,
    this.aiRepresentativeMoments,
    this.aiMainRepresentativeMoment,
    this.aiImagePrompt,
    this.aiPeople,
    this.aiPeopleRoles,
    this.aiPlaces,
    this.aiObjects,
    this.aiActions,
    this.aiTemporalContext,
    this.aiOverallTone,
    this.aiCategory,
    this.aiKeyTopics,
    this.aiHighlightedQuote,
    this.aiSensorialElements,
    this.aiLessonsLearned,
    this.aiEmotionalIntensity,
    this.aiEventDuration,
  });

  /// Factory constructor for creating a new `MemoryModel` from a map.
  factory MemoryModel.fromMap(Map<String, dynamic> map) {
    return MemoryModel(
      id: map['id'] as int,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      aiImage: map['ai_image'] as String?,
      aiTitle: map['ai_title'] as String?,
      aiFeelings: (map['ai_feelings'] as List?)?.map((e) => e.toString()).toList(),
      aiRepresentativeMoments:
      (map['ai_representative_moments'] as List?)?.map((e) => e.toString()).toList(),
      aiMainRepresentativeMoment: map['ai_title'] as String?,
      aiImagePrompt: map['ai_image_prompt'] as String?,
      aiPeople: (map['ai_people'] as List?)?.map((e) => e.toString()).toList(),
      aiPeopleRoles: (map['ai_people_roles'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
      aiPlaces: (map['ai_places'] as List?)?.map((e) => e.toString()).toList(),
      aiObjects: (map['ai_objects'] as List?)?.map((e) => e.toString()).toList(),
      aiActions: (map['ai_actions'] as List?)?.map((e) => e.toString()).toList(),
      aiTemporalContext: map['ai_temporal_context'] as String?,
      aiOverallTone: map['ai_overall_tone'] as String?,
      aiCategory: (map['ai_category'] as List?)?.map((e) => e.toString()).toList(),
      aiKeyTopics: (map['ai_key_topics'] as List?)?.map((e) => e.toString()).toList(),
      aiHighlightedQuote: map['ai_highlighted_quote'] as String?,
      aiSensorialElements: (map['ai_sensorial_elements'] as List?)
          ?.map((e) => e != null ? Map<String, dynamic>.from(e as Map) : null)
          .toList(),
      aiLessonsLearned: (map['ai_lessons_learned'] as List?)?.map((e) => e.toString()).toList(),
      aiEmotionalIntensity: map['ai_emotional_intensity'] as int?,
      aiEventDuration: map['ai_event_duration'] as String?,
    );
  }

  /// Converts the model back into a map (useful for saving to Firestore/SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'ai_image': aiImage,
      'ai_title': aiTitle,
      'ai_feelings': aiFeelings,
      'ai_representative_moments': aiRepresentativeMoments,
      'ai_main_representative_moment': aiMainRepresentativeMoment,
      'ai_image_prompt': aiImagePrompt,
      'ai_people': aiPeople,
      'ai_people_roles': aiPeopleRoles,
      'ai_places': aiPlaces,
      'ai_objects': aiObjects,
      'ai_actions': aiActions,
      'ai_temporal_context': aiTemporalContext,
      'ai_overall_tone': aiOverallTone,
      'ai_category': aiCategory,
      'ai_key_topics': aiKeyTopics,
      'ai_highlighted_quote': aiHighlightedQuote,
      'ai_sensorial_elements': aiSensorialElements,
      'ai_lessons_learned': aiLessonsLearned,
      'ai_emotional_intensity': aiEmotionalIntensity,
      'ai_event_duration': aiEventDuration,
    };
  }

  /// Helper to clone and modify immutably
  MemoryModel copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    String? aiImage,
    String? aiTitle,
    List<String>? aiFeelings,
    List<String>? aiRepresentativeMoments,
    String? aiMainRepresentativeMoment,
    String? aiImagePrompt,
    List<String>? aiPeople,
    Map<String, dynamic>? aiPeopleRoles,
    List<String>? aiPlaces,
    List<String>? aiObjects,
    List<String>? aiActions,
    String? aiTemporalContext,
    String? aiOverallTone,
    List<String>? aiCategory,
    List<String>? aiKeyTopics,
    String? aiHighlightedQuote,
    List<Map<String, dynamic>?>? aiSensorialElements,
    List<String>? aiLessonsLearned,
    int? aiEmotionalIntensity,
    String? aiEventDuration,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      aiImage: aiImage ?? this.aiImage,
      aiTitle: aiTitle ?? this.aiTitle,
      aiFeelings: aiFeelings ?? this.aiFeelings,
      aiRepresentativeMoments: aiRepresentativeMoments ?? this.aiRepresentativeMoments,
      aiMainRepresentativeMoment: aiMainRepresentativeMoment ?? this.aiMainRepresentativeMoment,
      aiImagePrompt: aiImagePrompt ?? this.aiImagePrompt,
      aiPeople: aiPeople ?? this.aiPeople,
      aiPeopleRoles: aiPeopleRoles ?? this.aiPeopleRoles,
      aiPlaces: aiPlaces ?? this.aiPlaces,
      aiObjects: aiObjects ?? this.aiObjects,
      aiActions: aiActions ?? this.aiActions,
      aiTemporalContext: aiTemporalContext ?? this.aiTemporalContext,
      aiOverallTone: aiOverallTone ?? this.aiOverallTone,
      aiCategory: aiCategory ?? this.aiCategory,
      aiKeyTopics: aiKeyTopics ?? this.aiKeyTopics,
      aiHighlightedQuote: aiHighlightedQuote ?? this.aiHighlightedQuote,
      aiSensorialElements: aiSensorialElements ?? this.aiSensorialElements,
      aiLessonsLearned: aiLessonsLearned ?? this.aiLessonsLearned,
      aiEmotionalIntensity: aiEmotionalIntensity ?? this.aiEmotionalIntensity,
      aiEventDuration: aiEventDuration ?? this.aiEventDuration,
    );
  }
}
