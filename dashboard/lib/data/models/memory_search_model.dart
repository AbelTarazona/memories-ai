class MemorySearchModel {
  final String id;
  final String? aiTitle;
  final String? content;
  final double similarity;
  // Campos adicionales para enriquecer el contexto del LLM
  final List<String>? feelings;
  final List<String>? people;
  final List<String>? places;
  final String? overallTone;
  final String? temporalContext;
  final String? highlightedQuote;
  final List<String>? keyTopics;

  MemorySearchModel({
    required this.id,
    this.aiTitle,
    this.content,
    required this.similarity,
    this.feelings,
    this.people,
    this.places,
    this.overallTone,
    this.temporalContext,
    this.highlightedQuote,
    this.keyTopics,
  });

  factory MemorySearchModel.fromJson(Map<String, dynamic> json) {
    return MemorySearchModel(
      id: json['id'] as String,
      aiTitle: json['ai_title'] as String?,
      content: json['content'] as String?,
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      feelings: (json['ai_feelings'] as List<dynamic>?)?.cast<String>(),
      people: (json['ai_people'] as List<dynamic>?)?.cast<String>(),
      places: (json['ai_places'] as List<dynamic>?)?.cast<String>(),
      overallTone: json['ai_overall_tone'] as String?,
      temporalContext: json['ai_temporal_context'] as String?,
      highlightedQuote: json['ai_highlighted_quote'] as String?,
      keyTopics: (json['ai_key_topics'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Convierte a JSON para enviar al LLM con contexto enriquecido
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ai_title': aiTitle,
      'content': content,
      if (feelings != null && feelings!.isNotEmpty) 'feelings': feelings,
      if (people != null && people!.isNotEmpty) 'people': people,
      if (places != null && places!.isNotEmpty) 'places': places,
      if (overallTone != null) 'tone': overallTone,
      if (temporalContext != null) 'temporal_context': temporalContext,
      if (highlightedQuote != null) 'highlighted_quote': highlightedQuote,
      if (keyTopics != null && keyTopics!.isNotEmpty) 'key_topics': keyTopics,
    };
  }
}
