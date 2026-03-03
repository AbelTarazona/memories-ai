import 'package:memories/data/models/person_traits_model.dart';

class PeopleModel {
  final String id;
  final String ownerUserId;
  final String displayName;
  final String? alias;
  final String? gender;
  final String? ageRange;
  final double? heightCm;
  final PersonTraitsModel traits;
  final bool consentGenerate;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSelf;

  PeopleModel({
    required this.id,
    required this.ownerUserId,
    required this.displayName,
    this.alias,
    this.gender,
    this.ageRange,
    this.heightCm,
    required this.traits,
    required this.consentGenerate,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
    required this.isSelf,
  });

  factory PeopleModel.fromJson(Map<String, dynamic> json) {
    return PeopleModel(
      id: json['id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      displayName: json['display_name'] as String,
      alias: json['alias'] as String?,
      gender: json['gender'] as String?,
      ageRange: json['age_range'] as String?,
      heightCm: json['height_cm'] != null ? (json['height_cm'] as num).toDouble() : null,
      traits: PersonTraitsModel.fromMap(json['traits'] as Map<String, dynamic>),
      consentGenerate: json['consent_generate'] as bool,
      visibility: json['visibility'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSelf: json['is_self'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'display_name': displayName,
      'alias': alias,
      'gender': gender,
      'age_range': ageRange,
      'height_cm': heightCm,
      'traits': traits,
      'consent_generate': consentGenerate,
      'visibility': visibility,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_self': isSelf,
    };
  }

  String get genderEmoji {
    switch (gender?.toLowerCase()) {
      case 'male':
        return '👨';
      case 'female':
        return '👩';
      case 'nonbinary':
        return '🧑';
      case 'unspecified':
        return '🧑‍🦱';
      default:
        return '❓';
    }
  }

  @override
  String toString() {
    return 'PeopleModel{displayName: $displayName, alias: $alias, gender: $gender, ageRange: $ageRange, heightCm: $heightCm, traits: $traits, isSelf: $isSelf}';
  }
}
