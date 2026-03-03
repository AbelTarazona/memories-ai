class AppConstants {
  static const List<String> memoryTitleAnalyzer = [
    'Memories AI está procesando tu recuerdo...',
    'Estamos preparando algo especial con tu memoria...',
    'Analizando tu recuerdo para mostrarte algo único...',
  ];

  static String randomMemoryTitle() {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % memoryTitleAnalyzer.length;
    return memoryTitleAnalyzer[randomIndex];
  }
}
