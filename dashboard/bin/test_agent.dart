import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:memories_web_admin/core/app_prompts.dart';

void main() async {
  final llm = ChatOpenAI(apiKey: 'dummy');
  final tool = Tool.fromFunction<Map<String, dynamic>, String>(
    name: 'search_memories',
    description: 'search the DB',
    inputJsonSchema: const {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
        },
      },
    },
    func: (Map<String, dynamic> args) async => 'result',
  );

  final agent = ToolsAgent.fromLLMAndTools(
    llm: llm,
    tools: [tool],
    systemChatMessage: SystemChatMessagePromptTemplate.fromTemplate(
      AppPrompts.empatheticMemory,
    ),
  );

  final executor = AgentExecutor(agent: agent);

  try {
    await executor.invoke({'input': 'Hola'});
  } catch (e) {
    print('Invoke error: \$e');
  }
}
