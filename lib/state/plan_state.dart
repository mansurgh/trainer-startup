import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  return PlanNotifier();
});

class PlanNotifier extends StateNotifier<PlanState?> {
  PlanNotifier() : super(null);

  /// Сгенерировать программу на 28 дней (заглушка — подставь любую логику)
  Future<void> generateProgram() async {
    final days = List<String>.generate(28, (i) {
      final d = i + 1;
      return '''
— Разминка 8–10 мин (кардио, суставы)
— Блок A (сила): 3×8–10
— Блок B (объём): 3×12–15
— Финиш: пресс/кор/дыхание 5–8 мин

Пример (День $d):
• Присед со штангой — 4×6–8
• Жим лёжа — 4×6–8
• Тяга горизонтальная — 3×10–12
• Жим гантелей сидя — 3×10–12
• Планка — 3×45–60 сек
''';
    });

    // todayIndex можно вычислять по дате; пока — 0
    state = PlanState(programDays: days, todayIndex: 0);
  }

  /// Сдвинуть текущий день (по желанию)
  void gotoDay(int index) {
    final s = state;
    if (s == null) return;
    final clamped = index.clamp(0, s.programDays.length - 1);
    state = s.copyWith(todayIndex: clamped);
  }
}
