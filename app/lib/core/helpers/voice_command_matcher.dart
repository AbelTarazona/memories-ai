import 'package:fuzzywuzzy/fuzzywuzzy.dart';

/// Utilidad para hacer matching del comando de voz con fuzzy matching
class VoiceCommandMatcher {
  // Comandos válidos que se aceptarán
  static const List<String> validCommands = [
    'memoris quiero contarte algo',
    'memories quiero contarte algo',
    'memoris quiero contarte una cosa',
  ];

  // Umbral de similitud (0-100)
  static const int similarityThreshold = 80;

  /// Verifica si el texto reconocido coincide con algún comando válido
  /// Retorna true si encuentra una coincidencia con suficiente similitud
  static bool matchesCommand(String recognizedText) {
    if (recognizedText.isEmpty) return false;

    // Normalizar el texto: lowercase y trim
    final normalizedText = _normalizeText(recognizedText);

    // Verificar coincidencia exacta primero
    for (final command in validCommands) {
      if (normalizedText == _normalizeText(command)) {
        return true;
      }
    }

    // Usar fuzzy matching para permitir variaciones
    for (final command in validCommands) {
      final similarity = ratio(normalizedText, _normalizeText(command));
      if (similarity >= similarityThreshold) {
        return true;
      }
    }

    return false;
  }

  /// Normaliza el texto eliminando caracteres especiales y convirtiendo a lowercase
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        // Remover signos de puntuación comunes
        .replaceAll(RegExp(r'[.,!?¿¡]'), '')
        // Normalizar espacios múltiples a uno solo
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Obtiene el ratio de similitud entre el texto reconocido y el mejor comando
  /// Útil para debugging y logs
  static int getBestMatchRatio(String recognizedText) {
    if (recognizedText.isEmpty) return 0;

    final normalizedText = _normalizeText(recognizedText);
    int bestSimilarity = 0;

    for (final command in validCommands) {
      final currentSimilarity = ratio(normalizedText, _normalizeText(command));
      if (currentSimilarity > bestSimilarity) {
        bestSimilarity = currentSimilarity;
      }
    }

    return bestSimilarity;
  }
}
