import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../core/modern_components.dart';
import '../../theme/noir_theme.dart';
import '../../widgets/noir_glass_components.dart';
import '../../state/meal_schedule_state.dart';
import '../../state/fridge_state.dart';
import '../../models/meal_group.dart';
import '../../services/noir_toast_service.dart';
import '../../l10n/app_localizations.dart';

class NutritionTab extends ConsumerStatefulWidget {
  const NutritionTab({super.key});

  @override
  ConsumerState<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends ConsumerState<NutritionTab>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'Питание',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Кнопка чата с тренером убрана по запросу
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'План'),
                  Tab(text: 'Холодильник'),
                  Tab(text: 'Рецепты'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMealPlanContent(),
                  _buildFridgeContent(),
                  _buildRecipesContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanContent() {
    final mealSchedule = ref.watch(mealScheduleProvider);
    final meals = mealSchedule.meals;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Общая статистика калорий
          PremiumComponents.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCalorieInfo('Цель', '2000', Colors.blueAccent),
                  _buildCalorieInfo('Съедено', _calculateTotalCalories(meals).toString(), Colors.greenAccent),
                  _buildCalorieInfo('Осталось', (2000 - _calculateTotalCalories(meals)).toString(), Colors.orangeAccent),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Список приёмов пищи
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: true,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(mealScheduleProvider.notifier).reorderMeals(oldIndex, newIndex);
                    },
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      return _buildMealCard(meals[index], index);
                    },
                  ),
                ),
                _buildAddMealButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFridgeContent() {
    final fridge = ref.watch(fridgeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Только одна кнопка - загрузить фото холодильника
          PremiumComponents.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Загрузить фото холодильника',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _takeFridgePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Загрузить фото'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Отображение загруженного фото (если есть)
          if (fridge.imagePath?.isNotEmpty == true) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(fridge.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Фото холодильника загружено! Рецепты будут показаны в разделе "Рецепты".',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipesContent() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Рецепты будут отображаться здесь',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieInfo(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealGroup meal, int index) {
    return Container(
      key: ValueKey('meal_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      child: PremiumComponents.glassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getMealIcon(index),
                    color: _getMealColor(index),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      meal.name.isNotEmpty ? meal.name : _getMealTitle(index),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${_getMealCalories(meal)} ккал',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getMealColor(index),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    color: const Color(0xFF2A2A2A),
                    onSelected: (value) {
                      if (value == 'rename') {
                        _renameMeal(index, meal.name);
                      } else if (value == 'delete') {
                        _deleteMeal(index, meal.name);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text('Переименовать', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text('Удалить', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (meal.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...meal.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${item.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMealButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PremiumComponents.glassCard(
        child: InkWell(
          onTap: _addMeal,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white70,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Добавить приём пищи',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Вспомогательные методы
  IconData _getMealIcon(int index) {
    switch (index % 4) {
      case 0: return Icons.wb_sunny;
      case 1: return Icons.lunch_dining;
      case 2: return Icons.dinner_dining;
      case 3: return Icons.nightlight;
      default: return Icons.restaurant;
    }
  }

  Color _getMealColor(int index) {
    switch (index % 4) {
      case 0: return Colors.orangeAccent;
      case 1: return Colors.greenAccent;
      case 2: return Colors.blueAccent;
      case 3: return Colors.purpleAccent;
      default: return Colors.white;
    }
  }

  String _getMealTitle(int index) {
    switch (index % 4) {
      case 0: return 'Завтрак';
      case 1: return 'Обед';
      case 2: return 'Ужин';
      case 3: return 'Перекус';
      default: return 'Приём пищи ${index + 1}';
    }
  }

  int _getMealCalories(MealGroup meal) {
    return meal.items.fold(0, (sum, item) => sum + (item.calories ?? 0));
  }

  int _calculateTotalCalories(List<MealGroup> meals) {
    return meals.fold(0, (sum, meal) => sum + _getMealCalories(meal));
  }

  void _addMeal() {
    // Показываем диалог для ввода названия нового приёма пищи
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) {
        String mealName = '';
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusXL),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(kSpaceLG),
                decoration: BoxDecoration(
                  color: kNoirGraphite.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(kRadiusXL),
                  border: Border.all(color: kNoirSteel.withOpacity(0.5)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Добавить приём пищи', style: kNoirTitleMedium.copyWith(color: kContentHigh)),
                      const SizedBox(height: kSpaceMD),
                      TextField(
                        autofocus: true,
                        onChanged: (value) => mealName = value,
                        style: kNoirBodyMedium.copyWith(color: kContentHigh),
                        decoration: InputDecoration(
                          hintText: 'Название (например, Перекус)',
                          hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
                          filled: true,
                          fillColor: kNoirBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            borderSide: BorderSide(color: kBorderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            borderSide: BorderSide(color: kBorderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            borderSide: const BorderSide(color: kContentHigh),
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpaceLG),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(foregroundColor: kContentMedium),
                              child: const Text('Отмена'),
                            ),
                          ),
                          const SizedBox(width: kSpaceMD),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (mealName.trim().isNotEmpty) {
                                  ref.read(mealScheduleProvider.notifier).addMeal(mealName.trim());
                                  Navigator.pop(ctx);
                                  final l10n = AppLocalizations.of(context)!;
                                  NoirToast.success(context, l10n.mealAdded);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kContentHigh,
                                foregroundColor: kNoirBlack,
                                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMD)),
                              ),
                              child: const Text('Добавить'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _renameMeal(int index, String currentName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) {
        String newName = currentName;
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusXL),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(kSpaceLG),
                decoration: BoxDecoration(
                  color: kNoirGraphite.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(kRadiusXL),
                  border: Border.all(color: kNoirSteel.withOpacity(0.5)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Переименовать приём пищи', style: kNoirTitleMedium.copyWith(color: kContentHigh)),
                      const SizedBox(height: kSpaceMD),
                      TextField(
                        controller: TextEditingController(text: currentName),
                        autofocus: true,
                        onChanged: (value) => newName = value,
                        style: kNoirBodyMedium.copyWith(color: kContentHigh),
                        decoration: InputDecoration(
                          hintText: 'Название',
                          hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
                          filled: true,
                          fillColor: kNoirBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            borderSide: BorderSide(color: kBorderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            borderSide: BorderSide(color: kBorderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            borderSide: const BorderSide(color: kContentHigh),
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpaceLG),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(foregroundColor: kContentMedium),
                              child: const Text('Отмена'),
                            ),
                          ),
                          const SizedBox(width: kSpaceMD),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (newName.trim().isNotEmpty) {
                                  ref.read(mealScheduleProvider.notifier).renameMeal(index, newName.trim());
                                  Navigator.pop(ctx);
                                  final l10n = AppLocalizations.of(context)!;
                                  NoirToast.success(context, l10n.mealRenamed, subtitle: l10n.nameChangedTo(newName.trim()));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kContentHigh,
                                foregroundColor: kNoirBlack,
                                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMD)),
                              ),
                              child: const Text('Сохранить'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteMeal(int index, String mealName) async {
    final confirmed = await NoirGlassDialog.showConfirmation(
      context,
      title: 'Удалить приём пищи?',
      content: 'Вы уверены, что хотите удалить "$mealName"?',
      icon: Icons.delete_rounded,
      confirmText: 'Удалить',
      cancelText: 'Отмена',
      isDestructive: true,
    );
    
    if (confirmed == true) {
      ref.read(mealScheduleProvider.notifier).removeMeal(index);
      final l10n = AppLocalizations.of(context)!;
      NoirToast.info(context, l10n.deleted);
    }
  }

  Future<void> _takeFridgePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(fridgeProvider.notifier).setImagePath(image.path);
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          NoirToast.success(context, l10n.photoUploaded);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        NoirToast.error(context, l10n.error);
      }
    }
  }
}