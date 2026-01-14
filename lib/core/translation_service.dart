// =============================================================================
// translation_service.dart — Client-Side Translation for DB Strings
// =============================================================================
// Translates English strings from database (exercises, days, muscle groups)
// to localized versions based on current app locale.
// =============================================================================

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Service for translating database strings to localized versions.
/// 
/// Usage:
/// ```dart
/// final translated = TranslationService.translate('Push-ups', context);
/// // Returns "Отжимания" for Russian locale
/// ```
class TranslationService {
  TranslationService._();

  // ========================== EXERCISES ==========================
  static const Map<String, String> _exercisesRu = {
    // Chest
    'push-up': 'Отжимания',
    'push-ups': 'Отжимания',
    'pushup': 'Отжимания',
    'pushups': 'Отжимания',
    'bench press': 'Жим лёжа',
    'barbell bench press': 'Жим штанги лёжа',
    'dumbbell bench press': 'Жим гантелей лёжа',
    'incline bench press': 'Жим лёжа на наклонной скамье',
    'decline bench press': 'Жим лёжа с наклоном вниз',
    'dumbbell flyes': 'Разводка гантелей',
    'cable crossover': 'Сведение рук в кроссовере',
    'chest dips': 'Отжимания на брусьях',
    'dips': 'Отжимания на брусьях',
    
    // Back
    'pull-up': 'Подтягивания',
    'pull-ups': 'Подтягивания',
    'pullup': 'Подтягивания',
    'pullups': 'Подтягивания',
    'chin-up': 'Подтягивания обратным хватом',
    'chin-ups': 'Подтягивания обратным хватом',
    'lat pulldown': 'Тяга верхнего блока',
    'barbell row': 'Тяга штанги в наклоне',
    'bent over row': 'Тяга штанги в наклоне',
    'dumbbell row': 'Тяга гантели в наклоне',
    'seated cable row': 'Тяга нижнего блока',
    'deadlift': 'Становая тяга',
    't-bar row': 'Тяга Т-грифа',
    'face pull': 'Тяга к лицу',
    
    // Legs
    'squat': 'Приседания',
    'squats': 'Приседания',
    'barbell squat': 'Приседания со штангой',
    'front squat': 'Фронтальные приседания',
    'goblet squat': 'Кубковые приседания',
    'leg press': 'Жим ногами',
    'lunge': 'Выпады',
    'lunges': 'Выпады',
    'walking lunges': 'Выпады в движении',
    'leg curl': 'Сгибание ног',
    'leg extension': 'Разгибание ног',
    'calf raise': 'Подъём на носки',
    'calf raises': 'Подъёмы на носки',
    'romanian deadlift': 'Румынская тяга',
    'hip thrust': 'Ягодичный мост',
    'glute bridge': 'Ягодичный мостик',
    'bulgarian split squat': 'Болгарские приседания',
    
    // Shoulders
    'shoulder press': 'Жим плечами',
    'overhead press': 'Жим над головой',
    'military press': 'Армейский жим',
    'barbell military press': 'Армейский жим со штангой',
    'dumbbell shoulder press': 'Жим гантелей сидя',
    'lateral raise': 'Махи гантелей в стороны',
    'lateral raises': 'Махи гантелей в стороны',
    'dumbbell lateral raises': 'Махи гантелей в стороны',
    'front raise': 'Подъём гантелей перед собой',
    'rear delt fly': 'Разводка на задние дельты',
    'upright row': 'Тяга к подбородку',
    'arnold press': 'Жим Арнольда',
    'shrugs': 'Шраги',
    
    // Arms - Biceps
    'bicep curl': 'Сгибание на бицепс',
    'bicep curls': 'Сгибания на бицепс',
    'barbell curl': 'Подъём штанги на бицепс',
    'dumbbell curl': 'Подъём гантелей на бицепс',
    'hammer curl': 'Молотки',
    'hammer curls': 'Молотки',
    'preacher curl': 'Сгибания на скамье Скотта',
    'concentration curl': 'Концентрированные сгибания',
    
    // Arms - Triceps
    'tricep dip': 'Отжимания на трицепс',
    'tricep dips': 'Отжимания на трицепс',
    'tricep extension': 'Разгибания на трицепс',
    'tricep extensions': 'Разгибания на трицепс',
    'dumbbell tricep extensions': 'Разгибания с гантелью на трицепс',
    'skull crusher': 'Французский жим',
    'skull crushers': 'Французский жим',
    'tricep pushdown': 'Разгибания на блоке',
    'close grip bench press': 'Жим узким хватом',
    'overhead tricep extension': 'Французский жим над головой',
    
    // Core
    'plank': 'Планка',
    'crunch': 'Скручивания',
    'crunches': 'Скручивания',
    'sit-up': 'Подъём корпуса',
    'sit-ups': 'Подъёмы корпуса',
    'leg raise': 'Подъём ног',
    'leg raises': 'Подъёмы ног',
    'russian twist': 'Русские скручивания',
    'russian twists': 'Русские скручивания',
    'mountain climber': 'Альпинист',
    'mountain climbers': 'Альпинисты',
    'bicycle crunch': 'Велосипед',
    'bicycle crunches': 'Велосипед',
    'hanging leg raise': 'Подъём ног в висе',
    'ab wheel rollout': 'Ролик для пресса',
    'dead bug': 'Мёртвый жук',
    
    // Cardio
    'running': 'Бег',
    'jogging': 'Бег трусцой',
    'walking': 'Ходьба',
    'cycling': 'Велосипед',
    'swimming': 'Плавание',
    'jump rope': 'Скакалка',
    'jumping jacks': 'Прыжки с разведением рук',
    'burpee': 'Бёрпи',
    'burpees': 'Бёрпи',
    'high knees': 'Высокие колени',
    'box jump': 'Прыжки на платформу',
    'box jumps': 'Прыжки на платформу',
    'rowing': 'Гребля',
    'stair climbing': 'Ходьба по лестнице',
    'elliptical': 'Эллиптический тренажёр',
    
    // Full body / Compound
    'clean and jerk': 'Толчок',
    'snatch': 'Рывок',
    'power clean': 'Взятие на грудь',
    'thruster': 'Трастеры',
    'thrusters': 'Трастеры',
    'kettlebell swing': 'Махи гирей',
    'farmer walk': 'Прогулка фермера',
    'battle ropes': 'Канаты',
    
    // Stretching
    'stretch': 'Растяжка',
    'stretching': 'Растяжка',
    'foam rolling': 'Раскатка на ролле',
    'warm up': 'Разминка',
    'cool down': 'Заминка',
  };

  // ========================== DAYS OF WEEK ==========================
  static const Map<String, String> _daysRu = {
    'monday': 'Понедельник',
    'tuesday': 'Вторник',
    'wednesday': 'Среда',
    'thursday': 'Четверг',
    'friday': 'Пятница',
    'saturday': 'Суббота',
    'sunday': 'Воскресенье',
    'rest day': 'День отдыха',
    'rest': 'Отдых',
  };

  // ========================== MUSCLE GROUPS ==========================
  static const Map<String, String> _musclesRu = {
    'chest': 'Грудь',
    'back': 'Спина',
    'shoulders': 'Плечи',
    'biceps': 'Бицепс',
    'triceps': 'Трицепс',
    'forearms': 'Предплечья',
    'abs': 'Пресс',
    'core': 'Кор',
    'quadriceps': 'Квадрицепс',
    'quads': 'Квадрицепс',
    'hamstrings': 'Бицепс бедра',
    'glutes': 'Ягодицы',
    'calves': 'Икры',
    'legs': 'Ноги',
    'arms': 'Руки',
    'upper body': 'Верх тела',
    'lower body': 'Низ тела',
    'full body': 'Всё тело',
    'push': 'Толкающие',
    'pull': 'Тянущие',
    'front delts': 'Передние дельты',
    'side delts': 'Средние дельты',
    'rear delts': 'Задние дельты',
    'lats': 'Широчайшие',
    'traps': 'Трапеции',
    'rhomboids': 'Ромбовидные',
    'obliques': 'Косые мышцы',
    'hip flexors': 'Сгибатели бедра',
    'adductors': 'Приводящие',
    'abductors': 'Отводящие',
  };

  // ========================== WORKOUT TYPES ==========================
  static const Map<String, String> _workoutTypesRu = {
    'strength': 'Силовая',
    'strength training': 'Силовая тренировка',
    'cardio': 'Кардио',
    'hiit': 'ВИИТ',
    'flexibility': 'Гибкость',
    'mobility': 'Мобильность',
    'endurance': 'Выносливость',
    'hypertrophy': 'Гипертрофия',
    'power': 'Мощность',
    'circuit': 'Круговая',
    'circuit training': 'Круговая тренировка',
    'functional': 'Функциональная',
    'plyometrics': 'Плиометрика',
    'stretching': 'Растяжка',
    'yoga': 'Йога',
    'pilates': 'Пилатес',
    'warm-up': 'Разминка',
    'cool-down': 'Заминка',
  };

  // ========================== FOOD / MEALS ==========================
  static const Map<String, String> _foodRu = {
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
    'pre-workout': 'До тренировки',
    'post-workout': 'После тренировки',
    // Common foods
    'chicken breast': 'Куриная грудка',
    'chicken': 'Курица',
    'beef': 'Говядина',
    'fish': 'Рыба',
    'salmon': 'Лосось',
    'tuna': 'Тунец',
    'eggs': 'Яйца',
    'egg whites': 'Яичные белки',
    'rice': 'Рис',
    'brown rice': 'Бурый рис',
    'oatmeal': 'Овсянка',
    'pasta': 'Паста',
    'bread': 'Хлеб',
    'potato': 'Картофель',
    'sweet potato': 'Батат',
    'broccoli': 'Брокколи',
    'spinach': 'Шпинат',
    'salad': 'Салат',
    'greek yogurt': 'Греческий йогурт',
    'cottage cheese': 'Творог',
    'milk': 'Молоко',
    'protein shake': 'Протеиновый коктейль',
    'almonds': 'Миндаль',
    'nuts': 'Орехи',
    'olive oil': 'Оливковое масло',
    'avocado': 'Авокадо',
    'banana': 'Банан',
    'apple': 'Яблоко',
    'berries': 'Ягоды',
  };

  /// Translate a string from English to current locale.
  /// Returns original string if no translation found.
  static String translate(String input, BuildContext context) {
    final locale = Localizations.localeOf(context);
    
    // Only translate for Russian locale
    if (locale.languageCode != 'ru') {
      return input;
    }
    
    final lowerInput = input.toLowerCase().trim();
    
    // Check exercises first (most common)
    if (_exercisesRu.containsKey(lowerInput)) {
      return _exercisesRu[lowerInput]!;
    }
    
    // Check days
    if (_daysRu.containsKey(lowerInput)) {
      return _daysRu[lowerInput]!;
    }
    
    // Check muscles
    if (_musclesRu.containsKey(lowerInput)) {
      return _musclesRu[lowerInput]!;
    }
    
    // Check workout types
    if (_workoutTypesRu.containsKey(lowerInput)) {
      return _workoutTypesRu[lowerInput]!;
    }
    
    // Check food
    if (_foodRu.containsKey(lowerInput)) {
      return _foodRu[lowerInput]!;
    }
    
    // No translation found - return original
    return input;
  }

  /// Translate exercise name specifically.
  static String translateExercise(String exerciseName, BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'ru') return exerciseName;
    
    final lower = exerciseName.toLowerCase().trim();
    return _exercisesRu[lower] ?? exerciseName;
  }

  /// Translate day name specifically.
  static String translateDay(String dayName, BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'ru') return dayName;
    
    final lower = dayName.toLowerCase().trim();
    return _daysRu[lower] ?? dayName;
  }

  /// Translate muscle group name specifically.
  static String translateMuscle(String muscleName, BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'ru') return muscleName;
    
    final lower = muscleName.toLowerCase().trim();
    return _musclesRu[lower] ?? muscleName;
  }

  /// Translate workout type specifically.
  static String translateWorkoutType(String workoutType, BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'ru') return workoutType;
    
    final lower = workoutType.toLowerCase().trim();
    return _workoutTypesRu[lower] ?? workoutType;
  }

  /// Translate food/meal name specifically.
  static String translateFood(String foodName, BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'ru') return foodName;
    
    final lower = foodName.toLowerCase().trim();
    return _foodRu[lower] ?? foodName;
  }

  /// Get locale code for AI prompts.
  /// Returns 'ru' for Russian-speaking regions, 'en' otherwise.
  static String getLocaleCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  /// Check if current locale is Russian.
  static bool isRussian(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ru';
  }
}
