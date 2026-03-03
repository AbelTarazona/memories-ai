import 'package:memories/data/models/ai_memory_model.dart';

class MemoryAnalysisResult {
  final AiMemoryModel aiMemory;
  final String imagePrompt;

  MemoryAnalysisResult({
    required this.aiMemory,
    required this.imagePrompt,
  });
}
