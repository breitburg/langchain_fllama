import 'dart:async';

import 'package:langchain_core/llms.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_fllama/langchain_fllama.dart';
import 'package:langchain_fllama/src/streamed.dart';
import 'package:langchain_tiktoken/langchain_tiktoken.dart';

class Fllama extends BaseLLM<FllamaOptions> {
  Fllama({
    required super.defaultOptions,
    final Map<String, String>? headers,
    final Map<String, dynamic>? queryParams,
    this.encoding = 'cl100k_base',
  });

  /// The encoding to use by tiktoken when [tokenize] is called.
  ///
  /// Fllama does not provide any API to count tokens, so we use tiktoken
  /// to get an estimation of the number of tokens in a prompt.
  String encoding;

  @override
  String get modelType => 'fllama';

  @override
  Future<LLMResult> invoke(
    final PromptValue input, {
    final FllamaOptions? options,
  }) async {
    return await fllamaToLangchainChatStream(
      input.toChatMessages(),
      options: ChatFllamaOptions.fromLLMOptions(options ?? defaultOptions),
    ).map((final result) => result.toLLMResult()).reduce(
          (previousValue, element) => previousValue.concat(element),
        );
  }

  @override
  Stream<LLMResult> stream(
    final PromptValue input, {
    final FllamaOptions? options,
  }) {
    return fllamaToLangchainChatStream(
      input.toChatMessages(),
      options: ChatFllamaOptions.fromLLMOptions(options ?? defaultOptions),
    ).map((final result) => result.toLLMResult());
  }

  /// Tokenizes the given prompt using tiktoken.
  ///
  /// Currently Fllama does not provide a tokenizer for the models it supports.
  /// So we use tiktoken and [encoding] model to get an approximation
  /// for counting tokens. Mind that the actual tokens will be totally
  /// different from the ones used by the Fllama model.
  ///
  /// If an encoding model is specified in [encoding] field, that
  /// encoding is used instead.
  ///
  /// - [promptValue] The prompt to tokenize.
  @override
  Future<List<int>> tokenize(
    final PromptValue promptValue, {
    final FllamaOptions? options,
  }) async {
    final encoding = getEncoding(this.encoding);
    return encoding.encode(promptValue.toString());
  }
}
