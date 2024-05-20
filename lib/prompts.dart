import 'package:firebase_vertexai/firebase_vertexai.dart';

class Prompts {
  static const String ingredient =
      'Your role is to collect the all the ingredients, unit and quantity information and return them';
  static const String audio = 'Your role is to convert the audio into text';
  static const String image =
      'Estimate the dimensions of the items in this image';
  // static const String image = 'What is going on in this image?';
  static const String other =
      'This is a study material, return a list of possible questions i can get in an exam based on the paper';

  static final ingredientParsingSchema = FunctionDeclaration(
    'findIngredient',
    'Parses all ingredients in text and return a list of returns the name, unit and quantity.',
    Schema(
      SchemaType.object,
      properties: {
        'ingredientName': Schema(
          SchemaType.string,
          description: 'The name of the ingredient as a string',
        ),
        'quantity': Schema(
          SchemaType.number,
          description:
              'The quantity of the ingredient in a interger or fraction',
        ),
        'unit': Schema(
          SchemaType.string,
          nullable: true,
          description:
              'The unit of the ingredient as a string such as "kg" or "g"',
        ),
      },
    ),
  );
}
