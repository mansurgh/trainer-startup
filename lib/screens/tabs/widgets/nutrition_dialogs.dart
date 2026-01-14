import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/design_tokens.dart';
import '../../../core/translation_service.dart';
import '../../../models/meal.dart';
import '../../../services/meal_service.dart';
import '../../../widgets/app_alert.dart';
import '../../../widgets/noir_glass_components.dart';
import '../../../theme/noir_theme.dart';
import '../nutrition_screen_v2.dart';
import './edit_fridge_dish_dialog.dart';
import '../../../l10n/app_localizations.dart';

// Диалог добавления блюда
class AddDishDialog extends ConsumerStatefulWidget {
  final String mealId;
  final MealType mealType;

  const AddDishDialog({super.key, required this.mealId, required this.mealType});

  @override
  ConsumerState<AddDishDialog> createState() => AddDishDialogState();
}

class AddDishDialogState extends ConsumerState<AddDishDialog> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _saveDish() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_nameController.text.isEmpty) {
      AppAlert.show(
        context,
        title: l10n.enterDishName,
        description: l10n.enterDishName,
        type: AlertType.warning,
      );
      return;
    }

    final dish = Dish(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      calories: int.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      isCompleted: false,
    );

    final service = ref.read(mealServiceProvider);
    await service.addDishToMeal(widget.mealId, dish);
    
    ref.invalidate(mealsProvider);
    ref.invalidate(dailyTotalsProvider);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: kNoirGraphite.withOpacity(0.95),
                borderRadius: BorderRadius.circular(kRadiusXL),
                border: Border.all(color: kNoirSteel.withOpacity(0.5)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(kSpaceLG),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.addDish,
                        style: kNoirTitleMedium.copyWith(
                          color: kContentHigh,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: kSpaceLG),
                      _buildNoirTextField(l10n.dishName, _nameController),
                      const SizedBox(height: kSpaceMD),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNoirTextField('${l10n.calories} (${l10n.kcal})', _caloriesController, isNumber: true),
                          ),
                          const SizedBox(width: kSpaceSM),
                          Expanded(
                            child: _buildNoirTextField('${l10n.protein} (${l10n.grams})', _proteinController, isNumber: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceMD),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNoirTextField('${l10n.fat} (${l10n.grams})', _fatController, isNumber: true),
                          ),
                          const SizedBox(width: kSpaceSM),
                          Expanded(
                            child: _buildNoirTextField('${l10n.carbs} (${l10n.grams})', _carbsController, isNumber: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceLG),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kContentMedium,
                                side: BorderSide(color: kContentMedium.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusMD),
                                ),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: kSpaceMD),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveDish,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kContentHigh,
                                foregroundColor: kNoirBlack,
                                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusMD),
                                ),
                              ),
                              child: Text(l10n.save),
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
        ),
      ),
    );
  }

  Widget _buildNoirTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
      style: kNoirBodyMedium.copyWith(color: kContentHigh),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: kNoirBodySmall.copyWith(color: kContentLow),
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
          borderSide: const BorderSide(color: kContentHigh, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
      ),
    );
  }
}

// Диалог рациона по фото холодильника
class FridgeMealPlanDialog extends ConsumerStatefulWidget {
  const FridgeMealPlanDialog({super.key});

  @override
  ConsumerState<FridgeMealPlanDialog> createState() => FridgeMealPlanDialogState();
}

class FridgeMealPlanDialogState extends ConsumerState<FridgeMealPlanDialog> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _isGenerating = false;
  List<Dish> _generatedDishes = [];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppAlert.show(
          context,
          title: 'Failed to pick image',
          description: e.toString(),
          type: AlertType.error,
        );
      }
    }
  }

  Future<void> _generateMealPlan() async {
    if (_selectedImagePath == null) {
      AppAlert.show(
        context,
        title: 'No image selected',
        description: 'Please select a fridge photo first',
        type: AlertType.warning,
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Симуляция генерации (в реальном приложении здесь будет AI)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _generatedDishes = [
        Dish(
          id: 'gen_1',
          name: 'Grilled Chicken Salad',
          calories: 350,
          protein: 35,
          fat: 12,
          carbs: 25,
          isCompleted: false,
        ),
        Dish(
          id: 'gen_2',
          name: 'Vegetable Stir Fry',
          calories: 280,
          protein: 10,
          fat: 8,
          carbs: 45,
          isCompleted: false,
        ),
        Dish(
          id: 'gen_3',
          name: 'Fruit Smoothie',
          calories: 200,
          protein: 8,
          fat: 3,
          carbs: 38,
          isCompleted: false,
        ),
        Dish(
          id: 'gen_4',
          name: 'Greek Yogurt Bowl',
          calories: 220,
          protein: 18,
          fat: 6,
          carbs: 28,
          isCompleted: false,
        ),
      ];
      _isGenerating = false;
    });
  }

  Future<void> _applyMealPlan() async {
    final service = ref.read(mealServiceProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Добавляем блюда в разные приемы пищи
    final breakfastId = 'breakfast_${today.day}';
    final lunchId = 'lunch_${today.day}';
    final dinnerId = 'dinner_${today.day}';

    if (_generatedDishes.length >= 4) {
      await service.addDishToMeal(breakfastId, _generatedDishes[0]);
      await service.addDishToMeal(breakfastId, _generatedDishes[3]);
      await service.addDishToMeal(lunchId, _generatedDishes[1]);
      await service.addDishToMeal(dinnerId, _generatedDishes[2]);
    }

    ref.invalidate(mealsProvider);
    ref.invalidate(dailyTotalsProvider);

    if (mounted) {
      Navigator.pop(context);
      AppAlert.show(
        context,
        title: 'Meal plan applied',
        description: 'Your meals have been generated successfully!',
        type: AlertType.success,
      );
    }
  }
  
  void _showEditDishDialog(Dish dish, int index) {
    showDialog(
      context: context,
      builder: (context) => EditFridgeDishDialog(
        dish: dish,
        onUpdate: (updatedDish) {
          setState(() {
            _generatedDishes[index] = updatedDish;
          });
        },
        onDelete: () {
          setState(() {
            _generatedDishes.removeAt(index);
          });
        },
        onReplace: (newDishName) {
          // Создаём новое блюдо с тем же ID но новым именем
          setState(() {
            _generatedDishes[index] = Dish(
              id: dish.id,
              name: newDishName,
              calories: dish.calories,
              protein: dish.protein,
              fat: dish.fat,
              carbs: dish.carbs,
              isCompleted: dish.isCompleted,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRussian = TranslationService.isRussian(context);
    
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: kNoirGraphite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(kRadiusXL),
              border: Border.all(color: kNoirSteel.withOpacity(0.5)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(kSpaceLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.fridgeBasedMealPlan,
                      style: kNoirTitleMedium.copyWith(
                        color: kContentHigh,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: kSpaceSM),
                    Text(
                      isRussian 
                        ? 'Загрузите фото холодильника, и AI предложит блюда'
                        : 'Upload a photo of your fridge and AI will suggest meals',
                      style: kNoirBodySmall.copyWith(color: kContentLow),
                    ),
                    const SizedBox(height: kSpaceLG),
                    
                    // Фото холодильника
                    if (_selectedImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kRadiusMD),
                        child: Image.file(
                          File(_selectedImagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: kNoirBlack,
                          borderRadius: BorderRadius.circular(kRadiusMD),
                          border: Border.all(
                            color: kBorderLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.kitchen_outlined,
                                size: 48,
                                color: kContentLow,
                              ),
                              const SizedBox(height: kSpaceSM),
                              Text(
                                isRussian ? 'Фото не выбрано' : 'No photo selected',
                                style: kNoirBodySmall.copyWith(color: kContentLow),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: kSpaceMD),
                    
                    // Кнопка выбора фото
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(isRussian ? 'Выбрать фото' : 'Select Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kContentHigh,
                        side: const BorderSide(color: kContentHigh),
                        padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD),
                        ),
                      ),
                    ),
                    
                    if (_selectedImagePath != null && _generatedDishes.isEmpty) ...[
                      const SizedBox(height: kSpaceMD),
                      ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateMealPlan,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isGenerating 
                          ? (isRussian ? 'Генерация...' : 'Generating...') 
                          : (isRussian ? 'Сгенерировать рацион' : 'Generate Meal Plan')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kContentHigh,
                          foregroundColor: kNoirBlack,
                          padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kRadiusMD),
                          ),
                        ),
                      ),
                    ],
                    
                    // Сгенерированные блюда
                    if (_generatedDishes.isNotEmpty) ...[
                      const SizedBox(height: kSpaceLG),
                      Text(
                        isRussian ? 'Предложенные блюда' : 'Suggested Dishes',
                        style: kNoirTitleSmall.copyWith(
                          color: kContentHigh,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: kSpaceSM),
                      
                      ..._generatedDishes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dish = entry.value;
                        
                        return GestureDetector(
                          onTap: () => _showEditDishDialog(dish, index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: kSpaceSM),
                            padding: const EdgeInsets.all(kSpaceMD),
                            decoration: BoxDecoration(
                              color: kNoirBlack,
                              borderRadius: BorderRadius.circular(kRadiusMD),
                              border: Border.all(color: kBorderLight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        TranslationService.translateFood(dish.name, context),
                                        style: kNoirBodyMedium.copyWith(
                                          color: kContentHigh,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${dish.calories} ${l10n.kcal} • ${l10n.protein}: ${dish.protein.toInt()}${l10n.grams} ${l10n.fat}: ${dish.fat.toInt()}${l10n.grams} ${l10n.carbs}: ${dish.carbs.toInt()}${l10n.grams}',
                                        style: kNoirBodySmall.copyWith(color: kContentLow),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.edit_outlined, size: 18, color: kContentLow),
                              ],
                            ),
                          ),
                        );
                      }),
                      
                      const SizedBox(height: kSpaceMD),
                      
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kContentMedium,
                                side: BorderSide(color: kContentMedium.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusMD),
                                ),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: kSpaceMD),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyMealPlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kContentHigh,
                                foregroundColor: kNoirBlack,
                                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusMD),
                                ),
                              ),
                              child: Text(isRussian ? 'Применить' : 'Apply'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_selectedImagePath == null)
                      Padding(
                        padding: const EdgeInsets.only(top: kSpaceMD),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(foregroundColor: kContentMedium),
                          child: Text(isRussian ? 'Закрыть' : 'Close'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
