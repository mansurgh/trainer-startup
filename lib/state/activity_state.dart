import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_day.dart';
import 'user_state.dart';

// Provider для загрузки данных активности (user-specific)
final activityDataProvider = FutureProvider<List<ActivityDay>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id') ?? 'anonymous';
  final today = DateTime.now();
  final List<ActivityDay> days = [];
  
  // Show last 31 days (to cover full months)
  for (int i = 30; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final dateKey = '${date.year}-${date.month}-${date.day}';
    
    // Use user-specific keys
    final workoutCompleted = prefs.getBool('workout_completed_${userId}_$dateKey') ?? false;
    final nutritionGoalMet = prefs.getBool('nutrition_completed_${userId}_$dateKey') ?? false;
    
    days.add(ActivityDay(
      date: date,
      workoutCompleted: workoutCompleted,
      nutritionGoalMet: nutritionGoalMet,
    ));
  }
  
  return days;
});

// Provider для подсчёта тренировок
final workoutCountProvider = FutureProvider<int>((ref) async {
  final activityDays = await ref.watch(activityDataProvider.future);
  return activityDays.where((day) => day.workoutCompleted).length;
});

// Provider для Today's Win (процент выполненных целей за сегодня)
final todaysWinProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id') ?? 'anonymous';
  final today = DateTime.now();
  final dateKey = '${today.year}-${today.month}-${today.day}';
  
  final workoutCompleted = prefs.getBool('workout_completed_${userId}_$dateKey') ?? false;
  final nutritionCompleted = prefs.getBool('nutrition_completed_${userId}_$dateKey') ?? false;
  
  // 0 = ничего (0%), 50 = одно (желтый), 100 = оба (зеленый)
  if (workoutCompleted && nutritionCompleted) return 100;
  if (workoutCompleted || nutritionCompleted) return 50;
  return 0;
});

// Provider для Consistency Streak (вместо BMI)
final consistencyStreakProvider = FutureProvider<int>((ref) async {
  final activityDays = await ref.watch(activityDataProvider.future);
  
  int streak = 0;
  // Проверяем с конца (сегодняшний день)
  // activityDays отсортированы от старых к новым (последний элемент - сегодня)
  
  // Если сегодня еще ничего не сделано, не сбрасываем стрик, если вчера было сделано
  // Но если сегодня сделано, увеличиваем
  
  final reversedDays = activityDays.reversed.toList();
  
  // Проверяем сегодня
  if (reversedDays.isNotEmpty) {
    final today = reversedDays[0];
    if (today.status != ActivityStatus.missed) {
      streak++;
    } else {
      // Если сегодня пропущено, проверяем вчера. Если вчера было, то стрик не прерван (пока день не закончился)
      // Но для простоты, будем считать стрик только по выполненным дням подряд
      // Если сегодня пусто, стрик = стрику до вчерашнего дня
      // НО: обычно стрик включает сегодня, если сегодня выполнено.
    }
  }
  
  // Идем назад
  for (int i = 1; i < reversedDays.length; i++) {
    if (reversedDays[i].status != ActivityStatus.missed) {
      streak++;
    } else {
      // Если сегодня (i=0) пропущено, то мы уже учли это (streak=0).
      // Если мы дошли до разрыва, останавливаемся.
      
      // Корректировка логики:
      // Стрик - это кол-во дней подряд БЕЗ пропусков.
      // Если сегодня пропущено, но вчера выполнено -> стрик = стрику до вчера.
      // Если сегодня выполнено -> стрик = 1 + стрик до вчера.
      
      // Пересчитаем правильно:
      break; 
    }
  }
  
  // Правильный пересчет:
  int currentStreak = 0;
  bool streakBroken = false;
  
  // Начинаем с сегодня
  // Если сегодня выполнено -> +1, идем к вчера
  // Если сегодня НЕ выполнено -> смотрим вчера. Если вчера выполнено -> идем дальше. Если вчера нет -> 0.
  
  // Упростим: считаем подряд идущие дни с активностью, начиная с "последнего активного дня"
  
  int lastActiveIndex = -1;
  for (int i = 0; i < reversedDays.length; i++) {
    if (reversedDays[i].status != ActivityStatus.missed) {
      lastActiveIndex = i;
      break;
    }
  }
  
  if (lastActiveIndex == -1) return 0; // Вообще нет активности
  
  // Если последний активный день был не сегодня и не вчера (index > 1), то стрик оборвался
  if (lastActiveIndex > 1) return 0;
  
  // Считаем стрик начиная с lastActiveIndex
  for (int i = lastActiveIndex; i < reversedDays.length; i++) {
    if (reversedDays[i].status != ActivityStatus.missed) {
      currentStreak++;
    } else {
      break;
    }
  }
  
  return currentStreak;
});
