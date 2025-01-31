import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/prompts.dart';
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
  String generatedText = '';
  String modelPath = '';

  Future<void> generateText() async {
    if (modelPath.isEmpty) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      modelPath = result.files.single.path!;
    }

    generatedText = '';

    final chat =
        ChatFllama(defaultOptions: ChatFllamaOptions(model: modelPath));
    final prompt = ChatPromptValue([
      HumanChatMessage(
        content: ChatMessageContent.text('Remember the number 5123.'),
      ),
      const AIChatMessage(content: 'Okay, I will remember the number.'),
      HumanChatMessage(content: ChatMessageContent.text('What is the number?')),
    ]);
    chat.stream(prompt).listen((event) {
      setState(() => generatedText += event.output.content);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: generateText,
              child: const Text('Generate text'),
            ),
            Text(generatedText),
          ],
        ),
      ),
    );
  }
}
