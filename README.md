# `langchain_fllama`

A bridge between [Fllama](https://github.com/Telosnex/fllama/) (a [`llama.cpp`](https://github.com/ggerganov/llama.cpp) for Flutter) and [Langchain for Dart](https://pub.dev/packages/langchain). You can easily run inference from any `.gguf` model on-device and create powerful pipelines with Langchain.

## Roadmap

- [x] Use both the regular `Fllama` and `ChatFllama` versions within pipelines
- [x] Run inference on-device with any `.gguf` model
- [x] Tool calling support
- [ ] Tool results support *(right now the `ToolMessage` is not supported, you can't provide output for tool calls back to the models)*
- [ ] The ability to offload the model from RAM when not in use
- [ ] Support for multi-modal models
- [ ] Output formatting support (e.g. output only in JSON)
- [ ] Docstrings for all classes and methods

## Usage

You can use both the regular version:

```dart
final llm = Fllama(
    defaultOptions: FllamaOptions(model: modelPath),
);
final prompt = PromptValue.string('Write a story about llamas');
final response = llm.invoke(prompt);

print(response);
```

Or the chat version:

```dart
final chat = ChatFllama(
    defaultOptions: ChatFllamaOptions(model: modelPath),
);

final prompt = ChatPromptValue([
    HumanChatMessage(
        content: ChatMessageContent.text('Remember the number 5123.'),
    ),
    const AIChatMessage(
        content: 'Okay, I will remember the number.',
    ),
    HumanChatMessage(
        content: ChatMessageContent.text('What is the number?'),
    ),
]);

await for (final part in chat.stream(prompt)) {
    print(part);
}
```

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  langchain_fllama:
    git:
      url: https://github.com/breitburg/langchain_fllama
      ref: main
```

Unfortunately, it's not possible to publish this package to pub.dev, as it's a bridge to a native library.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Telosnex](https://github.com/Telosnex) for creating Fllama
- [Ggerganov](https://github.com/ggerganov) for creating `llama.cpp`
- [davidmigloz](https://github.com/davidmigloz) for porting Langchain for Dart

## Contributing

Feel free to contribute to this project by creating a pull request. Make sure to follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
