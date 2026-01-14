// =============================================================================
// nutrition_history_screen.dart — Full Nutrition History View
// =============================================================================
// Shows detailed nutrition history with daily breakdown
// Tap on day card to see meal details in a bottom sheet
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/noir_theme.dart';
import '../services/stats_service.dart';
import '../services/translation_service.dart';
import '../l10n/app_localizations.dart';

class NutritionHistoryScreen extends ConsumerStatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  ConsumerState<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends ConsumerState<NutritionHistoryScreen> {
  final _statsService = StatsService();
  List<Map<String, dynamic>> _nutritionData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNutritionHistory();
  }

  Future<void> _loadNutritionHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _statsService.getLast7DaysNutrition();
      if (mounted) {
        setState(() {
          _nutritionData = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      appBar: AppBar(
        backgroundColor: kNoirBlack,
        foregroundColor: kContentHigh,
        title: Text(l10n.nutritionHistory, style: kNoirTitleLarge),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kContentMedium),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: kContentMedium, size: 48),
                      const SizedBox(height: kSpaceMD),
                      Text(
                        l10n.error,
                        style: kNoirBodyLarge.copyWith(color: kContentMedium),
                      ),
                      const SizedBox(height: kSpaceMD),
                      ElevatedButton(
                        onPressed: _loadNutritionHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kNoirGraphite,
                          foregroundColor: kContentHigh,
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _nutritionData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            color: kContentLow,
                            size: 64,
                          ),
                          const SizedBox(height: kSpaceMD),
                          Text(
                            l10n.noNutritionData,
                            style: kNoirBodyLarge.copyWith(color: kContentMedium),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNutritionHistory,
                      color: kContentHigh,
                      backgroundColor: kNoirGraphite,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(kSpaceMD),
                        itemCount: _nutritionData.length,
                        itemBuilder: (context, index) {
                          final day = _nutritionData[index];
                          return _buildDayCard(day);
                        },
                      ),
                    ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final date = DateTime(
      day['year'] as int,
      day['month'] as int,
      day['day'] as int,
    );
    final calories = day['calories'] as int;
    final target = day['target'] as int;
    final percentage = target > 0 ? (calories / target * 100).round() : 0;
    
    final l10n = AppLocalizations.of(context)!;
    
    final dayNames = [
      l10n.mondayShort, l10n.tuesdayShort, l10n.wednesdayShort, 
      l10n.thursdayShort, l10n.fridayShort, l10n.saturdayShort, l10n.sundayShort
    ];
    final monthNames = [
      l10n.janShort, l10n.febShort, l10n.marShort, l10n.aprShort, 
      l10n.mayShort, l10n.junShort, l10n.julShort, l10n.augShort, 
      l10n.sepShort, l10n.octShort, l10n.novShort, l10n.decShort
    ];
    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpaceMD),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDayDetailSheet(date, dayName, monthName, calories, target);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusMD),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(kSpaceMD),
              decoration: BoxDecoration(
                color: kNoirGraphite.withOpacity(0.5),
                borderRadius: BorderRadius.circular(kRadiusMD),
                border: Border.all(color: kBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header with tap hint
                  Row(
                    children: [
                      Text(
                        '$dayName, ${date.day} $monthName',
                        style: kNoirTitleMedium.copyWith(color: kContentHigh),
                      ),
                      const SizedBox(width: kSpaceXS),
                      Icon(
                        Icons.chevron_right,
                        color: kContentLow,
                        size: 20,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpaceSM,
                          vertical: kSpaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getPercentageColor(percentage).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(kRadiusSM),
                        ),
                        child: Text(
                          '$percentage%',
                          style: kNoirBodySmall.copyWith(
                            color: _getPercentageColor(percentage),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceMD),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: kNoirSteel.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation(_getPercentageColor(percentage)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: kSpaceSM),
                  
                  // Calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$calories ${l10n.kcalUnit}',
                        style: kNoirBodyLarge.copyWith(
                          color: kContentHigh,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${l10n.outOf} $target ${l10n.kcalUnit}',
                        style: kNoirBodySmall.copyWith(color: kContentLow),
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

  /// Show bottom sheet with meals for the tapped day
  void _showDayDetailSheet(
    DateTime date, 
    String dayName, 
    String monthName, 
    int calories, 
    int target,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final sheetL10n = AppLocalizations.of(context)!;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLG)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: kNoirCarbon.withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLG)),
                    border: Border.all(color: kBorderLight),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: kSpaceSM),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kContentLow,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(kSpaceMD),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$dayName, ${date.day} $monthName',
                                    style: kNoirTitleLarge.copyWith(color: kContentHigh),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$calories ${sheetL10n.outOf} $target ${sheetL10n.kcalUnit}',
                                    style: kNoirBodyMedium.copyWith(color: kContentMedium),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: kContentMedium),
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(color: kBorderLight, height: 1),
                      
                      // Meals list
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _statsService.getMealsByDate(date),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(kContentMedium),
                                ),
                              );
                            }
                            
                            final meals = snapshot.data ?? [];
                            
                            if (meals.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_outlined,
                                      color: kContentLow,
                                      size: 48,
                                    ),
                                    const SizedBox(height: kSpaceMD),
                                    Text(
                                      sheetL10n.noMealsLogged,
                                      style: kNoirBodyLarge.copyWith(color: kContentMedium),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(kSpaceMD),
                              itemCount: meals.length,
                              itemBuilder: (context, index) {
                                return _buildMealCard(meals[index]);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build a meal card for the detail view
  Widget _buildMealCard(Map<String, dynamic> meal) {
    final isRussian = TranslationService.isRussian(context);
    
    final mealType = meal['meal_type'] as String? ?? 'Meal';
    final foodName = meal['food_name'] as String? ?? '';
    final calories = meal['calories'] as int? ?? 0;
    final protein = (meal['protein'] as num?)?.toDouble() ?? 0.0;
    final fat = (meal['fat'] as num?)?.toDouble() ?? 0.0;
    final carbs = (meal['carbs'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = meal['is_completed'] as bool? ?? false;
    
    // Translate meal type and food name
    final translatedMealType = TranslationService.translateMealType(mealType, context);
    final translatedFood = TranslationService.translateFood(foodName, context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpaceSM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(kSpaceMD),
            decoration: BoxDecoration(
              color: kNoirGraphite.withOpacity(0.6),
              borderRadius: BorderRadius.circular(kRadiusMD),
              border: Border.all(
                color: isCompleted ? kContentHigh.withOpacity(0.2) : kBorderLight,
              ),
            ),
            child: Row(
              children: [
                // Meal type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kNoirSteel.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(kRadiusSM),
                  ),
                  child: Icon(
                    _getMealIcon(mealType),
                    color: isCompleted ? kContentHigh : kContentMedium,
                    size: 22,
                  ),
                ),
                const SizedBox(width: kSpaceMD),
                
                // Meal info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translatedMealType,
                        style: kNoirBodySmall.copyWith(color: kContentMedium),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        translatedFood.isNotEmpty ? translatedFood : translatedMealType,
                        style: kNoirBodyLarge.copyWith(
                          color: kContentHigh,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isRussian ? 'Б' : 'P'}: ${protein.toInt()}${isRussian ? 'г' : 'g'} • '
                        '${isRussian ? 'Ж' : 'F'}: ${fat.toInt()}${isRussian ? 'г' : 'g'} • '
                        '${isRussian ? 'У' : 'C'}: ${carbs.toInt()}${isRussian ? 'г' : 'g'}',
                        style: kNoirCaption.copyWith(color: kContentLow),
                      ),
                    ],
                  ),
                ),
                
                // Calories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$calories',
                      style: kNoirTitleMedium.copyWith(color: kContentHigh),
                    ),
                    Text(
                      isRussian ? 'ккал' : 'kcal',
                      style: kNoirCaption.copyWith(color: kContentLow),
                    ),
                  ],
                ),
                
                // Completed indicator
                if (isCompleted) ...[
                  const SizedBox(width: kSpaceSM),
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4ADE80),
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.restaurant_outlined;
      case 'dinner':
        return Icons.nightlight_outlined;
      case 'snack':
      case 'snacks':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80 && percentage <= 120) {
      return const Color(0xFF4ADE80); // Green - on target
    } else if (percentage > 120) {
      return const Color(0xFFF87171); // Red - over
    } else {
      return kContentMedium; // Grey - under
    }
  }
}
