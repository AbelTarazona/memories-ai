class MemoryNoteModel {
  final String memoryId;
  final String authorType; // "user" o "assistant"
  final String content;

  MemoryNoteModel({
    required this.memoryId,
    required this.authorType,
    required this.content,
  });

  factory MemoryNoteModel.fromJson(Map<String, dynamic> json) {
    return MemoryNoteModel(
      memoryId: json['memory_id'] as String,
      authorType: json['author_type'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memory_id': memoryId,
      'author_type': authorType,
      'content': content,
    };
  }
}