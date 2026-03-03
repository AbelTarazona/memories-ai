import 'dart:math';

import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:memories/core/helpers/person_enrich/person_matcher.dart';
import 'package:memories/data/models/people_model.dart';

class FuzzyPersonMatcher implements PersonMatcher {
  const FuzzyPersonMatcher();

  /// Usa fuzzywuzzy (ratio/partialRatio/tokenSetRatio) y se queda con el mejor score.
  /// similarityThreshold se expresa 0..1 y se convierte a 0..100.
  @override
  PeopleModel? findMatchingPerson(
    String personName,
    List<PeopleModel> peopleList, {
    double similarityThreshold = 0.8,
  }) {
    final normalized = personName.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    // 1) Coincidencia exacta (case-insensitive) con displayName o alias
    for (final p in peopleList) {
      if (p.displayName.toLowerCase() == normalized || (p.alias?.toLowerCase() == normalized)) {
        return p;
      }
    }

    // 2) Coincidencia difusa con fuzzywuzzy
    final int threshold = (similarityThreshold * 100).round();

    PeopleModel? bestMatch;
    int bestScore = -1;

    for (final p in peopleList) {
      final candidates = <String>[
        p.displayName,
        if (p.alias != null && p.alias!.trim().isNotEmpty) p.alias!,
      ];

      for (final candidate in candidates) {
        final c = candidate.toLowerCase();

        // Escoge el mejor de varios métodos
        final scores = <int>[
          ratio(normalized, c),
          partialRatio(normalized, c),
          tokenSetRatio(normalized, c),
        ];

        final candidateScore = scores.reduce(max);

        if (candidateScore >= threshold && candidateScore > bestScore) {
          bestScore = candidateScore;
          bestMatch = p;
        }
      }
    }

    return bestMatch;
  }
}
