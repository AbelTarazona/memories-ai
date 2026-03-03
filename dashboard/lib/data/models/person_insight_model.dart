import 'dart:convert';

class PersonInsightModel {
  final String personId;
  final String userId;
  final String? summary;
  final DominantRole? dominantRole;
  final EmotionalImpact? emotionalImpact;
  final RelationshipEvolution? relationshipEvolution;
  final List<String>? keyThemes;
  final List<String>? representativeQuotes;
  final List<RiskFlag>? riskFlags;
  final double? confidenceScore;
  final int? sourceMemoriesCount;
  final DateTime? analyzedAt;
  final String? modelUsed;

  PersonInsightModel({
    required this.personId,
    required this.userId,
    this.summary,
    this.dominantRole,
    this.emotionalImpact,
    this.relationshipEvolution,
    this.keyThemes,
    this.representativeQuotes,
    this.riskFlags,
    this.confidenceScore,
    this.sourceMemoriesCount,
    this.analyzedAt,
    this.modelUsed,
  });

  factory PersonInsightModel.fromJson(Map<String, dynamic> json) {
    return PersonInsightModel(
      personId: json['person_id'] as String,
      userId: json['user_id'] as String,
      summary: json['summary'] as String?,
      dominantRole: _parseJsonField(
        json['dominant_role'],
        DominantRole.fromJson,
      ),
      emotionalImpact: _parseJsonField(
        json['emotional_impact'],
        EmotionalImpact.fromJson,
      ),
      relationshipEvolution: _parseJsonField(
        json['relationship_evolution'],
        RelationshipEvolution.fromJson,
      ),
      keyThemes: _parseListField<String>(json['key_themes']),
      representativeQuotes: _parseListField<String>(
        json['representative_quotes'],
      ),
      riskFlags: _parseListField<RiskFlag>(
        json['risk_flags'],
        (item) => RiskFlag.fromJson(item as Map<String, dynamic>),
      ),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      sourceMemoriesCount: json['source_memories_count'] as int?,
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.parse(json['analyzed_at'] as String)
          : null,
      modelUsed: json['model_used'] as String?,
    );
  }

  static T? _parseJsonField<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return fromJson(value);
    }
    if (value is String) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        return fromJson(map);
      } catch (e) {
        print('Error parsing JSON field: $e');
        return null;
      }
    }
    return null;
  }

  static List<T>? _parseListField<T>(
    dynamic value, [
    T Function(dynamic)? fromJson,
  ]) {
    if (value == null) return null;
    if (value is List) {
      if (fromJson != null) {
        return value.map((e) => fromJson(e)).cast<T>().toList();
      }
      return value.cast<T>();
    }
    if (value is String) {
      try {
        final list = jsonDecode(value) as List;
        if (fromJson != null) {
          return list.map((e) => fromJson(e)).cast<T>().toList();
        }
        return list.cast<T>();
      } catch (e) {
        print('Error parsing List field: $e');
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'person_id': personId,
      'user_id': userId,
      'summary': summary,
      'dominant_role': dominantRole?.toJson(),
      'emotional_impact': emotionalImpact?.toJson(),
      'relationship_evolution': relationshipEvolution?.toJson(),
      'key_themes': keyThemes,
      'representative_quotes': representativeQuotes,
      'risk_flags': riskFlags?.map((e) => e.toJson()).toList(),
      'confidence_score': confidenceScore,
      'source_memories_count': sourceMemoriesCount,
      'analyzed_at': analyzedAt?.toIso8601String(),
      'model_used': modelUsed,
    };
  }
}

class DominantRole {
  final String? label;
  final double? confidence;

  DominantRole({this.label, this.confidence});

  factory DominantRole.fromJson(Map<String, dynamic> json) {
    return DominantRole(
      label: json['label'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
    };
  }
}

class EmotionalImpact {
  final List<String>? dominantEmotions;
  final String? overallBalance;
  final String? averageIntensity;

  EmotionalImpact({
    this.dominantEmotions,
    this.overallBalance,
    this.averageIntensity,
  });

  factory EmotionalImpact.fromJson(Map<String, dynamic> json) {
    return EmotionalImpact(
      dominantEmotions: (json['dominant_emotions'] as List<dynamic>?)
          ?.cast<String>(),
      overallBalance: json['overall_balance'] as String?,
      averageIntensity: json['average_intensity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dominant_emotions': dominantEmotions,
      'overall_balance': overallBalance,
      'average_intensity': averageIntensity,
    };
  }
}

class RelationshipEvolution {
  final String? description;
  final String? trend;

  RelationshipEvolution({this.description, this.trend});

  factory RelationshipEvolution.fromJson(Map<String, dynamic> json) {
    return RelationshipEvolution(
      description: json['description'] as String?,
      trend: json['trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'trend': trend,
    };
  }
}

class RiskFlag {
  final String? label;
  final String? description;

  RiskFlag({this.label, this.description});

  factory RiskFlag.fromJson(Map<String, dynamic> json) {
    return RiskFlag(
      label: json['label'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'description': description,
    };
  }
}
