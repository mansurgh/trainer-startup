// =============================================================================
// history_row_widget.dart — Generic Rectangular History Row with 7-Day Chart
// =============================================================================
// Noir Glass style rectangular clickable card with:
// - Title on left
// - 7-day bar chart on right
// - Navigation on tap
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/noir_theme.dart';

/// Data point for a single day in the history chart
class HistoryDayData {
  final DateTime date;
  final double value;
  final double target;
  
  const HistoryDayData({
    required this.date,
    required this.value,
    required this.target,
  });
  
  double get percentage => target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
  bool get hasData => value > 0;
}

/// Generic rectangular history row widget
/// 
/// Usage:
/// ```dart
/// HistoryRowWidget(
///   title: 'Питание',
///   subtitle: 'Последние 7 дней',
///   icon: Icons.restaurant_menu_rounded,
///   days: nutritionDays,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class HistoryRowWidget extends StatelessWidget {
  const HistoryRowWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.days,
    required this.onTap,
    this.barColor,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<HistoryDayData> days;
  final VoidCallback onTap;
  final Color? barColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(kSpaceMD),
            decoration: BoxDecoration(
              color: kNoirGraphite.withOpacity(0.4),
              borderRadius: BorderRadius.circular(kRadiusMD),
              border: Border.all(color: kNoirSteel.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // Left side: Icon + Title
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: kContentMedium, size: 20),
                          const SizedBox(width: kSpaceSM),
                          Expanded(
                            child: Text(
                              title,
                              style: kNoirHeadline.copyWith(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceXS),
                      Text(
                        subtitle,
                        style: kNoirCaption.copyWith(color: kContentLow),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: kSpaceMD),
                
                // Right side: 7-day bar chart
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 50,
                    child: isLoading
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  kContentMedium.withOpacity(0.5),
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: days.isEmpty
                                ? _buildEmptyBars()
                                : days.map((day) => _buildDayBar(day)).toList(),
                          ),
                  ),
                ),
                
                // Arrow indicator
                const SizedBox(width: kSpaceSM),
                Icon(
                  Icons.chevron_right_rounded,
                  color: kContentLow,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmptyBars() {
    return List.generate(7, (_) => _buildBarWidget(0, false));
  }

  Widget _buildDayBar(HistoryDayData day) {
    final barHeight = 40 * day.percentage + 8; // Min 8px height
    return _buildBarWidget(barHeight, day.hasData);
  }

  Widget _buildBarWidget(double height, bool hasData) {
    final color = hasData
        ? (barColor ?? const Color(0xFF4ADE80)) // Success green by default
        : kNoirSteel.withOpacity(0.3);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: height.clamp(8.0, 40.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
