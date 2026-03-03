class PersonTraitsModel {
  final String? notes;
  final String? skinTone;
  final String? skinUndertone;
  final String? eyeColor;
  final String? hairColor;
  final String? hairLength;
  final String? hairTexture;
  final String? facialHair;
  final String? glasses;
  final String? freckles;
  final String? tattoos;
  final String? bodyType;
  final List<String>? fashionStyle;
  final List<String>? distinctiveMarks;

  const PersonTraitsModel({
    this.notes,
    this.skinTone,
    this.skinUndertone,
    this.eyeColor,
    this.hairColor,
    this.hairLength,
    this.hairTexture,
    this.facialHair,
    this.glasses,
    this.freckles,
    this.tattoos,
    this.bodyType,
    this.fashionStyle = const [],
    this.distinctiveMarks = const [],
  });

  PersonTraitsModel copyWith({
    String? notes,
    String? skinTone,
    String? skinUndertone,
    String? eyeColor,
    String? hairColor,
    String? hairLength,
    String? hairTexture,
    String? facialHair,
    String? glasses,
    String? freckles,
    String? tattoos,
    String? bodyType,
    List<String>? fashionStyle,
    List<String>? distinctiveMarks,
  }) {
    return PersonTraitsModel(
      notes: notes ?? this.notes,
      skinTone: skinTone ?? this.skinTone,
      skinUndertone: skinUndertone ?? this.skinUndertone,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      hairLength: hairLength ?? this.hairLength,
      hairTexture: hairTexture ?? this.hairTexture,
      facialHair: facialHair ?? this.facialHair,
      glasses: glasses ?? this.glasses,
      freckles: freckles ?? this.freckles,
      tattoos: tattoos ?? this.tattoos,
      bodyType: bodyType ?? this.bodyType,
      fashionStyle: fashionStyle ?? this.fashionStyle,
      distinctiveMarks: distinctiveMarks ?? this.distinctiveMarks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notes': notes,
      'skin_tone': skinTone,
      'skin_undertone': skinUndertone,
      'eye_color': eyeColor,
      'hair_color': hairColor,
      'hair_length': hairLength,
      'hair_texture': hairTexture,
      'facial_hair': facialHair,
      'glasses': glasses,
      'freckles': freckles,
      'tattoos': tattoos,
      'body_type': bodyType,
      'fashion_style': fashionStyle,
      'distinctive_marks': distinctiveMarks,
    }..removeWhere((key, value) => value == null);
  }

  factory PersonTraitsModel.fromMap(Map<String, dynamic> map) {
    return PersonTraitsModel(
      notes: map['notes'] as String?,
      skinTone: map['skin_tone'] as String?,
      skinUndertone: map['skin_undertone'] as String?,
      eyeColor: map['eye_color'] as String?,
      hairColor: map['hair_color'] as String?,
      hairLength: map['hair_length'] as String?,
      hairTexture: map['hair_texture'] as String?,
      facialHair: map['facial_hair'] as String?,
      glasses: map['glasses'] as String?,
      freckles: map['freckles'] as String?,
      tattoos: map['tattoos'] as String?,
      bodyType: map['body_type'] as String?,
      fashionStyle: (map['fashion_style'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      distinctiveMarks: (map['distinctive_marks'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
