// lib/screens/tabs/nutrition_screen_v2.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../models/meal.dart';
import '../../services/meal_service.dart';
import '../ai_chat_screen.dart';
import 'widgets/nutrition_dialogs.dart';

final mealServiceProvider = Provider((ref) => MealService());

final mealsProvider = FutureProvider.family<List<Meal>, DateTime>((ref, date) async {
  final service = ref.read(mealServiceProvider);
  return service.getMealsForDate(date);
});

final dailyTotalsProvider = FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final service = ref.read(mealServiceProvider);
  return service.getDailyTotals(date);
});

class NutritionScreenV2 extends ConsumerWidget {
  const NutritionScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Нормализуем дату (только год, месяц, день)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealsAsync = ref.watch(mealsProvider(today));
    final totalsAsync = ref.watch(dailyTotalsProvider(today));

    return Scaffold(
      backgroundColor: DesignTokens.bgBase,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition',
                      style: DesignTokens.h1.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your daily intake',
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Макросы БЖУ
            SliverToBoxAdapter(
              child: totalsAsync.when(
                data: (totals) => _buildMacroCards(totals),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // AI Nutritionist Chat Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAINutritionistButton(context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Fridge-based meal plan Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFridgeButton(context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Приемы пищи
            SliverToBoxAdapter(
              child: mealsAsync.when(
                data: (meals) => _buildMealsList(context, ref, meals),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading meals')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCards(Map<String, dynamic> totals) {
    final completedProtein = (totals['completedProtein'] as double).toInt();
    final targetProtein = (totals['targetProtein'] as double).toInt();
    final completedFat = (totals['completedFat'] as double).toInt();
    final targetFat = (totals['targetFat'] as double).toInt();
    final completedCarbs = (totals['completedCarbs'] as double).toInt();
    final targetCarbs = (totals['targetCarbs'] as double).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _MacroCard(
              label: 'Protein',
              consumed: completedProtein.toString(),
              target: targetProtein.toString(),
              unit: 'g',
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MacroCard(
              label: 'Fat',
              consumed: completedFat.toString(),
              target: targetFat.toString(),
              unit: 'g',
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MacroCard(
              label: 'Carbs',
              consumed: completedCarbs.toString(),
              target: targetCarbs.toString(),
              unit: 'g',
              color: DesignTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAINutritionistButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AIChatScreen(chatType: 'nutrition'),
          ),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, color: DesignTokens.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Nutritionist Chat',
              style: DesignTokens.h3.copyWith(
                color: DesignTokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFridgeButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFridgeMealPlanDialog(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.kitchen_outlined, color: DesignTokens.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Fridge-based Meal Plan',
              style: DesignTokens.h3.copyWith(
                color: DesignTokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFridgeMealPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FridgeMealPlanDialog(),
    );
  }

  Widget _buildMealsList(BuildContext context, WidgetRef ref, List<Meal> meals) {
    return Column(
      children: meals.map((meal) => _MealSection(meal: meal, ref: ref)).toList(),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String consumed;
  final String target;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: DesignTokens.h2.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
              children: [
                TextSpan(text: consumed),
                TextSpan(
                  text: ' / ',
                  style: DesignTokens.h2.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                TextSpan(
                  text: target,
                  style: DesignTokens.h2.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: DesignTokens.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  final Meal meal;
  final WidgetRef ref;

  const _MealSection({required this.meal, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок приема пищи
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    meal.type.displayName,
                    style: DesignTokens.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${meal.completedCalories}/${meal.totalCalories} kcal',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Список блюд
            ...meal.dishes.map((dish) => _DishItem(
              dish: dish,
              mealId: meal.id,
              onToggle: () async {
                final service = ref.read(mealServiceProvider);
                await service.toggleDishCompletion(meal.id, dish.id);
                ref.invalidate(mealsProvider);
                ref.invalidate(dailyTotalsProvider);
              },
            )),

            // Кнопка добавить блюдо
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => _showAddDishDialog(context, meal.id, meal.type),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: DesignTokens.textPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: DesignTokens.textPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add Dish',
                        style: DesignTokens.bodyMedium.copyWith(
                          color: DesignTokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDishDialog(BuildContext context, String mealId, MealType mealType) {
    showDialog(
      context: context,
      builder: (context) => AddDishDialog(mealId: mealId, mealType: mealType),
    );
  }
}

class _DishItem extends StatelessWidget {
  final Dish dish;
  final String mealId;
  final VoidCallback onToggle;

  const _DishItem({
    required this.dish,
    required this.mealId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => EditDishDialog(dish: dish, mealId: mealId),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: DesignTokens.textSecondary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Чекбокс
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dish.isCompleted
                      ? DesignTokens.textPrimary
                      : Colors.transparent,
                  border: Border.all(
                    color: dish.isCompleted
                        ? DesignTokens.textPrimary
                        : DesignTokens.textSecondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: dish.isCompleted
                    ? const Icon(Icons.check, size: 16, color: DesignTokens.bgBase)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

          // Информация о блюде
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: DesignTokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: dish.isCompleted ? TextDecoration.lineThrough : null,
                    color: dish.isCompleted
                        ? DesignTokens.textSecondary
                        : DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dish.calories} kcal • P: ${dish.protein.toInt()}g F: ${dish.fat.toInt()}g C: ${dish.carbs.toInt()}g',
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Кнопка редактировать/удалить
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: DesignTokens.textSecondary,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditDishDialog(dish: dish, mealId: mealId),
              );
            },
          ),
        ],
        ), // Закрываем Row
      ), // Закрываем Container
    ); // Закрываем внешний GestureDetector
  }
}

extension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}
