import 'dart:convert';
import 'package:langchain/langchain.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

Tool createSearchMemoriesTool(ISupabaseRepository repository) {
  return Tool.fromFunction<Map<String, dynamic>, String>(
    name: 'search_memories',
    description:
        'Busca memorias y recuerdos en la base de datos del usuario. '
        'Usa esta herramienta SIEMPRE que necesites obtener contexto histórico sobre las memorias o temas que el usuario está mencionando.',
    inputJsonSchema: const {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description':
              'Términos de búsqueda. Deben ser las palabras clave principales del mensaje del usuario.',
        },
      },
      'required': ['query'],
    },
    func: (final Map<String, dynamic> toolInput) async {
      final query = toolInput['query'] as String;
      final res = await repository.searchMemories(query: query);

      return res.match(
        (failure) => 'Error obteniendo memorias: \${failure.message}',
        (memories) {
          if (memories.isEmpty) {
            return 'No se encontraron recuerdos relevantes sobre "\$query".';
          }
          final list = memories.map((m) => m.toJson()).toList();
          return jsonEncode(list);
        },
      );
    },
  );
}
