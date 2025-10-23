// lib/widgets/activity_tracker.dart

import 'package:flutter/material.dart';
import '../models/activity_day.dart';
import '../core/design_tokens.dart';

class ActivityTracker extends StatelessWidget {
  final List<ActivityDay> activityDays;

  const ActivityTracker({
    super.key,
    required this.activityDays,
  });

  @override
  Widget build(BuildContext context) {
    // Показываем последние 30 дней
    final displayDays = activityDays.length >= 30
        ? activityDays.sublist(activityDays.length - 30)
        : _generateMissingDays(activityDays, 30);

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
                'Activity',
                style: DesignTokens.h3.copyWith(
                  color: DesignTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_getCompletedDays(displayDays)}/30 days',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid 6x5 (30 квадратиков)
          _buildActivityGrid(displayDays),
          
          const SizedBox(height: 12),
          
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildActivityGrid(List<ActivityDay> days) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final day = days[index];
        return _buildActivitySquare(day);
      },
    );
  }

  Widget _buildActivitySquare(ActivityDay day) {
    final color = Color(day.status.colorValue);
    
    return Tooltip(
      message: '${_formatDate(day.date)}\n${_getStatusText(day)}',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('All', const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        _buildLegendItem('Partial', const Color(0xFFFFC107)),
        const SizedBox(width: 12),
        _buildLegendItem('Missed', const Color(0xFF424242)),
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
    return days.where((day) => day.status == ActivityStatus.completed).length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(ActivityDay day) {
    if (day.workoutCompleted && day.nutritionGoalMet) {
      return 'Workout ✓ Nutrition ✓';
    } else if (day.workoutCompleted) {
      return 'Workout ✓';
    } else if (day.nutritionGoalMet) {
      return 'Nutrition ✓';
    } else {
      return 'No activity';
    }
  }

  List<ActivityDay> _generateMissingDays(List<ActivityDay> existingDays, int totalDays) {
    final result = List<ActivityDay>.from(existingDays);
    final today = DateTime.now();
    
    // Заполняем недостающие дни серыми квадратиками
    while (result.length < totalDays) {
      final daysAgo = totalDays - result.length;
      result.insert(0, ActivityDay(
        date: today.subtract(Duration(days: daysAgo)),
        workoutCompleted: false,
        nutritionGoalMet: false,
      ));
    }
    
    return result;
  }
}
