import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/design_tokens.dart';
import '../../../models/meal.dart';
import '../../../services/meal_service.dart';
import '../../../widgets/app_alert.dart';
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
    if (_nameController.text.isEmpty) {
      AppAlert.show(
        context,
        title: 'Missing information',
        description: 'Please enter a dish name',
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
    return Dialog(
      backgroundColor: DesignTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Dish',
                style: DesignTokens.h2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildTextField('Dish name', _nameController),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Calories', _caloriesController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Protein (g)', _proteinController, isNumber: true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Fat (g)', _fatController, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Carbs (g)', _carbsController, isNumber: true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignTokens.textSecondary,
                        side: BorderSide(color: DesignTokens.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.textPrimary,
                        foregroundColor: DesignTokens.bgBase,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add'),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: DesignTokens.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: DesignTokens.textSecondary),
        filled: true,
        fillColor: DesignTokens.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DesignTokens.textPrimary, width: 2),
        ),
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
        onReplace: (oldDishName) {
          // В реальном приложении здесь будет запрос к AI для замены блюда
          AppAlert.show(
            context,
            title: 'Replacement requested',
            description: 'AI will suggest a replacement for "$oldDishName"',
            type: AlertType.info,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DesignTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.fridgeBasedMealPlan,
                style: DesignTokens.h2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a photo of your fridge and AI will suggest meals',
                style: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Фото холодильника
              if (_selectedImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                    color: DesignTokens.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignTokens.textSecondary.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen_outlined,
                          size: 48,
                          color: DesignTokens.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No photo selected',
                          style: TextStyle(color: DesignTokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Кнопка выбора фото
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignTokens.textPrimary,
                  side: BorderSide(color: DesignTokens.textPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              if (_selectedImagePath != null && _generatedDishes.isEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateMealPlan,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate Meal Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.textPrimary,
                    foregroundColor: DesignTokens.bgBase,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              
              // Сгенерированные блюда
              if (_generatedDishes.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Generated Dishes',
                  style: DesignTokens.h3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                ..._generatedDishes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dish = entry.value;
                  
                  return GestureDetector(
                    onTap: () => _showEditDishDialog(dish, index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DesignTokens.cardSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: DesignTokens.textSecondary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dish.name,
                                  style: DesignTokens.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
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
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: DesignTokens.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DesignTokens.textSecondary,
                          side: BorderSide(color: DesignTokens.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyMealPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.textPrimary,
                          foregroundColor: DesignTokens.bgBase,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ] else if (_selectedImagePath == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
