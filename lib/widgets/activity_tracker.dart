// lib/widgets/activity_tracker.dart

import 'package:flutter/material.dart';
import '../models/activity_day.dart';
import '../core/design_tokens.dart';
import '../l10n/app_localizations.dart';

class ActivityTracker extends StatelessWidget {
  final List<ActivityDay> activityDays;

  const ActivityTracker({
    super.key,
    required this.activityDays,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Generate days for the current month
    final displayDays = _generateMonthDays(activityDays);
    final daysInMonth = displayDays.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignTokens.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.activityLabel,
                style: DesignTokens.h3.copyWith(
                  color: DesignTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_getCompletedDays(displayDays)}/$daysInMonth ${l10n.activityDays}',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid 7 columns (calendar style)
          _buildActivityGrid(context, displayDays),
          
          const SizedBox(height: 12),
          
          // Legend
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildActivityGrid(BuildContext context, List<ActivityDay> days) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days a week
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return _buildActivitySquare(context, day);
      },
    );
  }

  Widget _buildActivitySquare(BuildContext context, ActivityDay day) {
    final color = Color(day.status.colorValue);
    
    return Tooltip(
      message: '${_formatDate(day.date)}\n${_getStatusText(context, day)}',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(l10n.all, const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        _buildLegendItem(l10n.partial, const Color(0xFFFFC107)),
        const SizedBox(width: 12),
        _buildLegendItem(l10n.missed, const Color(0xFF424242)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: DesignTokens.bodySmall.copyWith(
            color: DesignTokens.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  int _getCompletedDays(List<ActivityDay> days) {
    // Считаем и полные, и частичные дни как активность
    return days.where((day) => day.status == ActivityStatus.completed || day.status == ActivityStatus.partial).length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(BuildContext context, ActivityDay day) {
    final l10n = AppLocalizations.of(context)!;
    if (day.workoutCompleted && day.nutritionGoalMet) {
      return l10n.workoutAndNutritionCheck;
    } else if (day.workoutCompleted) {
      return l10n.workoutCheck;
    } else if (day.nutritionGoalMet) {
      return l10n.nutritionCheck;
    } else {
      return l10n.noActivity;
    }
  }

  List<ActivityDay> _generateMonthDays(List<ActivityDay> existingDays) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    final result = <ActivityDay>[];
    
    for (int i = 0; i < daysInMonth; i++) {
      final date = firstDayOfMonth.add(Duration(days: i));
      
      // Find existing day or create empty
      final existingDay = existingDays.firstWhere(
        (d) => d.date.year == date.year && d.date.month == date.month && d.date.day == date.day,
        orElse: () => ActivityDay(
          date: date,
          workoutCompleted: false,
          nutritionGoalMet: false,
        ),
      );
      
      result.add(existingDay);
    }
    
    return result;
  }
}
