# langchain_fllama

A bridge between [Fllama](https://github.com/Telosnex/fllama/) and [Langchain for Dart](https://pub.dev/packages/langchain). This package enables on-device inference with any `.gguf` model and allows you to create powerful pipelines using Langchain. Fllama is built on [`llama.cpp`](https://github.com/ggerganov/llama.cpp), bringing its capabilities to Flutter applications.

## Roadmap

- [x] Run inference on-device with any `.gguf` model
- [x] Use `ChatFllama` for chat-based models
- [x] Tool calling support
- [ ] Pass tool call output back to the model
- [ ] Manual control for model loading/unloading
- [ ] Support for image inputs
- [ ] Output formatting support (e.g. JSON)

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  langchain_fllama:
    git:
      url: https://github.com/breitburg/langchain_fllama
      ref: main
```

Note: This package cannot be published to pub.dev as it relies on native library bindings.

## Usage

### Basic Example

First, obtain a `.gguf` model. You can find compatible models on [Hugging Face Hub](https://huggingface.co/models). For a complete list of supported models, refer to the [`llama.cpp` README](https://github.com/ggerganov/llama.cpp#text-only).

You can load models in several ways:
- Download at runtime and save to the device (e.g., in the cache directory using `path_provider`)
- Let users select models from their device using `file_picker`

```dart
final modelPath = 'path/to/model.gguf';

final chat = ChatFllama(
    defaultOptions: ChatFllamaOptions(model: modelPath),
);

final prompt = PromptValue.string('What is the capital of France?');

final response = await chat.invoke(prompt);
print(response.outputAsString);
// Output: Paris
```

### Streaming and Multi-message Prompts

```dart
final modelPath = 'path/to/model.gguf';

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
    print(part.outputAsString);
}
// Output: The number is 5123.
```

### Tool Integration

```dart
final modelPath = 'path/to/model.gguf';

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
        tools: const [weatherTool],
    ),
);

final prompt = PromptValue.string('What\'s the weather in Leuven, Belgium?');

final response = await chat.invoke(prompt);

for (final call in response.output.toolCalls) {
    print('Tool call ${call.name} in ${call.arguments['location']}');
}
// Output: Tool call get_current_weather in Leuven, Belgium
```

Note: While streaming with tools is supported, it's recommended to use the `invoke` method when implementing tool calls. The tool call JSON will initially appear as regular text in the output stream until the model completes generating the JSON.

## Contributing

Contributions are welcome! Please follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification when creating pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Telosnex](https://github.com/Telosnex) - Creator of Fllama
- [Ggerganov](https://github.com/ggerganov) - Creator of `llama.cpp`
- [davidmigloz](https://github.com/davidmigloz) - Creator of Langchain for Dart