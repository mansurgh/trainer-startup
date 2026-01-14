// =============================================================================
// history_widgets.dart — 7-Day History Visualization Widgets
// =============================================================================
// Compact visual indicators for workout and nutrition history
// Shows last 7 days with dots (workouts) and bars (nutrition)
// Noir Glass monochrome styling
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/noir_theme.dart';
import '../services/stats_service.dart';
import '../services/translation_service.dart';
import '../l10n/app_localizations.dart';
import 'noir_glass_components.dart';

// =============================================================================
// Providers for History Data
// =============================================================================

final workoutHistoryProvider = FutureProvider<List<WorkoutDayStatus>>((ref) async {
  final service = StatsService();
  return service.getWorkoutHistory7Days();
});

final nutritionHistoryProvider = FutureProvider<List<NutritionDayStatus>>((ref) async {
  final service = StatsService();
  return service.getNutritionHistory7Days();
});

// =============================================================================
// Workout History Widget — 7 Dots
// =============================================================================

class WorkoutHistoryWidget extends ConsumerWidget {
  const WorkoutHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return NoirGlassContainer(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.fitness_center_rounded, color: kContentMedium, size: 18),
              const SizedBox(width: kSpaceSM),
              Text(
                l10n.workoutsLabel,
                style: kNoirBodyMedium.copyWith(color: kContentMedium),
              ),
              const Spacer(),
              Text(
                l10n.last7Days,
                style: kNoirBodySmall.copyWith(color: kContentLow),
              ),
            ],
          ),
          const SizedBox(height: kSpaceMD),
          
          // Dots row
          historyAsync.when(
            data: (history) => _buildDotsRow(history),
            loading: () => _buildLoadingDots(),
            error: (_, __) => _buildEmptyDots(),
          ),
          
          const SizedBox(height: kSpaceSM),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(kContentHigh, l10n.completed),
              const SizedBox(width: kSpaceMD),
              _buildLegendItem(kContentLow.withOpacity(0.3), l10n.missed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDotsRow(List<WorkoutDayStatus> history) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: history.map((day) => _buildDot(day)).toList(),
    );
  }

  Widget _buildDot(WorkoutDayStatus day) {
    final isToday = day.status == WorkoutStatus.today;
    final isFuture = day.status == WorkoutStatus.future;
    final isCompleted = day.status == WorkoutStatus.completed;
    
    return Tooltip(
      message: _formatDate(day.date),
      child: Column(
        children: [
          // Day label
          Text(
            _getDayLabel(day.date, context),
            style: kNoirBodySmall.copyWith(
              color: isToday ? kContentHigh : kContentLow,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: kSpaceXS),
          // Dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isToday ? 14 : 12,
            height: isToday ? 14 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFuture
                  ? Colors.transparent
                  : isCompleted
                      ? kContentHigh
                      : kContentLow.withOpacity(0.2),
              border: Border.all(
                color: isFuture
                    ? kContentLow.withOpacity(0.3)
                    : isToday
                        ? kContentHigh
                        : Colors.transparent,
                width: isToday ? 2 : 1,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: kContentHigh.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: isCompleted && day.workoutCount != null && day.workoutCount! > 1
                ? Center(
                    child: Text(
                      '${day.workoutCount}',
                      style: kNoirBodySmall.copyWith(
                        color: kNoirBlack,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kContentLow.withOpacity(0.1),
        ),
      )),
    );
  }

  Widget _buildEmptyDots() => _buildLoadingDots();

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: kNoirBodySmall.copyWith(color: kContentLow),
        ),
      ],
    );
  }

  String _getDayLabel(DateTime date, BuildContext context) {
    final englishDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final englishDay = englishDays[date.weekday - 1];
    return TranslationService.translateDayShort(englishDay, context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}';
  }
}

// =============================================================================
// Nutrition History Widget — 7 Bars (Clickable)
// =============================================================================

class NutritionHistoryWidget extends ConsumerWidget {
  const NutritionHistoryWidget({super.key, this.onDayTap});
  
  /// Callback when a day bar is tapped. If null, shows built-in day detail sheet.
  final void Function(DateTime date)? onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(nutritionHistoryProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return NoirGlassContainer(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.restaurant_rounded, color: kContentMedium, size: 18),
              const SizedBox(width: kSpaceSM),
              Text(
                l10n.nutrition,
                style: kNoirBodyMedium.copyWith(color: kContentMedium),
              ),
              const Spacer(),
              Text(
                l10n.last7Days,
                style: kNoirBodySmall.copyWith(color: kContentLow),
              ),
            ],
          ),
          const SizedBox(height: kSpaceMD),
          
          // Bars row
          historyAsync.when(
            data: (history) => _buildBarsRow(context, history),
            loading: () => _buildLoadingBars(),
            error: (_, __) => _buildEmptyBars(),
          ),
          
          const SizedBox(height: kSpaceSM),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(kContentHigh, '90-110%'),
              const SizedBox(width: kSpaceXS),
              _buildLegendItem(kContentMedium, '70-90%'),
              const SizedBox(width: kSpaceXS),
              _buildLegendItem(kContentLow.withOpacity(0.3), '<70%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarsRow(BuildContext context, List<NutritionDayStatus> history) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.map((day) => _buildBar(context, day)).toList(),
      ),
    );
  }

  Widget _buildBar(BuildContext context, NutritionDayStatus day) {
    final isToday = day.status == NutritionStatus.today;
    final isFuture = day.status == NutritionStatus.future;
    final percentage = day.caloriePercentage ?? 0.0;
    
    // Calculate bar height (min 4, max 40)
    final barHeight = isFuture ? 4.0 : (4 + (percentage.clamp(0.0, 1.2) * 36));
    
    // Determine bar color based on percentage
    final barColor = isFuture
        ? kContentLow.withOpacity(0.2)
        : percentage >= 0.9 && percentage <= 1.1
            ? kContentHigh
            : percentage >= 0.7
                ? kContentMedium
                : kContentLow.withOpacity(0.3);
    
    return GestureDetector(
      onTap: isFuture ? null : () => _onBarTap(context, day),
      child: Tooltip(
        message: '${_formatDate(day.date)}: ${(percentage * 100).toInt()}%',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isToday ? 16 : 12,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(kRadiusSM),
                border: isToday
                    ? Border.all(color: kContentHigh, width: 1.5)
                    : null,
                boxShadow: percentage >= 0.9 && !isFuture
                    ? [
                        BoxShadow(
                          color: kContentHigh.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: kSpaceXS),
            // Day label
            Text(
              _getDayLabel(day.date, context),
              style: kNoirBodySmall.copyWith(
                color: isToday ? kContentHigh : kContentLow,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _onBarTap(BuildContext context, NutritionDayStatus day) {
    HapticFeedback.lightImpact();
    if (onDayTap != null) {
      onDayTap!(day.date);
    } else {
      _showDayDetailSheet(context, day);
    }
  }
  
  void _showDayDetailSheet(BuildContext context, NutritionDayStatus day) {
    final percentage = (day.caloriePercentage ?? 0) * 100;
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _NutritionDayDetailSheet(
        date: day.date,
        percentage: percentage,
        l10n: l10n,
      ),
    );
  }

  Widget _buildLoadingBars() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) => Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: kContentLow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(kRadiusSM),
          ),
        )),
      ),
    );
  }

  Widget _buildEmptyBars() => _buildLoadingBars();

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: kNoirBodySmall.copyWith(color: kContentLow, fontSize: 10),
        ),
      ],
    );
  }

  String _getDayLabel(DateTime date, BuildContext context) {
    final englishDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final englishDay = englishDays[date.weekday - 1];
    return TranslationService.translateDayShort(englishDay, context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}';
  }
}

// =============================================================================
// Combined History Row — Both widgets side by side
// =============================================================================

class CombinedHistoryRow extends StatelessWidget {
  const CombinedHistoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: WorkoutHistoryWidget()),
        SizedBox(width: kSpaceMD),
        Expanded(child: NutritionHistoryWidget()),
      ],
    );
  }
}

// =============================================================================
// Nutrition Day Detail Sheet — Shows details when bar is tapped
// =============================================================================

class _NutritionDayDetailSheet extends StatelessWidget {
  const _NutritionDayDetailSheet({
    required this.date,
    required this.percentage,
    required this.l10n,
  });
  
  final DateTime date;
  final double percentage;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Use TranslationService for localized day names
    final englishDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final englishDay = englishDays[date.weekday - 1];
    final dayName = TranslationService.translateDayShort(englishDay, context);
    
    // Localized month names
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    final monthNamesRu = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final monthNamesEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthName = isRussian ? monthNamesRu[date.month - 1] : monthNamesEn[date.month - 1];
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(kSpaceLG),
          decoration: BoxDecoration(
            color: kNoirCarbon.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
            border: Border.all(color: kNoirSteel.withOpacity(0.3)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kContentLow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: kSpaceLG),
                
                // Date header
                Text(
                  '$dayName, ${date.day} $monthName',
                  style: kNoirTitleLarge.copyWith(color: kContentHigh),
                ),
                const SizedBox(height: kSpaceMD),
                
                // Percentage indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpaceLG,
                    vertical: kSpaceMD,
                  ),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusMD),
                    border: Border.all(
                      color: _getPercentageColor(percentage).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${percentage.round()}%',
                        style: kNoirDisplayMedium.copyWith(
                          color: _getPercentageColor(percentage),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceXS),
                      Text(
                        l10n.calorieGoal,
                        style: kNoirBodyMedium.copyWith(color: kContentMedium),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kSpaceMD),
                
                // Status message
                Text(
                  _getStatusMessage(percentage),
                  style: kNoirBodyMedium.copyWith(color: kContentMedium),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpaceLG),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getPercentageColor(double percentage) {
    if (percentage >= 90 && percentage <= 110) return kContentHigh;
    if (percentage >= 70) return kContentMedium;
    return kContentLow;
  }
  
  String _getStatusMessage(double percentage) {
    if (percentage >= 90 && percentage <= 110) {
      return 'Отлично! Цель достигнута 🎯';
    } else if (percentage > 110) {
      return 'Немного превышен лимит';
    } else if (percentage >= 70) {
      return 'Почти у цели!';
    } else if (percentage > 0) {
      return 'Нужно больше питания';
    } else {
      return 'Нет данных за этот день';
    }
  }
}
