import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../core/modern_components.dart';
import '../../state/meal_schedule_state.dart';
import '../../state/fridge_state.dart';
// import '../../models/meal_group.dart'; // not used directly here

class NutritionTab extends ConsumerStatefulWidget {
  const NutritionTab({super.key});

  @override
  ConsumerState<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends ConsumerState<NutritionTab>
    with TickerProviderStateMixin {
  
  final ImagePicker _picker = ImagePicker();
  int _waterGlasses = 5;
  
  // Улучшенные данные о приёмах пищи
  final List<Map<String, dynamic>> _todayMeals = [
    {
      'time': '08:00',
      'name': 'Завтрак',
      'icon': Icons.wb_sunny,
      'color': Colors.orangeAccent,
      'calories': 450,
      'proteins': 18,
      'fats': 12,
      'carbs': 65,
      'foods': [
        {'name': 'Овсяная каша с ягодами', 'kcal': 320, 'amount': '200г'},
        {'name': 'Кофе с молоком', 'kcal': 80, 'amount': '250мл'},
        {'name': 'Банан', 'kcal': 50, 'amount': '1 шт'},
      ],
      'completed': true,
    },
    {
      'time': '13:00',
      'name': 'Обед',
      'icon': Icons.lunch_dining,
      'color': Colors.greenAccent,
      'calories': 620,
      'proteins': 35,
      'fats': 20,
      'carbs': 45,
      'foods': [
        {'name': 'Куриная грудка гриль', 'kcal': 280, 'amount': '150г'},
        {'name': 'Рис с овощами', 'kcal': 220, 'amount': '150г'},
        {'name': 'Овощной салат', 'kcal': 120, 'amount': '100г'},
      ],
      'completed': true,
    },
    {
      'time': '16:00',
      'name': 'Перекус',
      'icon': Icons.local_cafe,
      'color': Colors.purpleAccent,
      'calories': 180,
      'proteins': 15,
      'fats': 8,
      'carbs': 12,
      'foods': [
        {'name': 'Греческий йогурт', 'kcal': 120, 'amount': '150г'},
        {'name': 'Миндаль', 'kcal': 60, 'amount': '10г'},
      ],
      'completed': false,
    },
    {
      'time': '19:00',
      'name': 'Ужин',
      'icon': Icons.dinner_dining,
      'color': Colors.blueAccent,
      'calories': 480,
      'proteins': 30,
      'fats': 18,
      'carbs': 35,
      'foods': [
        {'name': 'Запеченная семга', 'kcal': 280, 'amount': '120г'},
        {'name': 'Овощи на пару', 'kcal': 100, 'amount': '150г'},
        {'name': 'Киноа', 'kcal': 100, 'amount': '80г'},
      ],
      'completed': false,
    },
  ];

  // Список популярных продуктов для быстрого добавления
  final List<Map<String, dynamic>> _popularFoods = [
    {'name': 'Яблоко', 'kcal': 52, 'icon': '🍎'},
    {'name': 'Банан', 'kcal': 96, 'icon': '🍌'},
    {'name': 'Куриная грудка', 'kcal': 165, 'icon': '🍗'},
    {'name': 'Рис', 'kcal': 130, 'icon': '🍚'},
    {'name': 'Овсянка', 'kcal': 68, 'icon': '🥣'},
    {'name': 'Греческий йогурт', 'kcal': 100, 'icon': '🥛'},
    {'name': 'Салат', 'kcal': 25, 'icon': '🥗'},
    {'name': 'Орехи', 'kcal': 200, 'icon': '🥜'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Компактный AppBar с заголовком слева сверху
            SliverAppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              pinned: true,
              floating: false,
              snap: false,
              centerTitle: false,
              toolbarHeight: 56,
              titleSpacing: 12,
              title: const Text(
                'Питание',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            // Main Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Daily Summary Card
                  _buildDailySummaryCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Progress Ring & Quick Stats
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildCalorieProgressRing()),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildQuickStats()),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Today's Meals
                  _buildTodayMealsSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions Grid
                  _buildQuickActionsGrid(),
                  
                  const SizedBox(height: 20),
                  
                  // Water Intake
                  _buildWaterIntakeSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Popular Foods
                  _buildPopularFoodsSection(),
                  
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    final consumedCalories = _todayMeals.where((meal) => meal['completed']).fold(0, (sum, meal) => sum + (meal['calories'] as int));
    final targetCalories = 2000;
    final remainingCalories = targetCalories - consumedCalories;
    final progressPercent = (consumedCalories / targetCalories * 100).clamp(0, 100).toInt();
    
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.today,
                    color: Colors.greenAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Дневная сводка',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.greenAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Потреблено',
                    '$consumedCalories',
                    'ккал',
                    Colors.blueAccent,
                    Icons.local_dining,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Осталось',
                    '$remainingCalories',
                    'ккал',
                    remainingCalories > 0 ? Colors.orangeAccent : Colors.redAccent,
                    remainingCalories > 0 ? Icons.trending_up : Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieProgressRing() {
    final consumedCalories = _todayMeals.where((meal) => meal['completed']).fold(0, (sum, meal) => sum + (meal['calories'] as int));
    final targetCalories = 2000;
    final progress = (consumedCalories / targetCalories).clamp(0.0, 1.0);
    
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress < 0.8 ? Colors.greenAccent : 
                      progress < 1.0 ? Colors.orangeAccent : Colors.redAccent,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$consumedCalories',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniMacro('Б', '85г', Colors.redAccent),
                _buildMiniMacro('Ж', '65г', Colors.orangeAccent),
                _buildMiniMacro('У', '150г', Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMacro(String name, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        GlassCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.yellowAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Энергия',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Высокая',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.yellowAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Цель',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '53%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.amberAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Приёмы пищи',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${_todayMeals.where((m) => m['completed']).length}/${_todayMeals.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._todayMeals.asMap().entries.map((entry) {
          final index = entry.key;
          final meal = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMealCard(meal, index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    final isCompleted = meal['completed'] as bool;
    
    return GlassCard(
      child: InkWell(
        onTap: () => _showMealDetails(meal),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time & Icon Container
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (meal['color'] as Color).withOpacity(0.3),
                      (meal['color'] as Color).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (meal['color'] as Color).withOpacity(0.4),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      meal['icon'] as IconData,
                      color: meal['color'] as Color,
                      size: 18,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal['time'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: meal['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 14),
              
              // Meal Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meal['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (meal['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${meal['calories']} ккал',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: meal['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${meal['foods'].length} продукт${meal['foods'].length > 1 ? (meal['foods'].length < 5 ? 'а' : 'ов') : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMacroChip('Б', '${meal['proteins']}г', Colors.redAccent),
                        const SizedBox(width: 6),
                        _buildMacroChip('Ж', '${meal['fats']}г', Colors.orangeAccent),
                        const SizedBox(width: 6),
                        _buildMacroChip('У', '${meal['carbs']}г', Colors.blueAccent),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Status & Action
              Column(
                children: [
                  GestureDetector(
                    onTap: () => _toggleMealCompletion(meal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? Colors.greenAccent 
                            : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.greenAccent 
                              : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(String name, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$name: $value',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые действия',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              'Сканировать штрихкод',
              Icons.qr_code_scanner,
              Colors.blueAccent,
              () => _scanFood(),
            ),
            _buildQuickActionCard(
              'Фото блюда',
              Icons.camera_alt,
              Colors.purpleAccent,
              () => _takePhotoOfMeal(),
            ),
            _buildQuickActionCard(
              'Поиск рецептов',
              Icons.menu_book,
              Colors.orangeAccent,
              () => _openRecipes(),
            ),
            _buildQuickActionCard(
              'Анализ холодильника',
              Icons.kitchen,
              Colors.greenAccent,
              () => _analyzeFridge(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterIntakeSection() {
    const targetGlasses = 8;
    
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Употребление воды',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$_waterGlasses / $targetGlasses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(targetGlasses, (index) {
                final isFilled = index < _waterGlasses;
                return Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    height: 32,
                    margin: EdgeInsets.only(
                      right: index < targetGlasses - 1 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? Colors.blueAccent.withOpacity(0.75)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFilled 
                            ? Colors.blueAccent
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: isFilled
                        ? Center(
                            child: Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addWaterGlass(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Добавить',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _waterGlasses > 0 ? () => _removeWaterGlass() : null,
                    icon: Icon(
                      Icons.remove,
                      color: _waterGlasses > 0 
                          ? Colors.blueAccent 
                          : Colors.white.withOpacity(0.3),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularFoodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Популярные продукты',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularFoods.length,
            itemBuilder: (context, index) {
              final food = _popularFoods[index];
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: index < _popularFoods.length - 1 ? 12 : 0),
                child: GlassCard(
                  child: InkWell(
                    onTap: () => _addFoodToMeal(food),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            food['icon'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            food['name'],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${food['kcal']} ккал',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddMealDialog(),
      backgroundColor: Colors.greenAccent,
      foregroundColor: Colors.black,
      elevation: 8,
      icon: const Icon(Icons.restaurant, size: 20),
      label: const Text(
        'Добавить',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper methods
  String _getMonthName(int month) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return months[month - 1];
  }

  // Action methods
  void _toggleMealCompletion(Map<String, dynamic> meal) {
    setState(() {
      meal['completed'] = !meal['completed'];
    });
    
    final message = meal['completed'] 
        ? 'Приём пищи отмечен как выполненный! ✅'
        : 'Приём пищи отмечен как невыполненный';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: meal['completed'] ? Colors.greenAccent : Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addFoodToMeal(Map<String, dynamic> food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добавить ${food['name']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${food['kcal']} ккал на 100г',
              style: TextStyle(
                fontSize: 16,
                color: Colors.greenAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'К какому приёму пищи добавить?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _todayMeals.length,
                itemBuilder: (context, index) {
                  final meal = _todayMeals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _addFoodToSpecificMeal(food, meal);
                      },
                      leading: Icon(
                        meal['icon'] as IconData,
                        color: meal['color'] as Color,
                      ),
                      title: Text(
                        meal['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        meal['time'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.add,
                        color: meal['color'] as Color,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Colors.white.withOpacity(0.05),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFoodToSpecificMeal(Map<String, dynamic> food, Map<String, dynamic> meal) {
    setState(() {
      final foods = meal['foods'] as List<Map<String, dynamic>>;
      foods.add({
        'name': food['name'],
        'kcal': food['kcal'],
        'amount': '100г',
      });
      meal['calories'] = (meal['calories'] as int) + (food['kcal'] as int);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food['name']} добавлен в ${meal['name']}'),
        backgroundColor: Colors.greenAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddMealDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Добавить приём пищи',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _popularFoods.length,
                itemBuilder: (context, index) {
                  final food = _popularFoods[index];
                  return GlassCard(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _addFoodToMeal(food);
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              food['icon'],
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              food['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${food['kcal']} ккал',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
    );
  }

  void _showMealDetails(Map<String, dynamic> meal) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (meal['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    meal['icon'] as IconData,
                    color: meal['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['name'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        meal['time'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: meal['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (meal['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${meal['calories']} ккал',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: meal['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Макронутриенты
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Белки',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${meal['proteins']}г',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Жиры',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${meal['fats']}г',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Углеводы',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${meal['carbs']}г',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Продукты:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: (meal['foods'] as List<Map<String, dynamic>>).length,
                itemBuilder: (context, index) {
                  final food = (meal['foods'] as List<Map<String, dynamic>>)[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                food['amount'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${food['kcal']} ккал',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanFood() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white),
            SizedBox(width: 12),
            Text('Сканирование штрихкода будет реализовано'),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _takePhotoOfMeal() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.white),
                SizedBox(width: 12),
                Text('Фото блюда сохранено! 📸'),
              ],
            ),
            backgroundColor: Colors.greenAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при фотографировании: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openRecipes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.menu_book, color: Colors.white),
            SizedBox(width: 12),
            Text('Поиск рецептов будет реализован'),
          ],
        ),
        backgroundColor: Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _analyzeFridge() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(fridgeProvider.notifier).setImage(image.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.kitchen, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Фото холодильника загружено! 🏠'),
                ],
              ),
              backgroundColor: Colors.greenAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке фото: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addWaterGlass() {
    if (_waterGlasses < 8) {
      setState(() {
        _waterGlasses++;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Стакан воды добавлен! 💧 ($_waterGlasses/8)'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дневная норма воды достигнута! 🎉'),
          backgroundColor: Colors.greenAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeWaterGlass() {
    if (_waterGlasses > 0) {
      setState(() {
        _waterGlasses--;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Стакан воды убран ($_waterGlasses/8)'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
