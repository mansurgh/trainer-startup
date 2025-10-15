import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/design_tokens.dart';
import '../core/premium_components.dart';
import 'workout_screen.dart';
import 'ai_chat_screen.dart';
import 'weekly_schedule_screen.dart';
import 'workout_schedule/workout_schedule_screen.dart';

/// Современный экран тренировок с премиум дизайном
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(DesignTokens.space16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Простой заголовок вместо SliverAppBar
              Row(
                children: [
                  Text(
                    'Тренировки',
                    style: DesignTokens.h1.copyWith(
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  PremiumComponents.glassButton(
                    onPressed: () => _showAICoach(),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: DesignTokens.primaryAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignTokens.space24),
              _buildTodayWorkoutCard(),
              SizedBox(height: DesignTokens.space24),
              _buildMuscleMapSection(),
              SizedBox(height: DesignTokens.space24),
              _buildTodayExercisesList(),
              SizedBox(height: DesignTokens.space24),
              _buildQuickStats(),
              SizedBox(height: DesignTokens.space24),
              _buildWorkoutScheduleButton(),
            ]),
          ),
        ),
      ],
    );
  }

  String _getTodayDay() {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = DateTime.now().weekday - 1; // 0-6
    return weekdays[today];
  }

  Widget _buildTodayWorkoutCard() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.space8),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: DesignTokens.primaryAccent,
                  size: 24,
                ),
              ),
              SizedBox(width: DesignTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сегодня: Грудь и трицепс',
                      style: DesignTokens.h3.copyWith(
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: DesignTokens.space4),
                    Text(
                      '4 упражнения • 45 мин',
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.space24),
          Row(
            children: [
              Expanded(
                child: PremiumComponents.glassButton(
                  onPressed: () => _startWorkout(),
                  isPrimary: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded),
                      SizedBox(width: DesignTokens.space8),
                      Text('Начать тренировку'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: DesignTokens.space16),
              PremiumComponents.glassButton(
                onPressed: () => _showWorkoutDetails(),
                child: Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleMapSection() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Карта мышц',
            style: DesignTokens.h3.copyWith(
              color: DesignTokens.textPrimary,
            ),
          ),
          SizedBox(height: DesignTokens.space16),
          Center(
            child: PremiumComponents.muscleMap(
              activeMuscleGroups: {'Грудь', 'Трицепс'},
              showFront: true,
              onToggleView: () {
                setState(() {
                  // Toggle between front and back view
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: PremiumComponents.kpiCard(
            title: 'Текущий стрик',
            value: '7',
            icon: Icons.local_fire_department_rounded,
            accentColor: DesignTokens.warning,
            trend: '+2 дня',
          ),
        ),
        SizedBox(width: DesignTokens.space16),
        Expanded(
          child: PremiumComponents.kpiCard(
            title: 'Эта неделя',
            value: '4/5',
            icon: Icons.calendar_today_rounded,
            accentColor: DesignTokens.success,
            trend: '80%',
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutPlans() {
  // Блок программ скрыт по требованиям (чипы программ убрать)
    // Этот метод скрыт и возвращает пустой виджет, чтобы удовлетворить сигнатуру
    return const SizedBox.shrink();
  }

  Widget _buildWorkoutPlanCard(
    String title,
    String description,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: DesignTokens.space16),
      child: PremiumComponents.glassCard(
        onTap: () => _selectWorkoutPlan(title),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 32,
              ),
            ),
            SizedBox(height: DesignTokens.space16),
            Text(
              title,
              style: DesignTokens.h3.copyWith(
                color: DesignTokens.textPrimary,
              ),
            ),
            SizedBox(height: DesignTokens.space8),
            Text(
              description,
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(delay: 100.ms)
    .slideX(begin: 0.2);
  }

  // Helper methods
  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(dayPlan: dayExercises),
      ),
    );
  }

  void _showAICoach() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIChatScreen(chatType: 'workout'),
      ),
    );
  }

  void _showWorkoutDetails() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyScheduleScreen()));
  }
  void _showAllPrograms() {}
  void _selectWorkoutPlan(String plan) {}

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
        return [];
    }
  }

  Widget _buildTodayExercisesList() {
    final items = dayExercises;
    if (items.isEmpty || (items.length == 1 && items.first == 'rest day')) {
      return PremiumComponents.glassCard(
        child: Center(
          child: Text('Сегодня отдых', style: DesignTokens.bodyMedium),
        ),
      );
    }
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Упражнения на сегодня', style: DesignTokens.h3),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, size: 18, color: DesignTokens.primaryAccent),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_localizeExercise(e), style: DesignTokens.bodyLarge)),
                const SizedBox(width: 8),
                Text(_exerciseShortDesc(e), style: DesignTokens.caption),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _localizeExercise(String key) {
    // Простая локализация названий
    switch (key) {
      case 'barbell bench press': return 'Жим штанги лёжа';
      case 'dumbbell incline press': return 'Жим гантелей на наклонной';
      case 'dumbbell flyes': return 'Разводка гантелей';
      case 'push up': return 'Отжимания';
      case 'barbell squat': return 'Приседания со штангой';
      case 'romanian deadlift': return 'Румынская тяга';
      case 'bulgarian split squat': return 'Болгарские выпады';
      case 'calf raise': return 'Подъёмы на носки';
      case 'barbell military press': return 'Армейский жим';
      case 'dumbbell lateral raise': return 'Махи в стороны';
      case 'dumbbell rear delt flye': return 'Разводка на заднюю дельту';
      case 'dumbbell tricep extension': return 'Французский жим';
      case 'pull up': return 'Подтягивания';
      case 'barbell row': return 'Тяга штанги в наклоне';
      case 'lat pulldown': return 'Тяга верхнего блока';
      case 'bicep curl': return 'Сгибания на бицепс';
      case 'deadlift': return 'Становая тяга';
      case 'face pull': return 'Тяга каната к лицу';
      case 'hammer curl': return 'Молотковые сгибания';
      case 'overhead press': return 'Жим над головой';
      case 'dumbbell press': return 'Жим гантелей';
      case 'tricep dip': return 'Отжимания на брусьях';
      default: return key;
    }
  }

  String _exerciseShortDesc(String key) {
    switch (key) {
      case 'barbell bench press': return '3×8–10';
      case 'dumbbell incline press': return '3×10–12';
      case 'dumbbell flyes': return '3×12–15';
      case 'push up': return '3×макс';
      case 'barbell squat': return '4×6–8';
      case 'romanian deadlift': return '3×8–10';
      case 'bulgarian split squat': return '3×8–10/нога';
      case 'calf raise': return '3×12–15';
      case 'barbell military press': return '4×6–8';
      case 'dumbbell lateral raise': return '3×12–15';
      case 'dumbbell rear delt flye': return '3×12–15';
      case 'dumbbell tricep extension': return '3×10–12';
      case 'pull up': return '4×макс';
      case 'barbell row': return '4×8–10';
      case 'lat pulldown': return '3×10–12';
      case 'bicep curl': return '3×10–12';
      case 'deadlift': return '3×5';
      case 'face pull': return '3×12–15';
      case 'hammer curl': return '3×10–12';
      case 'overhead press': return '4×6–8';
      case 'dumbbell press': return '3×8–10';
      case 'tricep dip': return '3×макс';
      default: return '';
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
                  color: Colors.white.withOpacity(0.3),
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
                      'Select Day',
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
                ? const Color(0xFF007AFF).withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
              color: isSelected 
                ? const Color(0xFF007AFF).withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
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
                      ? const Color(0xFF007AFF).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isTodayDay ? Icons.today : Icons.calendar_today,
                                      color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.7),
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
                                            'Today',
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

  Widget _buildWorkoutScheduleButton() {
    return PremiumComponents.glassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkoutScheduleScreen(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.primaryAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Icon(
              Icons.calendar_view_week_rounded,
              color: DesignTokens.primaryAccent,
              size: 24,
            ),
          ),
          SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Schedule',
                  style: DesignTokens.h3.copyWith(
                    color: DesignTokens.textPrimary,
                  ),
                ),
                SizedBox(height: DesignTokens.space4),
                Text(
                  'View weekly plan with muscle targeting',
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: DesignTokens.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  // Old duplicated UI removed: kept only the new PremiumComponents-based screen above.
}
