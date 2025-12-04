import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../../../models/meal.dart';
import '../../../l10n/app_localizations.dart';

/// Диалог редактирования блюда из плана холодильника
class EditFridgeDishDialog extends ConsumerStatefulWidget {
  final Dish dish;
  final Function(Dish updatedDish) onUpdate;
  final VoidCallback onDelete;
  final Function(String oldDishName) onReplace;

  const EditFridgeDishDialog({
    super.key,
    required this.dish,
    required this.onUpdate,
    required this.onDelete,
    required this.onReplace,
  });

  @override
  ConsumerState<EditFridgeDishDialog> createState() => _EditFridgeDishDialogState();
}

class _EditFridgeDishDialogState extends ConsumerState<EditFridgeDishDialog> {
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
    _proteinController = TextEditingController(text: widget.dish.protein.toInt().toString());
    _fatController = TextEditingController(text: widget.dish.fat.toInt().toString());
    _carbsController = TextEditingController(text: widget.dish.carbs.toInt().toString());
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

  void _save() {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      _showError(AppLocalizations.of(context)!.enterDishName);
      return;
    }

    final calories = int.tryParse(_caloriesController.text);
    if (calories == null || calories < 0) {
      _showError(AppLocalizations.of(context)!.enterValidCalories);
      return;
    }

    final protein = double.tryParse(_proteinController.text);
    if (protein == null || protein < 0) {
      _showError(AppLocalizations.of(context)!.enterValidProtein);
      return;
    }

    final fat = double.tryParse(_fatController.text);
    if (fat == null || fat < 0) {
      _showError(AppLocalizations.of(context)!.enterValidFat);
      return;
    }

    final carbs = double.tryParse(_carbsController.text);
    if (carbs == null || carbs < 0) {
      _showError(AppLocalizations.of(context)!.enterValidCarbs);
      return;
    }

    final updatedDish = Dish(
      id: widget.dish.id,
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      isCompleted: widget.dish.isCompleted,
    );

    widget.onUpdate(updatedDish);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dish updated'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignTokens.surface,
        title: const Text(
          'Delete Dish?',
          style: DesignTokens.h3,
        ),
        content: const Text(
          'Are you sure you want to delete this dish?',
          style: DesignTokens.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: DesignTokens.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрываем confirm dialog
              Navigator.pop(context); // Закрываем edit dialog
              widget.onDelete();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dish deleted'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog() {
    final replaceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignTokens.surface,
        title: Text(
          'Replace Dish',
          style: DesignTokens.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the name of the new dish to replace "${widget.dish.name}"',
              style: DesignTokens.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replaceController,
              style: const TextStyle(color: DesignTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'New dish name',
                hintStyle: TextStyle(color: DesignTokens.textSecondary),
                filled: true,
                fillColor: DesignTokens.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: DesignTokens.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final newDishName = replaceController.text.trim();
              if (newDishName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a dish name'),
                    backgroundColor: DesignTokens.error,
                  ),
                );
                return;
              }
              
              Navigator.pop(context); // Закрываем replace dialog
              Navigator.pop(context); // Закрываем edit dialog
              widget.onReplace(widget.dish.name);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Replacement requested'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Replace',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
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
              // Заголовок
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Dish',
                      style: DesignTokens.h2.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: DesignTokens.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Поле названия
              _buildTextField(
                controller: _nameController,
                label: 'Dish Name',
                icon: Icons.restaurant_menu,
                keyboardType: TextInputType.text,
              ),
              
              const SizedBox(height: 16),
              
              // Калории
              _buildTextField(
                controller: _caloriesController,
                label: 'Calories (kcal)',
                icon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Белки
              _buildTextField(
                controller: _proteinController,
                label: 'Protein (g)',
                icon: Icons.egg_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Жиры
              _buildTextField(
                controller: _fatController,
                label: 'Fat (g)',
                icon: Icons.water_drop_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Углеводы
              _buildTextField(
                controller: _carbsController,
                label: 'Carbs (g)',
                icon: Icons.grain,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 24),
              
              // Кнопка замены блюда
              OutlinedButton.icon(
                onPressed: _showReplaceDialog,
                icon: const Icon(Icons.swap_horiz, size: 20),
                label: const Text('Replace with another dish'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Кнопки действий
              Row(
                children: [
                  // Кнопка удаления
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignTokens.error,
                        side: const BorderSide(color: DesignTokens.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Кнопка сохранения
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.textPrimary,
                        foregroundColor: DesignTokens.bgBase,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignTokens.bodySmall.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: DesignTokens.textPrimary,
            fontSize: 15,
          ),
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: DesignTokens.textSecondary, size: 20),
            filled: true,
            fillColor: DesignTokens.cardSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
