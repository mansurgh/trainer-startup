import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/sexy_components.dart';
import 'workout_screen.dart';
import 'workout_schedule/widgets/customize_workout_sheet.dart';
import '../models/workout_day.dart';
import '../models/muscle_group.dart';

/// Сексуальный экран тренировок с анатомией мышц
class SexyWorkoutScreen extends StatefulWidget {
  const SexyWorkoutScreen({super.key});

  @override
  State<SexyWorkoutScreen> createState() => _SexyWorkoutScreenState();
}

class _SexyWorkoutScreenState extends State<SexyWorkoutScreen> {
  String selectedDay = 'Wednesday';
  bool isToday = true; // Пока что всегда true, потом добавим логику даты
  
  final List<String> days = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  List<Map<String, dynamic>> get muscleGroups {
    // Разные программы для разных дней
    switch (selectedDay) {
      case 'Monday':
        return [
          {'muscleGroup': 'chest', 'title': 'Chest', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Bench Press', 'Dumbbell Incline Press']},
          {'muscleGroup': 'front delts', 'title': 'Front Delts', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Military Press']},
          {'muscleGroup': 'triceps', 'title': 'Triceps', 'progress': '0+5', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Dumbbell Tricep Extensions']},
        ];
      case 'Tuesday':
        return [
          {'muscleGroup': 'back', 'title': 'Back', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Pull-ups', 'Bent-over Rows']},
          {'muscleGroup': 'biceps', 'title': 'Biceps', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Curls', 'Hammer Curls']},
          {'muscleGroup': 'rear delts', 'title': 'Rear Delts', 'progress': '0+3', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Rear Delt Flyes']},
        ];
      case 'Wednesday':
        return [
          {'muscleGroup': 'chest', 'title': 'Chest', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Bench Press', 'Dumbbell Incline Press']},
          {'muscleGroup': 'front delts', 'title': 'Front Delts', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Military Press']},
          {'muscleGroup': 'side delts', 'title': 'Side Delts', 'progress': '0+3', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Dumbbell Lateral Raises']},
          {'muscleGroup': 'triceps', 'title': 'Triceps', 'progress': '0+5', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Dumbbell Tricep Extensions']},
        ];
      case 'Thursday':
        return [
          {'muscleGroup': 'legs', 'title': 'Legs', 'progress': '0+8', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Squats', 'Lunges', 'Leg Press']},
          {'muscleGroup': 'glutes', 'title': 'Glutes', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Hip Thrusts', 'Glute Bridges']},
        ];
      case 'Friday':
        return [
          {'muscleGroup': 'back', 'title': 'Back', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Pull-ups', 'Bent-over Rows']},
          {'muscleGroup': 'biceps', 'title': 'Biceps', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Curls', 'Hammer Curls']},
        ];
      case 'Saturday':
        return [
          {'muscleGroup': 'shoulders', 'title': 'Shoulders', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Military Press', 'Lateral Raises']},
          {'muscleGroup': 'arms', 'title': 'Arms', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Bicep Curls', 'Tricep Dips']},
        ];
      case 'Sunday':
        return [
          {'muscleGroup': 'rest', 'title': 'Rest Day', 'progress': '0+0', 'status': 'Rest', 'accentColor': const Color(0xFF5B21B6), 'exercises': ['Rest and Recovery']},
        ];
      default:
        return [
          {'muscleGroup': 'chest', 'title': 'Chest', 'progress': '0+6', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Bench Press', 'Dumbbell Incline Press']},
          {'muscleGroup': 'front delts', 'title': 'Front Delts', 'progress': '0+4', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Barbell Military Press']},
          {'muscleGroup': 'side delts', 'title': 'Side Delts', 'progress': '0+3', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Dumbbell Lateral Raises']},
          {'muscleGroup': 'triceps', 'title': 'Triceps', 'progress': '0+5', 'status': 'Growing', 'accentColor': const Color(0xFF00D4AA), 'exercises': ['Dumbbell Tricep Extensions']},
        ];
    }
  }

  final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Barbell Bench Press',
      'sets': '5 sets',
      'weight': '+2.5 kg',
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Barbell Military Press',
      'sets': '3 sets',
      'weight': '',
      'icon': Icons.accessibility,
    },
    {
      'name': 'Dumbbell Incline Press',
      'sets': '3 sets',
      'weight': '',
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Dumbbell Lateral Raises',
      'sets': '3 sets',
      'weight': '',
      'icon': Icons.arrow_forward,
    },
    {
      'name': 'Dumbbell Tricep Extensions',
      'sets': '3 sets',
      'weight': '',
      'icon': Icons.accessibility,
    },
  ];

  void _showDaySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Select Day',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isSelected = selectedDay == day;
                        final isTodayDay = day == 'Wednesday'; // Пока что только среда = сегодня
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SexyComponents.sexyCard(
                            onTap: () {
                              setState(() {
                                selectedDay = day;
                                isToday = isTodayDay;
                              });
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isTodayDay ? Icons.today : Icons.calendar_today,
                                  color: isSelected ? const Color(0xFF007AFF) : Colors.white.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // Добавлено для исправления
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
                                          'Today',
                                          style: TextStyle(
                                            color: const Color(0xFF00D4AA),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: const Color(0xFF007AFF),
                                    size: 20,
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
                      child: SexyComponents.sexyCard(
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
              SexyComponents.sexyButton(
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
                child: const Text('Начать упражнение'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return SexyComponents.sexyCard(
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
                title: SexyComponents.sexyText(
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
                  SexyComponents.sexyHeader(
                    selectedDay,
                    subtitle: 'Push day • 60 min',
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
                  
                  // Кнопка кастомизации тренировки
                  SexyComponents.sexyButton(
                    onPressed: _showCustomizeWorkout,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Настроить тренировку',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Группы мышц
                  SexyComponents.sexyText(
                    'Группы мышц',
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
                        child: SexyComponents.muscleAnatomyCard(
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
                  
                  // Анатомическая карта
                  _buildAnatomySection(),
                  
                  const SizedBox(height: 32),
                  
                  // Список упражнений
                  SexyComponents.sexyText(
                    'Упражнения',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Список упражнений
                  SexyComponents.sexyList(
                    children: exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SexyComponents.sexyCard(
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
                  SexyComponents.sexyButton(
                    onPressed: isToday ? () {
                      // Переходим на старый экран с гифками
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WorkoutScreen()),
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

  // Секция с анатомической картой
  Widget _buildAnatomySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SexyComponents.sexyText(
          'Анатомия',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        SexyComponents.sexyCard(
          child: Column(
            children: [
              // Переключатель Front/Back
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildViewToggle('Front', true),
                  const SizedBox(width: 16),
                  _buildViewToggle('Back', false),
                ],
              ),
              const SizedBox(height: 24),
              
              // Изображение анатомии
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildAnatomyImage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Переключатель вида (Front/Back)
  Widget _buildViewToggle(String label, bool isFront) {
    final isSelected = isFront; // Пока что всегда показываем Front
    return GestureDetector(
      onTap: () {
        // TODO: Переключение между Front/Back
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF007AFF).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF007AFF)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? const Color(0xFF007AFF)
                : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Изображение анатомии с выделенными мышцами
  Widget _buildAnatomyImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Базовое изображение тела (можно заменить на настоящее изображение)
        Container(
          width: 150,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(80),
          ),
          child: const Icon(
            Icons.accessibility_new,
            size: 120,
            color: Colors.white30,
          ),
        ),
        
        // Выделенные группы мышц для текущего дня
        ...muscleGroups.map((muscle) {
          return Positioned(
            top: _getMusclePosition(muscle['muscleGroup'])['top'],
            left: _getMusclePosition(muscle['muscleGroup'])['left'],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: muscle['accentColor'].withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: muscle['accentColor'],
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getMuscleIcon(muscle['muscleGroup']),
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Позиции мышц на анатомической карте (примерные)
  Map<String, double> _getMusclePosition(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return {'top': 80.0, 'left': 105.0};
      case 'front delts':
        return {'top': 70.0, 'left': 80.0};
      case 'side delts':
        return {'top': 70.0, 'left': 130.0};
      case 'back':
        return {'top': 90.0, 'left': 105.0};
      case 'biceps':
        return {'top': 120.0, 'left': 70.0};
      case 'triceps':
        return {'top': 120.0, 'left': 140.0};
      case 'legs':
        return {'top': 180.0, 'left': 105.0};
      default:
        return {'top': 100.0, 'left': 105.0};
    }
  }

  // Показать окно кастомизации тренировки
  void _showCustomizeWorkout() {
    // Создаем фиктивный WorkoutDay для демонстрации
    final currentDay = WorkoutDay(
      date: DateTime.now(),
      targetGroups: muscleGroups.map((muscle) {
        switch (muscle['muscleGroup'].toString().toLowerCase()) {
          case 'chest':
            return MuscleGroup.chest;
          case 'back':
            return MuscleGroup.back;
          case 'legs':
            return MuscleGroup.legs;
          case 'arms':
          case 'biceps':
          case 'triceps':
            return MuscleGroup.arms;
          default:
            return MuscleGroup.chest;
        }
      }).toList(),
      exercises: [], // Пустой список упражнений
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomizeWorkoutSheet(
        currentDay: currentDay,
      ),
    ).then((updatedDay) {
      if (updatedDay != null) {
        // TODO: Обновить тренировку с новыми настройками
        print('Workout updated: $updatedDay');
      }
    });
  }
}
