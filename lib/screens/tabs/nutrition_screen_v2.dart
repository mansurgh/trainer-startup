import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_tokens.dart';
import '../../theme/app_theme.dart';
import '../../models/meal.dart';
import '../../services/meal_service.dart';
import '../../state/user_state.dart';
import '../../utils/nutrition_calculator.dart';
import '../ai_chat_screen.dart';
import '../meal_schedule_screen.dart';
import 'widgets/nutrition_dialogs.dart';
import 'widgets/edit_dish_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_alert.dart';
import '../../state/activity_state.dart';
import '../../services/nutrition_goal_checker.dart';

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
      backgroundColor: kOledBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with gradient title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [kElectricAmberStart, kElectricAmberEnd],
                      ).createShader(bounds),
                      child: Text(
                        AppLocalizations.of(context)!.nutrition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.trackYourIntake,
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Макросы БЖУ
            SliverToBoxAdapter(
              child: totalsAsync.when(
                data: (totals) => _buildMacroCards(context, totals),
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
            
            // Кнопка добавления приёма пищи
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: InkWell(
                  onTap: () => _showAddMealDialog(context, ref),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: kObsidianSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kObsidianBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: kElectricAmberStart, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.addMeal,
                          style: TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 80)), // Отступ снизу
          ],
        ),
      ),
    );
  }
  
  void _showAddMealDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DesignTokens.cardSurface,
        title: Text(l10n.addMeal, style: DesignTokens.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.name}:', style: DesignTokens.bodyMedium),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              style: DesignTokens.bodyMedium,
              decoration: InputDecoration(
                hintText: '${l10n.breakfast}, ${l10n.lunch}, ${l10n.dinner}, ${l10n.snack}...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: DesignTokens.bgBase,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(ctx);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await _createNewMeal(context, ref, MealType.snack, today, name);
                controller.dispose();
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
  
  Future<void> _createNewMeal(BuildContext context, WidgetRef ref, MealType type, DateTime date, String customName) async {
    final service = ref.read(mealServiceProvider);
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      date: date,
      dishes: [],
      customName: customName,
    );
    
    await service.createMeal(newMeal);
    ref.invalidate(mealsProvider);
    ref.invalidate(dailyTotalsProvider);
    
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppAlert.show(
        context,
        title: 'Meal Added', // TODO: Add to l10n
        description: '$customName ${l10n.addedTo} ${l10n.nutrition}',
        type: AlertType.success,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  Future<void> _showRenameMealDialog(BuildContext context, WidgetRef ref, String mealId, String currentName, DateTime date) async {
    final controller = TextEditingController(text: currentName);
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DesignTokens.cardSurface,
        title: Text('Rename Meal', style: DesignTokens.h3), // TODO: Localize
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.newDishName}:', style: DesignTokens.bodyMedium),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              style: DesignTokens.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.enterDishName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: DesignTokens.bgBase,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(ctx);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final service = ref.read(mealServiceProvider);
                await service.updateMealName(mealId, newName, date);
                ref.invalidate(mealsProvider);
                ref.invalidate(dailyTotalsProvider);
                controller.dispose();
                Navigator.pop(ctx);
                if (context.mounted) {
                  AppAlert.show(
                    context,
                    title: 'Meal Renamed', // TODO: Localize
                    description: 'Name changed to "$newName"',
                    type: AlertType.success,
                    duration: const Duration(seconds: 2),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteMealDialog(BuildContext context, WidgetRef ref, String mealId, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DesignTokens.cardSurface,
        title: Text(l10n.deleteMeal, style: DesignTokens.h3),
        content: Text(l10n.deleteMealConfirm, style: DesignTokens.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final service = ref.read(mealServiceProvider);
              await service.deleteMeal(mealId, date);
              ref.invalidate(mealsProvider);
              ref.invalidate(dailyTotalsProvider);
              Navigator.pop(ctx);
              if (context.mounted) {
                AppAlert.show(
                  context,
                  title: l10n.mealDeleted,
                  type: AlertType.warning,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCards(BuildContext context, Map<String, dynamic> totals) {
    final completedCalories = totals['completedCalories'] as int;
    final targetCalories = totals['targetCalories'] as int;
    final completedProtein = (totals['completedProtein'] as double).toInt();
    final targetProtein = (totals['targetProtein'] as double).toInt();
    final completedFat = (totals['completedFat'] as double).toInt();
    final targetFat = (totals['targetFat'] as double).toInt();
    final completedCarbs = (totals['completedCarbs'] as double).toInt();
    final targetCarbs = (totals['targetCarbs'] as double).toInt();

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Первый ряд: Калории и Белки
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: l10n.calories,
                  consumed: completedCalories.toString(),
                  target: targetCalories.toString(),
                  unit: l10n.kcal,
                  color: DesignTokens.primaryAccent,
                  onTap: () => _showEditGoalDialog(context, 'calories', targetCalories),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroCard(
                  label: l10n.protein,
                  consumed: completedProtein.toString(),
                  target: targetProtein.toString(),
                  unit: 'g', // Keep 'g' as universal or add to l10n if needed (usually 'g' is fine, but user asked)
                  color: DesignTokens.textPrimary,
                  onTap: () => _showEditGoalDialog(context, 'protein', targetProtein),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Второй ряд: Жиры и Углеводы
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: l10n.fat,
                  consumed: completedFat.toString(),
                  target: targetFat.toString(),
                  unit: 'g',
                  color: DesignTokens.textPrimary,
                  onTap: () => _showEditGoalDialog(context, 'fat', targetFat),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroCard(
                  label: l10n.carbs,
                  consumed: completedCarbs.toString(),
                  target: targetCarbs.toString(),
                  unit: 'g',
                  color: DesignTokens.textPrimary,
                  onTap: () => _showEditGoalDialog(context, 'carbs', targetCarbs),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, String type, int currentValue) {
    final controller = TextEditingController(text: currentValue.toString());
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(userProvider);
          
          // Рассчитываем рекомендации если есть данные пользователя
          Map<String, double>? recommendations;
          if (user != null && 
              user.weight != null && 
              user.height != null && 
              user.age != null && 
              user.gender != null) {
            recommendations = NutritionCalculator.calculateRecommendations(
              weight: user.weight!,
              height: user.height!,
              age: user.age!,
              gender: user.gender!,
              activityLevel: user.activityLevel ?? 'medium',
              goal: user.goal ?? 'fitness',
            );
          }
          
          int? recommended;
          if (recommendations != null) {
            switch (type) {
              case 'calories':
                recommended = recommendations['calories']?.toInt();
                break;
              case 'protein':
                recommended = recommendations['protein']?.toInt();
                break;
              case 'fat':
                recommended = recommendations['fat']?.toInt();
                break;
              case 'carbs':
                recommended = recommendations['carbs']?.toInt();
                break;
            }
          }
          
          return AlertDialog(
            backgroundColor: DesignTokens.cardSurface,
            title: Text(
              l10n.editGoal,
              style: DesignTokens.h3,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recommended != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              l10n.recommended,
                              style: DesignTokens.bodySmall.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$recommended ${type == 'calories' ? l10n.kcal : 'g'}',
                          style: DesignTokens.h3.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.basedOnYourData,
                          style: DesignTokens.bodySmall.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      controller.text = recommended.toString();
                    },
                    child: Text(l10n.useRecommended),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: DesignTokens.bodyMedium,
                  decoration: InputDecoration(
                    labelText: l10n.goal,
                    suffixText: type == 'calories' ? l10n.kcal : 'g',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final newValue = int.tryParse(controller.text);
                  if (newValue != null && newValue > 0) {
                    // Сохраняем в SharedPreferences (user-specific)
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('user_id') ?? 'anonymous';
                    await prefs.setInt('nutrition_goal_${userId}_$type', newValue);
                    
                    // Обновляем провайдер для немедленного отображения
                    ref.invalidate(dailyTotalsProvider);
                    
                    // Принудительно проверяем цели
                    await NutritionGoalChecker.checkNow(ref);
                    
                    Navigator.pop(ctx);
                    if (context.mounted) {
                      AppAlert.show(
                        context,
                        title: l10n.goalUpdated,
                        description: '${l10n.goal}: $newValue ${type == 'calories' ? l10n.kcal : 'g'}',
                        type: AlertType.success,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    ).then((_) => controller.dispose());
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
          color: kObsidianSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kObsidianBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, color: kElectricAmberStart, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.aiNutritionistChat,
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
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
          color: kObsidianSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kObsidianBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen_rounded, color: kElectricAmberStart, size: 20),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.fridgeMealPlan,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
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

  String _getLocalizedMealName(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    final lowerName = name.toLowerCase();
    if (lowerName == 'breakfast') return l10n.breakfast;
    if (lowerName == 'lunch') return l10n.lunch;
    if (lowerName == 'dinner') return l10n.dinner;
    if (lowerName == 'snack') return l10n.snack;
    return name;
  }

  Widget _buildMealsList(BuildContext context, WidgetRef ref, List<Meal> meals) {
    return Column(
      children: meals.map((meal) => _MealSection(
        meal: meal,
        displayName: _getLocalizedMealName(context, meal.displayName),
        ref: ref,
        onRename: () => _showRenameMealDialog(context, ref, meal.id, meal.displayName, meal.date),
        onDelete: () => _showDeleteMealDialog(context, ref, meal.id, meal.date),
      )).toList(),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String consumed;
  final String target;
  final String unit;
  final Color color;
  final VoidCallback? onTap;

  const _MacroCard({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCalories = label.toLowerCase().contains('cal') || label.toLowerCase().contains('кал');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isCalories 
              ? kObsidianSurface
              : kObsidianSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCalories ? kElectricAmberStart.withOpacity(0.3) : kObsidianBorder,
            width: 1,
          ),
          gradient: isCalories ? LinearGradient(
            colors: [
              kElectricAmberStart.withOpacity(0.1),
              kElectricAmberEnd.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
        ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isCalories ? kElectricAmberStart : kTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: kTextPrimary,
              ),
              children: [
                TextSpan(text: consumed),
                TextSpan(
                  text: ' / ',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: kTextSecondary,
                  ),
                ),
                TextSpan(
                  text: target,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: kTextSecondary,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: kTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.edit, size: 14, color: kTextTertiary),
        ],
      ),
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  final Meal meal;
  final String displayName;
  final WidgetRef ref;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _MealSection({
    required this.meal,
    required this.displayName,
    required this.ref,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: kObsidianSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kObsidianBorder.withOpacity(0.5)),
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
                    displayName,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${meal.completedCalories}/${meal.totalCalories} ${l10n.kcal}',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: kTextSecondary),
                        color: kObsidianSurface,
                        onSelected: (value) {
                          if (value == 'rename') {
                            onRename();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, color: kTextPrimary),
                                const SizedBox(width: 8),
                                Text(l10n.rename, style: TextStyle(color: kTextPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: kErrorRed),
                                const SizedBox(width: 8),
                                Text(l10n.delete, style: TextStyle(color: kErrorRed)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
                
                // Проверяем выполнение цели по питанию
                await _checkNutritionGoal(ref);
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
                        l10n.addDish,
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
  
  Future<void> _checkNutritionGoal(WidgetRef ref) async {
    try {
      // Используем единую логику проверки целей
      await NutritionGoalChecker.checkNow(ref);
      
      // Обновляем провайдеры активности
      ref.invalidate(activityDataProvider);
      ref.invalidate(todaysWinProvider);
      ref.invalidate(consistencyStreakProvider);
    } catch (e) {
      if (kDebugMode) print('[Nutrition] Error checking goal: $e');
    }
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
