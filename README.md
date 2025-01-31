# `langchain_fllama`

A bridge between [Fllama](https://github.com/Telosnex/fllama/) (a [`llama.cpp`](https://github.com/ggerganov/llama.cpp) for Flutter) and [Langchain for Dart](https://pub.dev/packages/langchain). You can easily run inference from any `.gguf` model on-device and create powerful pipelines with Langchain.

## Roadmap

- [x] Use `ChatFllama` for chat-based models
- [x] Run inference on-device with any `.gguf` model
- [x] Tool calling support
- [ ] Tool results support *(right now the `ToolMessage` is not supported, you can't provide output for tool calls back to the models)*
- [ ] The ability to offload the model from RAM when not in use
- [ ] Support for image inputs
- [ ] Output formatting support (e.g. output only in JSON) *(right now can only be achieved through tool calling)*
- [ ] Docstrings for all classes and methods

## Usage

You can use the chat version:

```dart
final chat = ChatFllama(
    defaultOptions: ChatFllamaOptions(model: modelPath),
);

final prompt = ChatPromptValue([
    HumanChatMessage(
        content: ChatMessageContent.text('Remember the number 5123.'),
    ),
    AIChatMessage(
        content: 'Sure, I will remember the number.',
    ),
    HumanChatMessage(
        content: ChatMessageContent.text('What is the number?'),
    ),
]);

await for (final part in chat.stream(prompt)) {
    print(part);
}

// Output: The number is 5123.
```

With tool calling:

```dart
const weatherTool = ToolSpec(
    name: 'get_current_weather',
    description: 'Get the current weather in a given location',
    inputJsonSchema: {
    'type': 'object',
    'properties': {
        'location': {
        'type': 'string',
        'description': 'The city and state, e.g. San Francisco, CA',
        },
    },
    'required': ['location'],
    },
);

final chat = ChatFllama(
    defaultOptions: ChatFllamaOptions(
    model: modelPath,
    // This will enforce the model to use the tool(s)
    // It will not be able to output normal text, only tool calls
    tools: const [weatherTool],
    ),
);

final prompt =
    PromptValue.string('What\'s the weather in Leuven, Belgium?');

await for (final part in chat.stream(prompt)) {
    for (final call in part.output.toolCalls) {
        print('Tool call ${call.name} in ${call.arguments['location']}');
    }
}

// Output: Tool call get_current_weather in Leuven, Belgium
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
