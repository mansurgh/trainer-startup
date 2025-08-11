import 'dart:math';
import '../models/ai_response.dart';
import '../models/user_model.dart';

/// AI backends (stubs). Swap with real backends later.
class AIService {
  Future<AIResponse> getResponse(String text, {String? imagePath}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (imagePath != null) {
      return AIResponse(
        type: AIResponseType.tips,
        advice: 'На фото вижу продукты. Совет: добавь больше белка к ужину.\n— Творог 200г\n— Яйца 3шт\n— Овсянка 80г',
        gifUrls: const [],
      );
    }
    return AIResponse(type: AIResponseType.general, advice: 'Держи краткий ответ-тренера: пей воду, разомнись 5 минут и фокус на технике.');
  }

  Future<AIResponse> analyzeFood(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return AIResponse(
      type: AIResponseType.macros,
      advice: 'Оценка еды: добавить источник белка и клетчатку.',
      macros: const MacroNutrients(kcal: 620, protein: 38, fat: 20, carbs: 72),
      gifUrls: const [],
    );
  }

  Future<AIResponse> suggestRecipe(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const AIResponse(
      type: AIResponseType.general,
      advice: 'Идея блюда: рис + курица + овощи-брокколи; соус йогурт-чеснок.',
    );
  }

  Future<AIResponse> bodyCheck(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return const AIResponse(type: AIResponseType.tips, advice: 'Осанка ок. Добавь упражнения на заднюю дельту и мобилку Т-спайна.');
  }

  Future<AIResponse> exerciseDetect(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const AIResponse(type: AIResponseType.tips, advice: 'Похоже на присед. Держи колени над стопой, корпус чуть прямее.');
  }

  Future<AIResponse> generateProgram(UserModel user, {String? bodyImagePath}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final days = List.generate(28, (i) => 'День ${i + 1}: ${i % 2 == 0 ? 'Силы (верх)' : 'Силы (низ)'} + 10 мин кардио');
    return AIResponse(type: AIResponseType.program, advice: days.join('\n'));
  }

  Future<AIResponse> analyzeVideo({String? videoPath, String? exerciseName}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final tips = [
      'Держи нейтральную спину',
      'Колени по траектории носков',
      'Контролируй эксцентрику 2–3с',
      'Дыши: вниз — вдох, вверх — выдох',
      'Работай в полном ROM',
    ];
    tips.shuffle(Random());
    return AIResponse(type: AIResponseType.posture, advice: tips.take(4).map((e) => '• $e').join('\n'));
  }
}