import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/tokens.dart';

class DaySelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;
  final List<bool> completedDays; // Список выполненных дней

  const DaySelector({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
    this.completedDays = const [false, false, false, false, false, false, false],
  });

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == selectedIndex;
          final isToday = _isToday(index);
          final isCompleted = completedDays[index];
          
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Completion indicator at top
                    SizedBox(
                      height: 10,
                      child: isCompleted && !isSelected 
                          ? Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                    // Day letter
                    Text(
                      _dayLabels[index],
                      style: TextStyle(
                        color: isSelected ? T.text : T.textSec,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
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