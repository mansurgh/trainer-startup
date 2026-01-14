// lib/screens/tabs/widgets/edit_dish_dialog.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../../../theme/noir_theme.dart';
import '../../../widgets/noir_glass_components.dart';
import '../../../models/meal.dart';
import '../../../services/meal_service.dart';
import '../nutrition_screen_v2.dart';
import '../../../widgets/app_alert.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    l10n.editDish,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Название блюда
                  _buildNoirTextField(l10n.dishName, _nameController),
                  const SizedBox(height: 12),

                  // Калории
                  _buildNoirTextField('${l10n.calories} (${l10n.kcal})', _caloriesController, isNumber: true),
                  const SizedBox(height: 12),

                  // БЖУ
                  Row(
                    children: [
                      Expanded(child: _buildNoirTextField(l10n.protein, _proteinController, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildNoirTextField(l10n.fat, _fatController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoirTextField(l10n.carbs, _carbsController, isNumber: true),
                  
                  const SizedBox(height: 20),
                  
                  // Replace with mock button
                  OutlinedButton.icon(
                    onPressed: _replaceDishWithMock,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.replaceDish),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Buttons row
                  Row(
                    children: [
                      // Delete button
                      IconButton(
                        onPressed: _deleteDish,
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                        tooltip: l10n.delete,
                      ),
                      const Spacer(),
                      // Cancel
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: Colors.white60),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      // Save
                      ElevatedButton(
                        onPressed: _saveDish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(l10n.save),
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
  }
  
  void _replaceDishWithMock() {
    // Replace with mock data based on original dish type
    final mockReplacements = {
      'курица': ('Индейка гриль', 165, 31.0, 3.5, 0.0),
      'chicken': ('Turkey Breast', 165, 31.0, 3.5, 0.0),
      'рис': ('Гречка отварная', 110, 4.0, 1.0, 21.0),
      'rice': ('Quinoa', 120, 4.4, 1.9, 21.3),
      'яйца': ('Омлет белковый', 55, 11.0, 0.5, 0.5),
      'eggs': ('Egg Whites', 52, 11.0, 0.2, 0.7),
      'творог': ('Йогурт греческий', 100, 10.0, 5.0, 4.0),
      'cottage': ('Greek Yogurt', 100, 10.0, 5.0, 3.6),
    };
    
    final currentName = _nameController.text.toLowerCase();
    String newName = 'Лосось на пару';
    int newCal = 208;
    double newP = 20.0, newF = 13.0, newC = 0.0;
    
    for (final entry in mockReplacements.entries) {
      if (currentName.contains(entry.key)) {
        newName = entry.value.$1;
        newCal = entry.value.$2;
        newP = entry.value.$3;
        newF = entry.value.$4;
        newC = entry.value.$5;
        break;
      }
    }
    
    setState(() {
      _nameController.text = newName;
      _caloriesController.text = newCal.toString();
      _proteinController.text = newP.toStringAsFixed(1);
      _fatController.text = newF.toStringAsFixed(1);
      _carbsController.text = newC.toStringAsFixed(1);
    });
  }
  
  Future<void> _deleteDish() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NoirGlassDialog.showConfirmation(
      context,
      title: l10n.deleteDish,
      content: l10n.deleteDishConfirm(widget.dish.name),
      icon: Icons.delete_rounded,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final service = ref.read(mealServiceProvider);
      await service.removeDishFromMeal(widget.mealId, widget.dish.id);
      ref.invalidate(mealsProvider);
      ref.invalidate(dailyTotalsProvider);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  
  Widget _buildNoirTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))] : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _saveDish() async {
    final l10n = AppLocalizations.of(context)!;
    // Валидация
    final name = _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final fat = double.tryParse(_fatController.text);
    final carbs = double.tryParse(_carbsController.text);

    if (name.isEmpty || calories == null || protein == null || fat == null || carbs == null) {
      AppAlert.show(context, title: l10n.pleaseFillAllFields, type: AlertType.warning);
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
    ref.invalidate(mealsProvider);
    ref.invalidate(dailyTotalsProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
