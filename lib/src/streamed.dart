import 'dart:async';

import 'package:fllama/fllama_universal.dart';
import 'package:fllama/misc/openai.dart';
import 'package:fllama/misc/openai_tool.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_fllama/src/chat_models/chat_models.dart';

Stream<String> fllamaToLangchainChatStream(List<ChatMessage> input,
    {required ChatFllamaOptions? options}) async* {
  if (options == null) {
    throw ArgumentError.notNull('options');
  }

  final request = OpenAiRequest(
    contextSize: options.numCtx,
    maxTokens: options.maxTokens,
    modelPath: options.model!,
    numGpuLayers: options.numGpuLayers,
    frequencyPenalty: options.frequencyPenalty,
    presencePenalty: options.presencePenalty,
    temperature: options.temperature,
    topP: options.topP,
    tools: [
      for (final tool in options.tools ?? [])
        Tool(
          name: tool.name,
          description: tool.description,
          jsonSchema: tool.inputJsonSchema,
        ),
    ],
    messages: [
      for (final message in input)
        Message(
          switch (message) {
            AIChatMessage _ => Role.assistant,
            HumanChatMessage _ => Role.user,
            SystemChatMessage _ => Role.system,
            _ => throw ArgumentError.value(
                message,
                'message',
                'Unsupported message type',
              ),
          },
          message.contentAsString,
        ),
    ],
  );

  // Since fllamaInference gives us tokens directly,
  // we can use a broadcast controller to emit them as they come
  final controller = StreamController<String>.broadcast();
  String streamedText = '';

  fllamaChat(request, (response, done) {

    final delta = response.substring(streamedText.length);
    streamedText = response;
    controller.add(delta);

    if (done) {
      controller.close();
    }
  });

  yield* controller.stream;
}
