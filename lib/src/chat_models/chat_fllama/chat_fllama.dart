import 'dart:async';

import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_fllama/src/chat_models/chat_models.dart';
import 'package:langchain_fllama/src/streamed.dart';
import 'package:langchain_tiktoken/langchain_tiktoken.dart';
import 'package:uuid/uuid.dart';

class ChatFllama extends BaseChatModel<ChatFllamaOptions> {
  ChatFllama({
    required super.defaultOptions,
    final Map<String, String>? headers,
    final Map<String, dynamic>? queryParams,
    this.encoding = 'cl100k_base',
  });

  /// The encoding to use by tiktoken when [tokenize] is called.
  ///
  /// ChatFllama does not provide any API to count tokens, so we use tiktoken
  /// to get an estimation of the number of tokens in a prompt.
  String encoding;

  @override
  String get modelType => 'fllama';

  /// A UUID generator.
  late final Uuid _uuid = const Uuid();

  @override
  Future<ChatResult> invoke(
    final PromptValue input, {
    final ChatFllamaOptions? options,
  }) async {
    return ChatResult(
      id: _uuid.v4(),
      output: AIChatMessage(
        content: await fllamaToLangchainChatStream(
          input.toChatMessages(),
          options: options ?? defaultOptions,
        ).join(),
      ),
      finishReason: FinishReason.unspecified,
      metadata: const {},
      usage: const LanguageModelUsage(),
    );
  }

  @override
  Stream<ChatResult> stream(
    final PromptValue input, {
    final ChatFllamaOptions? options,
  }) {
    return fllamaToLangchainChatStream(
      input.toChatMessages(),
      options: options ?? defaultOptions,
    ).map(
      (output) => ChatResult(
        id: _uuid.v4(),
        output: AIChatMessage(content: output),
        finishReason: FinishReason.unspecified,
        metadata: const {},
        usage: const LanguageModelUsage(),
      ),
    );
  }

  /// Tokenizes the given prompt using tiktoken.
  ///
  /// Currently ChatFllama does not provide a tokenizer for the models it supports.
  /// So we use tiktoken and [encoding] model to get an approximation
  /// for counting tokens. Mind that the actual tokens will be totally
  /// different from the ones used by the ChatFllama model.
  ///
  /// If an encoding model is specified in [encoding] field, that
  /// encoding is used instead.
  ///
  /// - [promptValue] The prompt to tokenize.
  @override
  Future<List<int>> tokenize(
    final PromptValue promptValue, {
    final ChatFllamaOptions? options,
  }) async {
    final encoding = getEncoding(this.encoding);
    return encoding.encode(promptValue.toString());
  }

  @override
  void close() {
    // TODO: Somehow offload the model from RAM.
  }
}
