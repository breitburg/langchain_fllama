import 'dart:async';
import 'dart:convert';

import 'package:fllama/fllama.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/llms.dart';
import 'package:langchain_fllama/src/chat_models/chat_models.dart';
import 'package:langchain_fllama/src/common.dart';

Stream<ChatResult> fllamaToLangchainChatStream(List<ChatMessage> input,
    {required ChatFllamaOptions? options}) async* {
  if (options == null) {
    throw ArgumentError.notNull('options');
  }

  if (options.toolChoice != null) {
    throw ArgumentError.value(
      options.toolChoice,
      'options.toolChoice',
      'Tool choice is not supported in Fllama',
    );
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
          jsonSchema: jsonEncode(tool.inputJsonSchema),
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
  var streamedText = '';

  final requestId = await fllamaChat(request, (response, done) {
    if (done) controller.close();
    if (controller.isClosed) return;

    final delta = response.substring(streamedText.length);
    streamedText = response;

    controller.add(delta);
  });

  // Cancel the request if the stream is closed
  // controller.onCancel = () => fllamaCancelInference(requestId);

  yield* controller.stream.map((content) {
    final toolCalls = <AIChatMessageToolCall>[];

    try {
      final parsed = jsonDecode(streamedText) as Map<String, dynamic>;

      if (parsed.containsKey('name') && parsed.containsKey('parameters')) {
        for (final tool in options.tools ?? []) {
          if (tool.name != parsed['name']) continue;

          toolCalls.add(
            AIChatMessageToolCall(
              id: uuid.v4(),
              name: parsed['name'],
              argumentsRaw: jsonEncode(parsed['parameters']),
              arguments: parsed['parameters'],
            ),
          );
          break;
        }
      }
    } catch (e) {}

    return ChatResult(
      id: uuid.v4(),
      output: AIChatMessage(
        content: content,
        toolCalls: toolCalls,
      ),
      finishReason: FinishReason.unspecified,
      metadata: {
        'model': options.model,
        'frequencyPenalty': options.frequencyPenalty,
        'presencePenalty': options.presencePenalty,
        'temperature': options.temperature,
        'topP': options.topP,
        'numGpuLayers': options.numGpuLayers,
        'numCtx': options.numCtx,
        'maxTokens': options.maxTokens,
      },
      usage: const LanguageModelUsage(),
      streaming: true,
    );
  });
}

extension ToLLMResult on ChatResult {
  LLMResult toLLMResult() {
    return LLMResult(
      id: id,
      output: outputAsString,
      finishReason: finishReason,
      metadata: metadata,
      usage: usage,
    );
  }
}
