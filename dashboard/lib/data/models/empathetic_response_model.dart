import 'package:memories_web_admin/data/models/memory_notes_model.dart';

class EmpatheticResponseModel {
  final String response;
  final List<String> ids;
  final String action; // "continue", "switch", "end"
  final List<MemoryNoteModel> memoryNotes;

  EmpatheticResponseModel({
    required this.response,
    required this.ids,
    required this.action,
    this.memoryNotes = const [],
  });

  bool get isContinue => action == 'continue';
  bool get isSwitch => action == 'switch';
  bool get isEnd => action == 'end';

  /// Backward compatibility
  bool get expectsFollowup => isContinue;

  factory EmpatheticResponseModel.fromJson(Map<String, dynamic> json) {
    // Support both old "expects_followup" and new "action" field
    String resolvedAction;
    if (json.containsKey('action')) {
      resolvedAction = json['action'] as String;
    } else if (json.containsKey('expects_followup')) {
      resolvedAction = (json['expects_followup'] as bool) ? 'continue' : 'end';
    } else {
      resolvedAction = 'end';
    }

    return EmpatheticResponseModel(
      response: json['response'] as String,
      ids: List<String>.from(json['memory_ids'] as List<dynamic>),
      action: resolvedAction,
      memoryNotes: json.containsKey('memory_notes')
          ? (json['memory_notes'] as List<dynamic>)
                .map((e) => MemoryNoteModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }
}
