import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../../../theme/noir_theme.dart';
import '../../../widgets/noir_glass_components.dart';
import '../../../models/meal.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/noir_toast_service.dart';

/// Диалог редактирования блюда из плана холодильника
class EditFridgeDishDialog extends ConsumerStatefulWidget {
  final Dish dish;
  final Function(Dish updatedDish) onUpdate;
  final VoidCallback onDelete;
  final Function(String newDishName) onReplace;

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
    
    final l10n = AppLocalizations.of(context)!;
    NoirToast.success(context, l10n.updated);
  }

  void _showError(String message) {
    NoirToast.error(context, message);
  }

  void _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NoirGlassDialog.showConfirmation(
      context,
      title: l10n.deletePhotoConfirm,
      content: l10n.actionCannotBeUndone,
      icon: Icons.delete_rounded,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );
    
    if (confirmed == true && mounted) {
      Navigator.pop(context); // Закрываем edit dialog
      widget.onDelete();
      
      NoirToast.info(context, l10n.deleted);
    }
  }

  void _showReplaceDialog() {
    final replaceController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: l10n.replaceDish,
        content: '${l10n.enterNewDishName} "${widget.dish.name}"',
        icon: Icons.swap_horiz_rounded,
        contentWidget: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextField(
            controller: replaceController,
            style: TextStyle(color: kContentHigh),
            decoration: InputDecoration(
              hintText: l10n.newDishName,
              hintStyle: TextStyle(color: kContentLow),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        confirmText: l10n.replace,
        cancelText: l10n.cancel,
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () {
          final newDishName = replaceController.text.trim();
          if (newDishName.isEmpty) {
            NoirToast.error(context, l10n.enterDishName);
            return;
          }
          
          Navigator.pop(ctx); // Закрываем replace dialog
          Navigator.pop(context); // Закрываем edit dialog
          widget.onReplace(newDishName);
          
          NoirToast.success(context, l10n.updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: kNoirGraphite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusXL),
      ),
      child: Material(
        color: Colors.transparent,
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
                      l10n.editDish,
                      style: kNoirTitleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: kContentHigh,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kContentMedium),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Поле названия
              _buildTextField(
                controller: _nameController,
                label: l10n.dishName,
                icon: Icons.restaurant_menu,
                keyboardType: TextInputType.text,
              ),
              
              const SizedBox(height: 16),
              
              // Калории
              _buildTextField(
                controller: _caloriesController,
                label: '${l10n.calories} (${l10n.kcal})',
                icon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Белки
              _buildTextField(
                controller: _proteinController,
                label: '${l10n.protein} (${l10n.grams})',
                icon: Icons.egg_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Жиры
              _buildTextField(
                controller: _fatController,
                label: '${l10n.fat} (${l10n.grams})',
                icon: Icons.water_drop_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Углеводы
              _buildTextField(
                controller: _carbsController,
                label: '${l10n.carbs} (${l10n.grams})',
                icon: Icons.grain,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 24),
              
              // Кнопка замены блюда
              OutlinedButton.icon(
                onPressed: _showReplaceDialog,
                icon: const Icon(Icons.swap_horiz, size: 20),
                label: Text(l10n.replaceWithAnotherDish),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kContentHigh,
                  side: const BorderSide(color: kContentMedium),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusMD),
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
                      label: Text(l10n.delete),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF87171),
                        side: const BorderSide(color: Color(0xFFF87171)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD),
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
                      label: Text(l10n.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kContentHigh,
                        foregroundColor: kNoirBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD),
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
          style: kNoirBodySmall.copyWith(
            color: kContentMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: kNoirBodyMedium.copyWith(color: kContentHigh),
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: kContentMedium, size: 20),
            filled: true,
            fillColor: kNoirBlack,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMD),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
