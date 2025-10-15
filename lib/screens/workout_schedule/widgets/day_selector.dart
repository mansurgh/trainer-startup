import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/tokens.dart';

class DaySelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;

  const DaySelector({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == selectedIndex;
          final isToday = _isToday(index);
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onDaySelected(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? T.accentMuted : Colors.transparent,
                  borderRadius: const BorderRadius.all(T.r12),
                  border: isToday && !isSelected 
                    ? Border.all(color: T.border, width: 1)
                    : null,
                ),
                child: Center(
                  child: Text(
                    _dayLabels[index],
                    style: TextStyle(
                      color: isSelected ? T.text : T.textSec,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _isToday(int dayIndex) {
    final now = DateTime.now();
    final mondayIndex = (now.weekday - 1) % 7;
    return dayIndex == mondayIndex;
  }
}