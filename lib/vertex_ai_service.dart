import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:vertexai_walkthrough/file_picker_service.dart';
import 'package:vertexai_walkthrough/prompts.dart';

enum QueryType { text, media }

class VertexAIService {
  late GenerativeModel _model;
  late GenerativeModel _functionModel;
  init() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-pro-preview-0409',
    );
    _functionModel = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-pro-preview-0409',
      tools: [
        Tool(functionDeclarations: [Prompts.ingredientParsingSchema]),
      ],
    );
  }

  final ValueNotifier<bool> loading = ValueNotifier(false);

  Future<String> uploadMedia(CustomFile file) async {
    final data = await file.file.readAsBytes();

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("vertexai/${file.name}");
    await imageRef.putData(data);

    final bucket = imageRef.bucket;
    final fullPath = imageRef.fullPath;
    final storageUrl = 'gs://$bucket/$fullPath';
    log('storageUrl: $storageUrl');
    return storageUrl;
  }

  Future<void> generateContent({
    String? message,
    CustomFile? image,
    QueryType type = QueryType.text,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      GenerateContentResponse response;
      if (type == QueryType.text && message != null) {
        var prompt = Prompts.ingredient;

        response = await _functionModel.generateContent(
          [Content.text('$prompt\n$message')],
        );

        _onResponse(
          response,
          onSuccess: onSuccess,
          onError: onError,
          isFunction: false,
        );
      } else {
        final storageRef = await uploadMedia(image!);
        final filePart = FileData(image.mimeType, storageRef);
        TextPart prompt;
        if (image.type == XFileType.audio) {
          prompt = TextPart(Prompts.audio);
        } else if (image.type == XFileType.image) {
          prompt = TextPart(Prompts.image);
        } else {
          prompt = TextPart(Prompts.other);
        }

        response = await _model.generateContent([
          Content.multi([prompt, filePart]),
        ], generationConfig: GenerationConfig());
        _onResponse(
          response,
          onSuccess: onSuccess,
          onError: onError,
          isFunction: true,
        );
      }
    } catch (e) {
      onError(e.toString());
      _setLoading(false);
    } finally {
      _setLoading(false);
    }
  }

  void _onResponse(
    GenerateContentResponse response, {
    bool isFunction = false,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    String? text;
    if (isFunction) {
      log('response: ${response.text}');
      text = response.text;
    } else {
      log(response.functionCalls.map((e) => ' ${e.args} ').join('\n'));
      text =
          response.functionCalls.map((e) => '${e.args}').join('\n').toString();
      text = "```json\n$text\n```";
    }

    _setLoading(false);
    if (text == null) {
      onError('No response from API.');
      return;
    } else {
      onSuccess(text);
    }
  }

  void _setLoading(bool value) => loading.value = value;
}
