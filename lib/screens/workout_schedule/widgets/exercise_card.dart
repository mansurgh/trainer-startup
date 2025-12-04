import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/exercise.dart';
import '../../../theme/tokens.dart';
import '../../../l10n/app_localizations.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: T.p12,
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: const BorderRadius.all(T.r16),
          border: Border.all(color: T.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getLocalizedName(context, exercise.name),
                    style: const TextStyle(
                      color: T.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${exercise.sets} × ${exercise.reps}',
                  style: const TextStyle(
                    color: T.textSec,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            if (exercise.sets > 0) ...[
              const SizedBox(height: 8),
              
              // Progress info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.sets}: ${exercise.completedSets}/${exercise.sets}',
                    style: const TextStyle(
                      color: T.textSec,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(exercise.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: T.textSec,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: T.accentMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: exercise.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: exercise.progress == 1.0 ? T.success : T.text,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getLocalizedName(BuildContext context, String name) {
    final map = {
      'barbell squat': 'Приседания со штангой',
      'push up': 'Отжимания',
      'barbell bench press': 'Жим лежа',
      'lateral raise': 'Махи гантелями в стороны',
      'cable lateral raise': 'Махи в кроссовере',
      'pull up': 'Подтягивания',
      'dumbbell shoulder press': 'Жим гантелей сидя',
      'dumbbell bicep curl': 'Сгибание на бицепс',
      'tricep pushdown': 'Разгибание на трицепс',
      'leg press': 'Жим ногами',
      'leg extension': 'Разгибание ног',
      'leg curl': 'Сгибание ног',
      'crunch': 'Скручивания',
      'plank': 'Планка',
      'deadlift': 'Становая тяга',
      'overhead press': 'Армейский жим',
      'lunges': 'Выпады',
      'face pull': 'Тяга к лицу',
      'lat pulldown': 'Тяга верхнего блока',
      'seated row': 'Тяга нижнего блока',
    };
    
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ru' && map.containsKey(name.toLowerCase())) {
      return map[name.toLowerCase()]!;
    }
    return name;
  }
}