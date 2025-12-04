// lib/screens/tabs/widgets/edit_dish_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../../../models/meal.dart';
import '../../../services/meal_service.dart';
import '../nutrition_screen_v2.dart';
import '../../../widgets/app_alert.dart';

class EditDishDialog extends ConsumerStatefulWidget {
  final Dish dish;
  final String mealId;

  const EditDishDialog({
    super.key,
    required this.dish,
    required this.mealId,
  });

  @override
  ConsumerState<EditDishDialog> createState() => _EditDishDialogState();
}

class _EditDishDialogState extends ConsumerState<EditDishDialog> {
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dish.name);
    _caloriesController = TextEditingController(text: widget.dish.calories.toString());
    _proteinController = TextEditingController(text: widget.dish.protein.toStringAsFixed(1));
    _fatController = TextEditingController(text: widget.dish.fat.toStringAsFixed(1));
    _carbsController = TextEditingController(text: widget.dish.carbs.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignTokens.cardSurface,
      title: Text('Edit Dish', style: DesignTokens.h3),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Название блюда
            _buildTextField(
              controller: _nameController,
              label: 'Dish Name',
              icon: Icons.restaurant,
            ),
            const SizedBox(height: 16),

            // Калории
            _buildTextField(
              controller: _caloriesController,
              label: 'Calories (kcal)',
              icon: Icons.local_fire_department,
              isNumber: true,
            ),
            const SizedBox(height: 16),

            // БЖУ в одну строку
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _proteinController,
                    label: 'Protein (g)',
                    icon: Icons.egg,
                    isNumber: true,
                    isDecimal: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    controller: _fatController,
                    label: 'Fat (g)',
                    icon: Icons.water_drop,
                    isNumber: true,
                    isDecimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _carbsController,
              label: 'Carbs (g)',
              icon: Icons.grass,
              isNumber: true,
              isDecimal: true,
            ),
          ],
        ),
      ),
      actions: [
        // Кнопка удаления
        TextButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: DesignTokens.cardSurface,
                title: Text('Delete Dish?', style: DesignTokens.h3),
                content: Text(
                  'Are you sure you want to delete "${widget.dish.name}"?',
                  style: DesignTokens.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              final service = ref.read(mealServiceProvider);
              await service.removeDishFromMeal(widget.mealId, widget.dish.id);
              ref.invalidate(mealsProvider);
              ref.invalidate(dailyTotalsProvider);
              // Форсируем обновление
              await Future.delayed(const Duration(milliseconds: 100));
              
              if (mounted) {
                Navigator.pop(context);
                AppAlert.show(
                  context,
                  title: 'Dish deleted',
                  type: AlertType.warning,
                  duration: const Duration(seconds: 3),
                );
              }
            }
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        const Spacer(),

        // Кнопки Cancel и Save
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveDish,
          style: FilledButton.styleFrom(
            backgroundColor: DesignTokens.primaryAccent,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return TextField(
      controller: controller,
      style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.textPrimary),
      keyboardType: isNumber
          ? (isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [
              if (!isDecimal) FilteringTextInputFormatter.digitsOnly,
              if (isDecimal) FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: DesignTokens.bodyMedium.copyWith(
          color: DesignTokens.textSecondary,
        ),
        prefixIcon: Icon(icon, color: DesignTokens.textSecondary, size: 20),
        filled: true,
        fillColor: DesignTokens.bgBase,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: DesignTokens.textSecondary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: DesignTokens.primaryAccent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _saveDish() async {
    // Валидация
    final name = _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final fat = double.tryParse(_fatController.text);
    final carbs = double.tryParse(_carbsController.text);

    if (name.isEmpty) {
      _showError('Please enter dish name');
      return;
    }

    if (calories == null || calories <= 0) {
      _showError('Please enter valid calories');
      return;
    }

    if (protein == null || protein < 0) {
      _showError('Please enter valid protein amount');
      return;
    }

    if (fat == null || fat < 0) {
      _showError('Please enter valid fat amount');
      return;
    }

    if (carbs == null || carbs < 0) {
      _showError('Please enter valid carbs amount');
      return;
    }

    // Обновляем блюдо
    final updatedDish = widget.dish.copyWith(
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );

    final service = ref.read(mealServiceProvider);
    await service.updateDish(widget.mealId, updatedDish);
    
    // Форсируем полное обновление
    ref.invalidate(mealsProvider);
    ref.invalidate(dailyTotalsProvider);
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      Navigator.pop(context);
      AppAlert.show(
        context,
        title: '${updatedDish.name} updated',
        type: AlertType.success,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showError(String message) {
    AppAlert.show(
      context,
      title: 'Error',
      description: message,
      type: AlertType.error,
      duration: const Duration(seconds: 3),
    );
  }
}
