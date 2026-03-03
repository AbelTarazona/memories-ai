class MemoryQuestionModel {
  final int id;
  final DateTime createdAt;
  final int memoryId;
  final String question;
  final bool answered;
  final String? userAnswer;
  final String? aiModel;
  final int version;

  MemoryQuestionModel({
    required this.id,
    required this.createdAt,
    required this.memoryId,
    required this.question,
    this.answered = false,
    this.userAnswer,
    this.aiModel = 'gpt-4o-mini',
    this.version = 1,
  });

  factory MemoryQuestionModel.fromMap(Map<String, dynamic> map) {
    return MemoryQuestionModel(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      memoryId: map['memory_id'] as int,
      question: map['question'] as String,
      answered: map['answered'] as bool? ?? false,
      userAnswer: map['user_answer'] as String?,
      aiModel: map['ai_model'] as String?,
      version: map['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memory_id': memoryId,
      'question': question,
      'answered': answered,
      'user_answer': userAnswer,
      'ai_model': aiModel,
      'version': version,
    };
  }

  MemoryQuestionModel copyWith({
    int? id,
    DateTime? createdAt,
    int? memoryId,
    String? question,
    bool? answered,
    String? userAnswer,
    String? aiModel,
    int? version,
  }) {
    return MemoryQuestionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      memoryId: memoryId ?? this.memoryId,
      question: question ?? this.question,
      answered: answered ?? this.answered,
      userAnswer: userAnswer ?? this.userAnswer,
      aiModel: aiModel ?? this.aiModel,
      version: version ?? this.version,
    );
  }
}
