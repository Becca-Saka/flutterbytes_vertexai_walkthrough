// import 'package:flutter/material.dart';

// void main() {
//   runApp(const GenerativeAISample());
// }

// class GenerativeAISample extends StatelessWidget {
//   const GenerativeAISample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter + Vertex AI',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           brightness: Brightness.dark,
//           seedColor: const Color.fromARGB(255, 171, 222, 244),
//         ),
//         useMaterial3: true,
//       ),
//       home: const MainApp(),
//     );
//   }
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Flutter + Vertex AI')),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: () {},
//             child: const Text(
//               'PickFile',
//             ),
//           ),
//           const SizedBox(),
//         ],
//       ),
//     );
//   }
// }
// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vertexai_walkthrough/file_picker_service.dart';
import 'package:vertexai_walkthrough/firebase_options.dart';
import 'package:vertexai_walkthrough/vertex_ai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Vertex AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(title: 'Flutter + Vertex AI'),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const ChatWidget(),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, CustomFile? file, String? text, bool fromUser})>
      _generatedContent =
      <({Image? image, CustomFile? file, String? text, bool fromUser})>[];
  VertexAIService vertexAIService = VertexAIService();
  FilePickerService filePickerService = FilePickerService();
  bool get _loading => vertexAIService.loading.value;
  @override
  void initState() {
    super.initState();
    vertexAIService.init();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, idx) {
                var content = _generatedContent[idx];
                return MessageWidget(
                  customFile: content.file,
                  text: content.text,
                  image: content.image,
                  isFromUser: content.fromUser,
                );
              },
              itemCount: _generatedContent.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    decoration: textFieldDecoration,
                    controller: _textController,
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                const SizedBox.square(
                  dimension: 15,
                ),
                IconButton(
                  tooltip: 'media prompt',
                  onPressed: !_loading
                      ? () async {
                          await _sendMediaMessage();
                        }
                      : null,
                  icon: Icon(
                    Icons.folder,
                    color: _loading
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (!_loading)
                  IconButton(
                    onPressed: () async {
                      _sendChatMessage(_textController.text);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMediaMessage() async {
    final files = await filePickerService.pickFile();
    if (files != null && files.isNotEmpty) {
      final first = files.first;
      if (first.type == XFileType.image) {
        final image = Image.file(File(files.first.path));
        _generatedContent.add((
          image: image,
          file: null,
          text: null,
          fromUser: true,
        ));
      } else if (first.type == XFileType.pdf || first.type == XFileType.audio) {
        _generatedContent.add((
          image: null,
          file: first,
          text: null,
          fromUser: true,
        ));
      }
      setState(() {});

      vertexAIService.generateContent(
        image: first,
        onSuccess: (result) {
          setState(() {
            _generatedContent
                .add((image: null, file: null, text: result, fromUser: false));

            _scrollDown();
          });
        },
        onError: (message) {
          _showError(message);
        },
      );
    }
  }

  void _sendChatMessage(String value) {
    _generatedContent.add((
      image: null,
      file: null,
      text: value,
      fromUser: true,
    ));
    setState(() {});
    _textController.clear();
    vertexAIService.generateContent(
      message: value,
      onSuccess: (result) {
        setState(() {
          _generatedContent.add((
            image: null,
            file: null,
            text: result,
            fromUser: false,
          ));

          _scrollDown();
        });
      },
      onError: (message) {
        _showError(message);
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  final Image? image;
  final CustomFile? customFile;
  final String? text;
  final bool isFromUser;

  const MessageWidget({
    super.key,
    this.image,
    this.customFile,
    this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                if (text case final text?) MarkdownBody(data: text),
                if (image case final image?)
                  SizedBox(height: 200, width: 200, child: image),
                if (customFile case final customFile?) Text(customFile.name),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
