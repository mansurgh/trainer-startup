import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/tokens.dart';
import '../../../l10n/app_localizations.dart';

class DaySelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;
  final List<bool> completedDays; // List of completed days

  const DaySelector({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
    this.completedDays = const [false, false, false, false, false, false, false],
  });

  // Get localized day labels
  static List<String> getDayLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return [
      l10n.mondayShort,
      l10n.tuesdayShort,
      l10n.wednesdayShort,
      l10n.thursdayShort,
      l10n.fridayShort,
      l10n.saturdayShort,
      l10n.sundayShort,
    ];
  }

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Day content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 14),
                        // Day letter (localized)
                        Text(
                          getDayLabels(context)[index],
                          style: TextStyle(
                            color: isSelected ? T.text : T.textSec,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    // Golden checkmark ALWAYS visible when completed (above selection)
                    if (isCompleted)
                      Positioned(
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 14,
                            color: const Color(0xFFFFD700), // Golden checkmark
                          ),
                        ),
                      ),
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