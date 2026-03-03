import 'dart:convert';

class OpenAiHelper {
  static String? extractOutputText(dynamic responseData) {
    Map<String, dynamic> root;

    // Maneja tanto String como Map
    if (responseData is String) {
      root = jsonDecode(responseData) as Map<String, dynamic>;
    } else if (responseData is Map<String, dynamic>) {
      root = responseData;
    } else {
      return null;
    }

    final outputs = root['output'] as List<dynamic>?;
    if (outputs == null) return null;

    for (final item in outputs) {
      final map = item as Map<String, dynamic>;
      if (map['type'] == 'message') {
        final content = map['content'] as List<dynamic>?;
        if (content == null) continue;

        for (final c in content) {
          final cm = c as Map<String, dynamic>;
          if (cm['type'] == 'output_text') {
            final text = cm['text'];
            if (text is String) return text;
          }
        }
      }
    }
    return null;
  }

  static decodeBase64Image(b64json) {
    return base64Decode(b64json);
  }
}
