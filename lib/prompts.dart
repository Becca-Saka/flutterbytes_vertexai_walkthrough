import 'package:firebase_vertexai/firebase_vertexai.dart';
// During their phone conversation, John detailed the contents of his kitchen: "We've got five chicken breasts, two cans of beans, a bottle of olive oil, a dozen eggs, three bell peppers, a bag of rice, a head of garlic, a carton of yogurt, two lemons, and a bunch of bananas."

// With another housemate as they chatted over the phone, Sarah listed off the ingredients in her pantry: "We have three eggs, a liter of milk, half a kilogram of flour, two tomatoes, a bunch of spinach, a jar of peanut butter, a dozen potatoes, three onions, a packet of pasta, and a block of cheese."

// We have a tuber of yam, a bag of rice, five pieces of plantain, a bunch of ugwu leaves, two tins of tomato paste, a bottle of palm oil, a sachet of crayfish, a pack of beef, three scotch bonnet peppers, and a container of ogbono seeds.   We've got a basket of ripe tomatoes, a sack of long grain rice, a variety of spices including curry powder, thyme, and ginger, a bundle of fresh okra, a tub of shea butter, a jar of honey, a pack of dried fish, a bag of garri, two bottles of soy sauce, a bottle of vinegar, a carton of eggs, a bunch of plantains, a crate of fresh oranges, a tin of sardines, a packet of Maggi cubes, a bag of groundnut, a container of locust beans, and a block of Nigerian yam
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
