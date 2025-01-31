import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_core/tools.dart';
import 'package:langchain_fllama/langchain_fllama.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String generatedText = '...';
  String? modelPath;

  Future<void> generateText() async {
    if (modelPath == null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      modelPath = result.files.single.path!;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(generatedText),
            ElevatedButton(
              onPressed: generateText,
              child: const Text('Generate text'),
            ),
          ],
        ),
      ),
    );
  }
}
