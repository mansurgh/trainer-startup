enum AIResponseType { general, macros, tips, program, posture }

enum MessageActor { user, assistant }

enum ContentType { text, image, aiResponse }

class MacroNutrients {
  final int kcal; final int protein; final int fat; final int carbs;
  const MacroNutrients({required this.kcal, required this.protein, required this.fat, required this.carbs});
}

class AIResponse {
  final AIResponseType type;
  final String advice; // markdown-friendly short answer
  final MacroNutrients? macros;
  final List<String> gifUrls;
  const AIResponse({required this.type, required this.advice, this.macros, this.gifUrls = const []});
}