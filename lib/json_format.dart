// // Copyright 2024 Google LLC
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //     http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.

// import 'dart:developer';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_vertexai/firebase_vertexai.dart';
// import 'package:vertexai_walkthrough/firebase_options.dart';

// class VertexAIService {
//   late final GenerativeModel _functionIngredientCallModel;

//   Future<void> initFirebase() async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   void init() {
//     initFirebase().then((value) {
//       _functionIngredientCallModel = FirebaseVertexAI.instance.generativeModel(
//         model: 'gemini-1.5-pro-preview-0409',
//         tools: [
//           Tool(functionDeclarations: [ingredientPArsingSchema]),
//         ],
//       );
//     });
//   }

//   final ingredientPArsingSchema = FunctionDeclaration(
//     'findIngredient',
//     'Parses an ingredient string and returns the name and quantity.',
//     Schema(
//       SchemaType.object,
//       properties: {
//         'ingredientName': Schema(
//           SchemaType.string,
//           description: 'The name of the ingredient as a string',
//         ),
//         'quantity': Schema(
//           SchemaType.number,
//           description:
//               'The quantity of the ingredient in a interger or fraction',
//         ),
//         'unit': Schema(
//           SchemaType.string,
//           nullable: true,
//           description:
//               'The unit of the ingredient as a string such as "kg" or "g"',
//         ),
//       },
//     ),
//   );

//   Future<void> _testIngredientCallModel(String message) async {
//     final chat = _functionIngredientCallModel.startChat();
//     const prompt =
//         'Your role is to collect the ingredients and quantity information and return them';

//     // Send the message to the generative model.
//     var response = await chat.sendMessage(Content.text(prompt + message));

//     final functionCalls = response.functionCalls.toList();
//     // When the model response with a function call, invoke the function.
//     if (functionCalls.isNotEmpty) {
//       log('${functionCalls.map((e) => '${e.name} and ${e.args}')}');
//     }
//   }
// }
