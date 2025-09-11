import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../models/ai_response.dart';
import '../models/user_model.dart';
import 'user_state.dart';

/// Простое состояние программы тренировок:
/// - programDays: список из 28 текстовых описаний по дням
/// - todayIndex: индекс "сегодняшнего" дня (0..27)
class PlanState {
  final List<String> programDays;
  final int todayIndex;

  const PlanState({
    required this.programDays,
    required this.todayIndex,
  });

  PlanState copyWith({
    List<String>? programDays,
    int? todayIndex,
  }) {
    return PlanState(
      programDays: programDays ?? this.programDays,
      todayIndex: todayIndex ?? this.todayIndex,
    );
  }
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState?>((ref) {
  return PlanNotifier(ref);
});

class PlanNotifier extends StateNotifier<PlanState?> {
  final AIService _aiService = AIService();
  final Ref _ref;
  
  PlanNotifier(this._ref) : super(null);

  /// Сгенерировать программу на 28 дней с помощью AI
  Future<void> generateProgram() async {
    try {
      // Получаем данные пользователя для персонализации
      final user = _ref.read(userProvider);
      final userInfo = _buildUserInfo(user);
      
      // Генерируем программу через AI
      final response = await _aiService.generateTrainingProgram(userInfo);
      
      // Парсим ответ и создаем программу
      final days = _parseTrainingProgram(response.message);
      
      state = PlanState(
        programDays: days,
        todayIndex: 0,
      );
    } catch (e) {
      // Fallback на заглушку при ошибке
      final days = _generateFallbackProgram();
      state = PlanState(
        programDays: days,
        todayIndex: 0,
      );
    }
  }

  String _buildUserInfo(UserModel? user) {
    if (user == null) return 'Создай программу тренировок для начинающего';
    
    final age = user.age ?? 25;
    final height = user.height ?? 170;
    final weight = user.weight ?? 70;
    final goal = user.goal ?? 'fitness';
    final fatPct = user.bodyFatPct ?? 20;
    final musclePct = user.musclePct ?? 70;
    
    return '''
Создай персональную программу тренировок на 28 дней для:
- Возраст: $age лет
- Рост: $height см
- Вес: $weight кг
- Цель: $goal
- Процент жира: $fatPct%
- Процент мышц: $musclePct%

Программа должна включать:
- Разминку и заминку
- Силовые упражнения
- Кардио
- Упражнения на пресс и кор
- Прогрессию нагрузки

Формат: для каждого дня дай краткое описание тренировки с конкретными упражнениями, подходами и повторениями.
''';
  }

  List<String> _parseTrainingProgram(String aiResponse) {
    // Простой парсинг - разделяем по дням
    final lines = aiResponse.split('\n');
    final days = <String>[];
    String currentDay = '';
    
    for (final line in lines) {
      if (line.toLowerCase().contains('день') || line.toLowerCase().contains('день')) {
        if (currentDay.isNotEmpty) {
          days.add(currentDay.trim());
        }
        currentDay = line + '\n';
      } else if (currentDay.isNotEmpty) {
        currentDay += line + '\n';
      }
    }
    
    if (currentDay.isNotEmpty) {
      days.add(currentDay.trim());
    }
    
    // Если не удалось распарсить, создаем базовую программу
    if (days.length < 28) {
      return _generateFallbackProgram();
    }
    
    return days.take(28).toList();
  }

  List<String> _generateFallbackProgram() {
    return List<String>.generate(28, (i) {
      final d = i + 1;
      return '''
День $d - Силовая тренировка

Разминка (10 мин):
• Легкий бег на месте - 3 мин
• Вращения суставов - 2 мин
• Динамическая растяжка - 5 мин

Основная часть:
• Приседания - 3×12-15
• Отжимания - 3×8-12
• Планка - 3×30-45 сек
• Выпады - 3×10 на каждую ногу
• Подъемы на носки - 3×15-20

Заминка (5 мин):
• Статическая растяжка
• Дыхательные упражнения
''';
    });
  }

  /// Сдвинуть текущий день (по желанию)
  void gotoDay(int index) {
    final s = state;
    if (s == null) return;
    final clamped = index.clamp(0, s.programDays.length - 1);
    state = s.copyWith(todayIndex: clamped);
  }
}
