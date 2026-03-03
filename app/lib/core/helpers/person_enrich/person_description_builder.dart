import 'package:memories/data/models/people_model.dart';

class PersonDescriptionBuilder {
  const PersonDescriptionBuilder();

  /// Construye una descripción corta basada en rasgos y rol (si aplica).
  String build(PeopleModel person, {String? role}) {
    final traits = person.traits;
    final parts = <String>[];

    if (person.ageRange != null && person.ageRange!.trim().isNotEmpty) {
      parts.add('${person.ageRange}');
    }
    if (person.gender != null && person.gender!.trim().isNotEmpty) {
      parts.add(person.gender!.toLowerCase());
    }
    if (traits.skinTone != null && traits.skinTone!.trim().isNotEmpty) {
      parts.add('piel ${traits.skinTone}');
    }
    if ((traits.hairColor != null && traits.hairColor!.trim().isNotEmpty) &&
        (traits.hairLength != null && traits.hairLength!.trim().isNotEmpty)) {
      parts.add('cabello ${traits.hairLength} ${traits.hairColor}');
    }
    if (traits.fashionStyle != null && traits.fashionStyle!.isNotEmpty) {
      parts.add('estilo ${traits.fashionStyle!.join(", ")}');
    }
    if (role != null && role.trim().isNotEmpty) {
      parts.add(role.trim());
    }

    return parts.join(', ');
  }
}
