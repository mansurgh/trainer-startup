// =============================================================================
// translation_service.dart — Client-Side Dictionary for DB String Translation
// =============================================================================
// Translates English database values to localized UI strings on the fly.
// Standalone implementation (no external dependencies).
// =============================================================================

import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Static service for translating database strings to localized UI text.
/// 
/// Usage:
/// ```dart
/// TranslationService.translate('bench press', context) // → 'Жим лёжа' (RU)
/// TranslationService.translateDay('Monday', context)   // → 'Понедельник' (RU)
/// ```
class TranslationService {
  TranslationService._();

  // ===========================================================================
  // MAIN API
  // ===========================================================================

  /// Universal translate function.
  /// Tries exercise → day → workout type → meal type → returns original.
  static String translate(String text, BuildContext context) {
    if (text.isEmpty) return text;
    
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return text;

    final key = text.toLowerCase().trim();

    // Try exercises first (most common)
    if (_exerciseMap.containsKey(key)) {
      return _exerciseMap[key]!;
    }

    // Try days
    if (_dayLongMap.containsKey(key)) {
      return _dayLongMap[key]!;
    }
    if (_dayShortMap.containsKey(key)) {
      return _dayShortMap[key]!;
    }

    // Try workout types
    if (_workoutTypeMap.containsKey(key)) {
      return _workoutTypeMap[key]!;
    }

    // Try meal types
    if (_mealTypeMap.containsKey(key)) {
      return _mealTypeMap[key]!;
    }

    // Try food items
    if (_foodMap.containsKey(key)) {
      return _foodMap[key]!;
    }

    return text;
  }

  /// Translate exercise name
  static String translateExercise(String name, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return name;
    
    final key = name.toLowerCase().trim();
    return _exerciseMap[key] ?? _capitalizeFirst(name);
  }

  /// Translate day (short form: Mon → Пн)
  static String translateDayShort(String day, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return day;
    
    final key = day.toLowerCase().trim();
    return _dayShortMap[key] ?? day;
  }

  /// Translate day (long form: Monday → Понедельник)
  static String translateDayLong(String day, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return day;
    
    final key = day.toLowerCase().trim();
    return _dayLongMap[key] ?? day;
  }

  /// Translate workout type (Upper Body → Верх тела)
  static String translateWorkoutType(String type, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return type;
    
    final key = type.toLowerCase().trim();
    return _workoutTypeMap[key] ?? type;
  }

  /// Translate meal type (Breakfast → Завтрак)
  static String translateMealType(String mealType, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return mealType;
    
    final key = mealType.toLowerCase().trim();
    return _mealTypeMap[key] ?? mealType;
  }

  /// Translate food item name
  static String translateFood(String food, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return food;
    
    final key = food.toLowerCase().trim();
    return _foodMap[key] ?? food;
  }

  /// Get localized unit (g → г, kcal → ккал)
  static String unit(String unit, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (unit.toLowerCase()) {
      case 'g':
      case 'grams':
        return l10n?.grams ?? 'g';
      case 'kcal':
      case 'calories':
        return l10n?.kcal ?? 'kcal';
      case 'ml':
        return 'мл';
      case 'l':
        return 'л';
      default:
        return unit;
    }
  }

  /// Check if current locale is Russian
  static bool isRussian(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ru';
  }

  // ===========================================================================
  // TRANSLATION MAPS
  // ===========================================================================

  /// Exercise translations (delegated to DataLocalizer)
  static const _exerciseMap = <String, String>{
    // Chest
    'bench press': 'Жим лёжа',
    'barbell bench press': 'Жим штанги лёжа',
    'dumbbell bench press': 'Жим гантелей лёжа',
    'incline bench press': 'Жим на наклонной скамье',
    'dumbbell incline press': 'Жим гантелей на наклонной',
    'decline bench press': 'Жим на скамье с отр. наклоном',
    'dumbbell flyes': 'Разводка гантелей',
    'cable flyes': 'Сведение в кроссовере',
    'push up': 'Отжимания',
    'push-ups': 'Отжимания',
    'pushups': 'Отжимания',
    'chest dip': 'Отжимания на брусьях',
    
    // Back
    'pull up': 'Подтягивания',
    'pull-ups': 'Подтягивания',
    'pullups': 'Подтягивания',
    'chin up': 'Подтягивания узким хватом',
    'lat pulldown': 'Тяга верхнего блока',
    'barbell row': 'Тяга штанги в наклоне',
    'bent over row': 'Тяга штанги в наклоне',
    'dumbbell row': 'Тяга гантели в наклоне',
    'seated cable row': 'Тяга нижнего блока',
    'cable row': 'Тяга троса',
    't-bar row': 'Тяга Т-грифа',
    'deadlift': 'Становая тяга',
    
    // Shoulders
    'overhead press': 'Жим над головой',
    'military press': 'Армейский жим',
    'shoulder press': 'Жим на плечи',
    'dumbbell shoulder press': 'Жим гантелей сидя',
    'arnold press': 'Жим Арнольда',
    'lateral raise': 'Махи гантелей в стороны',
    'front raise': 'Подъём гантелей перед собой',
    'rear delt fly': 'Махи на заднюю дельту',
    'face pull': 'Тяга к лицу',
    'upright row': 'Протяжка',
    'shrugs': 'Шраги',
    
    // Arms
    'bicep curl': 'Сгибание на бицепс',
    'barbell curl': 'Подъём штанги на бицепс',
    'dumbbell curl': 'Подъём гантелей на бицепс',
    'hammer curl': 'Молотки',
    'preacher curl': 'Сгибания на скамье Скотта',
    'concentration curl': 'Концентрированные сгибания',
    'tricep pushdown': 'Разгибание на трицепс',
    'tricep extension': 'Французский жим',
    'skull crusher': 'Французский жим лёжа',
    'overhead tricep extension': 'Разгибание над головой',
    'tricep dip': 'Обратные отжимания',
    'close grip bench press': 'Жим узким хватом',
    'dip': 'Отжимания на брусьях',
    'dips': 'Отжимания на брусьях',
    'cable fly': 'Сведение в кроссовере',
    'lunge': 'Выпады',
    'pull-up': 'Подтягивания',
    'row': 'Тяга',
    'curl': 'Сгибание на бицепс',
    'incline press': 'Жим на наклонной',
    'push-up': 'Отжимания',
    
    // Legs
    'squat': 'Приседания',
    'barbell squat': 'Приседания со штангой',
    'front squat': 'Фронтальные приседания',
    'goblet squat': 'Гоблет приседания',
    'leg press': 'Жим ногами',
    'lunges': 'Выпады',
    'walking lunges': 'Выпады в движении',
    'bulgarian split squat': 'Болгарские выпады',
    'leg extension': 'Разгибание ног',
    'leg curl': 'Сгибание ног',
    'romanian deadlift': 'Румынская тяга',
    'hip thrust': 'Ягодичный мостик',
    'calf raise': 'Подъём на носки',
    'standing calf raise': 'Подъём на носки стоя',
    
    // Core
    'plank': 'Планка',
    'crunch': 'Скручивания',
    'crunches': 'Скручивания',
    'sit up': 'Подъём корпуса',
    'sit-ups': 'Подъём корпуса',
    'leg raise': 'Подъём ног',
    'hanging leg raise': 'Подъём ног в висе',
    'russian twist': 'Русские скручивания',
    'mountain climber': 'Альпинист',
    'bicycle crunch': 'Велосипед',
    
    // Cardio
    'running': 'Бег',
    'jogging': 'Лёгкий бег',
    'cycling': 'Велотренажёр',
    'rowing': 'Гребля',
    'burpee': 'Бёрпи',
    'jump rope': 'Скакалка',
  };

  /// Day translations (long form)
  static const _dayLongMap = <String, String>{
    'monday': 'Понедельник',
    'tuesday': 'Вторник',
    'wednesday': 'Среда',
    'thursday': 'Четверг',
    'friday': 'Пятница',
    'saturday': 'Суббота',
    'sunday': 'Воскресенье',
  };

  /// Day translations (short form)
  static const _dayShortMap = <String, String>{
    'mon': 'Пн',
    'tue': 'Вт',
    'wed': 'Ср',
    'thu': 'Чт',
    'fri': 'Пт',
    'sat': 'Сб',
    'sun': 'Вс',
  };

  /// Workout type translations
  static const _workoutTypeMap = <String, String>{
    'upper body': 'Верх тела',
    'lower body': 'Низ тела',
    'full body': 'Всё тело',
    'push': 'Жим',
    'pull': 'Тяга',
    'legs': 'Ноги',
    'chest': 'Грудь',
    'back': 'Спина',
    'shoulders': 'Плечи',
    'arms': 'Руки',
    'core': 'Кор',
    'abs': 'Пресс',
    'cardio': 'Кардио',
    'rest': 'Отдых',
    'rest day': 'День отдыха',
  };

  /// Meal type translations
  static const _mealTypeMap = <String, String>{
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
    'snacks': 'Перекусы',
    'pre-workout': 'До тренировки',
    'post-workout': 'После тренировки',
    'morning snack': 'Утренний перекус',
    'afternoon snack': 'Дневной перекус',
    'evening snack': 'Вечерний перекус',
    'brunch': 'Бранч',
    'supper': 'Ужин',
  };

  /// Common food translations
  static const _foodMap = <String, String>{
    // Proteins
    'chicken': 'Курица',
    'chicken breast': 'Куриная грудка',
    'beef': 'Говядина',
    'pork': 'Свинина',
    'fish': 'Рыба',
    'salmon': 'Лосось',
    'tuna': 'Тунец',
    'eggs': 'Яйца',
    'egg': 'Яйцо',
    'egg whites': 'Яичные белки',
    'turkey': 'Индейка',
    'shrimp': 'Креветки',
    'tofu': 'Тофу',
    'cottage cheese': 'Творог',
    'greek yogurt': 'Греческий йогурт',
    'yogurt': 'Йогурт',
    'protein shake': 'Протеиновый коктейль',
    'whey protein': 'Сывороточный протеин',
    
    // Carbs
    'rice': 'Рис',
    'brown rice': 'Бурый рис',
    'white rice': 'Белый рис',
    'pasta': 'Макароны',
    'bread': 'Хлеб',
    'whole wheat bread': 'Цельнозерновой хлеб',
    'oatmeal': 'Овсянка',
    'oats': 'Овсянка',
    'potato': 'Картофель',
    'potatoes': 'Картофель',
    'sweet potato': 'Батат',
    'quinoa': 'Киноа',
    'buckwheat': 'Гречка',
    
    // Vegetables
    'broccoli': 'Брокколи',
    'spinach': 'Шпинат',
    'salad': 'Салат',
    'tomato': 'Помидор',
    'cucumber': 'Огурец',
    'carrot': 'Морковь',
    'bell pepper': 'Болгарский перец',
    'onion': 'Лук',
    'garlic': 'Чеснок',
    'asparagus': 'Спаржа',
    'zucchini': 'Кабачок',
    'mushrooms': 'Грибы',
    'avocado': 'Авокадо',
    
    // Fruits
    'apple': 'Яблоко',
    'banana': 'Банан',
    'orange': 'Апельсин',
    'berries': 'Ягоды',
    'strawberry': 'Клубника',
    'blueberry': 'Черника',
    'grapes': 'Виноград',
    'watermelon': 'Арбуз',
    'mango': 'Манго',
    'pineapple': 'Ананас',
    
    // Fats
    'olive oil': 'Оливковое масло',
    'butter': 'Масло',
    'nuts': 'Орехи',
    'almonds': 'Миндаль',
    'walnuts': 'Грецкие орехи',
    'peanut butter': 'Арахисовая паста',
    'cheese': 'Сыр',
    
    // Drinks
    'water': 'Вода',
    'coffee': 'Кофе',
    'tea': 'Чай',
    'green tea': 'Зелёный чай',
    'milk': 'Молоко',
    'almond milk': 'Миндальное молоко',
    'juice': 'Сок',
    'smoothie': 'Смузи',
  };

  // ===========================================================================
  // UTILITIES
  // ===========================================================================
  
  static String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
