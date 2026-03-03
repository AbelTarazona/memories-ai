import 'package:memories/core/helpers/person_enrich/fuzzy_person_matcher.dart';
import 'package:memories/core/helpers/person_enrich/person_description_builder.dart';
import 'package:memories/core/helpers/person_enrich/person_matcher.dart';
import 'package:memories/data/models/people_model.dart';

class MomentEnricher {
  final PersonMatcher _matcher;
  final PersonDescriptionBuilder _descBuilder;

  const MomentEnricher({
    PersonMatcher? matcher,
    PersonDescriptionBuilder? descriptionBuilder,
  }) : _matcher = matcher ?? const _DefaultMatcher(),
       _descBuilder = descriptionBuilder ?? const PersonDescriptionBuilder();

  /// Enriquecer un texto reemplazando nombres por "Nombre (desc)".
  /// - Busca match exacto o fuzzy.
  /// - Respeta `consentGenerate`; si no hay match o sin consentimiento, usa rol genérico.
  String enrich({
    required String mainMoment,
    // Personas encontradas en la memoria (nombres tal cual en el texto)
    required List<String> people,
    // Mapa de nombre de persona a su rol en la memoria
    required Map<String, String> peopleRoles,
    // Lista de personas conocidas en la BD para hacer matching
    required List<PeopleModel> peopleList,
    double similarityThreshold = 0.8,
  }) {
    var enriched = mainMoment;

    for (final personName in people) {
      final match = _matcher.findMatchingPerson(
        personName,
        peopleList,
        similarityThreshold: similarityThreshold,
      );

      if (match != null && match.consentGenerate) {
        final desc = _descBuilder.build(
          match,
          role: peopleRoles[personName],
        );

        enriched = enriched.replaceAll(
          RegExp('\\b${RegExp.escape(personName)}\\b', caseSensitive: false),
          '$personName ($desc)',
        );
      } else {
        // Fallback genérico basado en rol
        final roleDesc = peopleRoles[personName] ?? 'persona';
        enriched = enriched.replaceAll(
          RegExp('\\b${RegExp.escape(personName)}\\b', caseSensitive: false),
          '$personName ($roleDesc)',
        );
      }
    }

    return enriched;
  }
}

class _DefaultMatcher extends FuzzyPersonMatcher {
  const _DefaultMatcher();
}
