import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/modern_components.dart';
import '../l10n/app_localizations.dart';
import 'workout_screen.dart';

/// Современный экран тренировок с анатомией мышц
class ModernWorkoutScreen extends StatefulWidget {
  const ModernWorkoutScreen({super.key});

  @override
  State<ModernWorkoutScreen> createState() => _ModernWorkoutScreenState();
}

class _ModernWorkoutScreenState extends State<ModernWorkoutScreen> {
  late String selectedDay;
  late bool isToday;
  
  final List<String> days = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    selectedDay = _getTodayDay();
    isToday = true;
  }
  // Получить все упражнения дня в правильном порядке
  List<String> get dayExercises {
    switch (selectedDay) {
      case 'Monday':
        return ['barbell bench press', 'dumbbell incline press', 'dumbbell flyes', 'push up'];
      case 'Tuesday':
        return ['barbell squat', 'romanian deadlift', 'bulgarian split squat', 'calf raise'];
      case 'Wednesday':
        return ['barbell military press', 'dumbbell lateral raise', 'dumbbell rear delt flye', 'dumbbell tricep extension'];
      case 'Thursday':
        return ['pull up', 'barbell row', 'lat pulldown', 'bicep curl'];
      case 'Friday':
        return ['deadlift', 'barbell row', 'face pull', 'hammer curl'];
      case 'Saturday':
        return ['overhead press', 'dumbbell press', 'dumbbell lateral raise', 'tricep dip'];
      case 'Sunday':
        return ['rest day'];
      default:
        return ['barbell military press', 'dumbbell lateral raise', 'dumbbell rear delt flye', 'dumbbell tricep extension'];
    }
  }

  List<Map<String, dynamic>> get muscleGroups {
    // Разные программы для разных дней
    switch (selectedDay) {
      case 'Monday':
        return [
          {'muscleGroup': 'chest', 'title': 'Chest', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell bench press', 'push up']},
          {'muscleGroup': 'front delts', 'title': 'Front Delts', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell military press']},
          {'muscleGroup': 'triceps', 'title': 'Triceps', 'progress': '0+5', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['dumbbell tricep extension']},
        ];
      case 'Tuesday':
        return [
          {'muscleGroup': 'back', 'title': 'Back', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['pull up', 'bent over row']},
          {'muscleGroup': 'biceps', 'title': 'Biceps', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell curl', 'hammer curl']},
          {'muscleGroup': 'rear delts', 'title': 'Rear Delts', 'progress': '0+3', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['rear delt fly']},
        ];
      case 'Wednesday':
        return [
          {'muscleGroup': 'chest', 'title': 'Chest', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell bench press', 'push up']},
          {'muscleGroup': 'front delts', 'title': 'Front Delts', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell military press']},
          {'muscleGroup': 'side delts', 'title': 'Side Delts', 'progress': '0+3', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['dumbbell lateral raise']},
          {'muscleGroup': 'triceps', 'title': 'Triceps', 'progress': '0+5', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['dumbbell tricep extension']},
        ];
      case 'Thursday':
        return [
          {'muscleGroup': 'legs', 'title': 'Legs', 'progress': '0+8', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell squat', 'lunge', 'leg press']},
          {'muscleGroup': 'glutes', 'title': 'Glutes', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['hip thrust', 'glute bridge']},
        ];
      case 'Friday':
        return [
          {'muscleGroup': 'back', 'title': 'Back', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['pull up', 'bent over row']},
          {'muscleGroup': 'biceps', 'title': 'Biceps', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell curl', 'hammer curl']},
        ];
      case 'Saturday':
        return [
          {'muscleGroup': 'shoulders', 'title': 'Shoulders', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell military press', 'dumbbell lateral raise']},
          {'muscleGroup': 'arms', 'title': 'Arms', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell curl', 'dumbbell tricep extension']},
        ];
      case 'Sunday':
        return [
          {'muscleGroup': 'rest', 'title': 'Rest Day', 'progress': '0+0', 'status': 'Rest', 'accentColor': const Color(0xFF5B21B6), 'exercises': ['Rest and Recovery']},
        ];
      default:
        return [
          {'muscleGroup': 'chest', 'title': 'Chest', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell bench press', 'push up']},
          {'muscleGroup': 'front delts', 'title': 'Front Delts', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['barbell military press']},
          {'muscleGroup': 'side delts', 'title': 'Side Delts', 'progress': '0+3', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['dumbbell lateral raise']},
          {'muscleGroup': 'triceps', 'title': 'Triceps', 'progress': '0+5', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['dumbbell tricep extension']},
        ];
    }
  }

  // Получаем упражнения для выбранного дня
  List<Map<String, dynamic>> get exercises {
    switch (selectedDay) {
      case 'Monday':
        return [
          {'name': 'barbell bench press', 'sets': '5 sets', 'weight': '+2.5 kg', 'icon': Icons.fitness_center},
          {'name': 'dumbbell incline press', 'sets': '3 sets', 'weight': '', 'icon': Icons.fitness_center},
          {'name': 'dumbbell flyes', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
          {'name': 'push up', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
      case 'Tuesday':
        return [
          {'name': 'barbell squat', 'sets': '5 sets', 'weight': '+5 kg', 'icon': Icons.fitness_center},
          {'name': 'romanian deadlift', 'sets': '4 sets', 'weight': '', 'icon': Icons.fitness_center},
          {'name': 'bulgarian split squat', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
          {'name': 'calf raise', 'sets': '4 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
      case 'Wednesday':
        return [
          {'name': 'barbell military press', 'sets': '5 sets', 'weight': '+2.5 kg', 'icon': Icons.fitness_center},
          {'name': 'dumbbell lateral raise', 'sets': '3 sets', 'weight': '', 'icon': Icons.arrow_forward},
          {'name': 'dumbbell rear delt flye', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
          {'name': 'dumbbell tricep extension', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
      case 'Thursday':
        return [
          {'name': 'pull up', 'sets': '4 sets', 'weight': '', 'icon': Icons.fitness_center},
          {'name': 'barbell row', 'sets': '4 sets', 'weight': '+2.5 kg', 'icon': Icons.fitness_center},
          {'name': 'lat pulldown', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
          {'name': 'bicep curl', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
      case 'Friday':
        return [
          {'name': 'deadlift', 'sets': '5 sets', 'weight': '+5 kg', 'icon': Icons.fitness_center},
          {'name': 'barbell row', 'sets': '4 sets', 'weight': '', 'icon': Icons.fitness_center},
          {'name': 'face pull', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
          {'name': 'hammer curl', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
      case 'Saturday':
        return [
          {'name': 'overhead press', 'sets': '4 sets', 'weight': '', 'icon': Icons.fitness_center},
          {'name': 'dumbbell press', 'sets': '3 sets', 'weight': '', 'icon': Icons.fitness_center},
          {'name': 'dumbbell lateral raise', 'sets': '3 sets', 'weight': '', 'icon': Icons.arrow_forward},
          {'name': 'tricep dip', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
      case 'Sunday':
        return [
          {'name': 'Rest Day', 'sets': '', 'weight': '', 'icon': Icons.hotel},
        ];
      default:
        return [
          {'name': 'barbell military press', 'sets': '5 sets', 'weight': '+2.5 kg', 'icon': Icons.fitness_center},
          {'name': 'dumbbell lateral raise', 'sets': '3 sets', 'weight': '', 'icon': Icons.arrow_forward},
          {'name': 'dumbbell rear delt flye', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
          {'name': 'dumbbell tricep extension', 'sets': '3 sets', 'weight': '', 'icon': Icons.accessibility},
        ];
    }
  }

  String _getDaySubtitle(String day) {
    switch (day) {
      case 'Monday':
        return 'Chest & Triceps • 60 min';
      case 'Tuesday':
        return 'Legs • 75 min';
      case 'Wednesday':
        return 'Shoulders & Triceps • 60 min';
      case 'Thursday':
        return 'Back & Biceps • 70 min';
      case 'Friday':
        return 'Full Body • 80 min';
      case 'Saturday':
        return 'Upper Body • 65 min';
      case 'Sunday':
        return 'Rest Day • 0 min';
      default:
        return 'Push day • 60 min';
    }
  }

  String _getTodayDay() {
    final now = DateTime.now();
    final weekday = now.weekday;
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  void _showDaySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Ручка для перетаскивания
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectDay,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Список дней
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isSelected = selectedDay == day;
                        final isTodayDay = day == _getTodayDay(); // Определяем сегодняшний день
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF007AFF).withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF007AFF).withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedDay = day;
                                isToday = isTodayDay;
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFF007AFF).withValues(alpha: 0.2)
                                          : Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isTodayDay ? Icons.today : Icons.calendar_today,
                                      color: isSelected ? const Color(0xFF007AFF) : Colors.white.withValues(alpha: 0.7),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          day,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (isTodayDay)
                                          Text(
                                            AppLocalizations.of(context)!.today,
                                            style: const TextStyle(
                                              color: Color(0xFF00D4AA),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007AFF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMuscleDetails(BuildContext context, Map<String, dynamic> muscle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: muscle['accentColor'].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMuscleIcon(muscle['muscleGroup']),
                      color: muscle['accentColor'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscle['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${muscle['exercises'].length} упражнений',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Упражнения
              Text(
                'Упражнения',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: muscle['exercises'].length,
                  itemBuilder: (context, index) {
                    final exercise = muscle['exercises'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ModernComponents.sexyCard(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: muscle['accentColor'].withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.fitness_center,
                                color: muscle['accentColor'],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                exercise,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      exercise['icon'],
                      color: const Color(0xFF007AFF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          exercise['sets'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Детали упражнения
              Text(
                'Детали упражнения',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDetailCard('Подходы', exercise['sets'], Icons.repeat),
                      const SizedBox(height: 12),
                      if (exercise['weight'].isNotEmpty)
                        _buildDetailCard('Вес', exercise['weight'], Icons.fitness_center),
                      const SizedBox(height: 12),
                      _buildDetailCard('Техника', _getExerciseTechnique(exercise['name']), Icons.info),
                      const SizedBox(height: 12),
                      _buildDetailCard('Советы', _getExerciseTips(exercise['name']), Icons.lightbulb),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Кнопка начать упражнение
              ModernComponents.sexyButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Переходим на экран тренировки с выбранным упражнением
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutScreen(
                        selectedExercise: exercise['name'],
                      ),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.startExercise),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return ModernComponents.sexyCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF007AFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getExerciseTechnique(String exerciseName) {
    switch (exerciseName) {
      case 'Barbell Bench Press':
        return 'Лягте на скамью, возьмите штангу хватом шире плеч. Опустите штангу к груди, затем выжмите вверх, полностью выпрямляя руки. Держите лопатки сведенными, ноги устойчиво на полу.';
      case 'Barbell Military Press':
        return 'Встаньте прямо, ноги на ширине плеч. Возьмите штангу на уровне плеч. Выжмите штангу вверх над головой, полностью выпрямляя руки. Опустите контролируемо обратно.';
      case 'Dumbbell Incline Press':
        return 'Установите скамью под углом 30-45 градусов. Лягте, возьмите гантели. Опустите гантели к груди, затем выжмите вверх по дуге, сводя руки в верхней точке.';
      case 'Dumbbell Lateral Raises':
        return 'Встаньте прямо, держите гантели по бокам. Поднимите гантели в стороны до уровня плеч, слегка согнув локти. Опустите контролируемо в исходное положение.';
      case 'Dumbbell Tricep Extensions':
        return 'Сядьте или встаньте, держите гантель обеими руками за головой. Разгибайте руки в локтях, поднимая гантель вверх. Опустите контролируемо за голову.';
      default:
        return 'Правильная техника выполнения упражнения. Следите за дыханием и контролируйте движения.';
    }
  }

  String _getExerciseTips(String exerciseName) {
    switch (exerciseName) {
      case 'Barbell Bench Press':
        return '• Держите лопатки сведенными\n• Не отрывайте ноги от пола\n• Дышите: вдох при опускании, выдох при подъеме\n• Не отбивайте штангу от груди';
      case 'Barbell Military Press':
        return '• Держите корпус напряженным\n• Не прогибайтесь в пояснице\n• Дышите: вдох при опускании, выдох при подъеме\n• Смотрите вперед, не запрокидывайте голову';
      case 'Dumbbell Incline Press':
        return '• Контролируйте движение в обеих фазах\n• Не сводите гантели слишком близко\n• Дышите: вдох при опускании, выдох при подъеме\n• Держите лопатки сведенными';
      case 'Dumbbell Lateral Raises':
        return '• Не используйте инерцию\n• Поднимайте до уровня плеч\n• Дышите: вдох при опускании, выдох при подъеме\n• Не раскачивайтесь корпусом';
      case 'Dumbbell Tricep Extensions':
        return '• Держите локти неподвижными\n• Не разводите локти в стороны\n• Дышите: вдох при опускании, выдох при подъеме\n• Контролируйте движение в обеих фазах';
      default:
        return '• Следите за правильной техникой\n• Дышите ритмично\n• Контролируйте движение\n• Не торопитесь';
    }
  }

  IconData _getMuscleIcon(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Icons.favorite; // Сердце для груди
      case 'front delts':
        return Icons.trending_up; // Стрелка вверх для передних дельт
      case 'side delts':
        return Icons.trending_flat; // Горизонтальная стрелка для боковых дельт
      case 'back':
        return Icons.trending_down; // Стрелка вниз для спины
      case 'legs':
        return Icons.directions_run; // Бег для ног
      case 'arms':
        return Icons.fitness_center; // Гантели для рук
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // Сексуальный AppBar
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: ModernComponents.sexyText(
                  'Today\'s workout',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Контент
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Заголовок дня
                  ModernComponents.sexyHeader(
                    selectedDay,
                    subtitle: _getDaySubtitle(selectedDay),
                    trailing: GestureDetector(
                      onTap: () => _showDaySelector(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Группы мышц
                  ModernComponents.sexyText(
                    'Muscle Groups',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Горизонтальный список групп мышц
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: muscleGroups.length,
                      itemBuilder: (context, index) {
                        final muscle = muscleGroups[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                        child: ModernComponents.muscleAnatomyCard(
                          muscleGroup: muscle['muscleGroup'],
                          title: muscle['title'],
                          progress: muscle['progress'],
                          status: muscle['status'],
                          accentColor: muscle['accentColor'],
                          exercises: muscle['exercises'],
                          // Убираем onTap - группы мышц больше не кликабельны
                        ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Список упражнений
                  ModernComponents.sexyText(
                    'Exercises',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Список упражнений
                  ModernComponents.sexyList(
                    children: exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ModernComponents.sexyCard(
                          onTap: () {
                            // Показываем детали упражнения
                            _showExerciseDetails(context, exercise);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  exercise['icon'],
                                  color: const Color(0xFF007AFF),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exercise['sets'],
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (exercise['weight'].isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: const Color(0xFF00D4AA),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        exercise['weight'],
                                        style: const TextStyle(
                                          color: Color(0xFF00D4AA),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Кнопка начала тренировки
                  ModernComponents.sexyButton(
                    onPressed: isToday ? () {
                      // Переходим на экран тренировки с планом дня
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorkoutScreen(
                            dayPlan: dayExercises,
                          ),
                        ),
                      );
                    } : null,
                    backgroundColor: isToday 
                        ? const Color(0xFF007AFF)
                        : Colors.white.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isToday ? Icons.play_arrow : Icons.lock,
                          color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isToday ? 'Start workout' : 'Available on training day',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
