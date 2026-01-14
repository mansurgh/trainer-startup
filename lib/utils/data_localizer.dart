// =============================================================================
// data_localizer.dart — Локализация данных из базы на UI уровне
// =============================================================================
// Переводит английские названия упражнений, дней недели и других
// DB-значений в русские строки, когда locale == 'ru'
// =============================================================================

import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Статический helper для локализации данных из БД на уровне UI.
/// Не модифицирует БД — только отображение.
class DataLocalizer {
  DataLocalizer._();

  // ===========================================================================
  // УПРАЖНЕНИЯ — English DB Name → Localized Display Name
  // ===========================================================================
  
  static const _exerciseTranslations = <String, String>{
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
    'chest dip': 'Отжимания на брусьях',
    
    // Back
    'pull up': 'Подтягивания',
    'pull-ups': 'Подтягивания',
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
    'dead bug': 'Мёртвый жук',
    'bird dog': 'Птица-собака',
    'ab wheel': 'Ролик для пресса',
    
    // Cardio
    'running': 'Бег',
    'jogging': 'Лёгкий бег',
    'cycling': 'Велотренажёр',
    'rowing': 'Гребля',
    'jumping jack': 'Прыжки с хлопком',
    'burpee': 'Бёрпи',
    'jump rope': 'Скакалка',
    'elliptical': 'Эллипсоид',
    'stair climber': 'Степпер',
  };

  /// Перевод названия упражнения.
  /// Если locale != 'ru' или перевод не найден — возвращает оригинал.
  static String translateExercise(String name, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return name;
    
    final key = name.toLowerCase().trim();
    return _exerciseTranslations[key] ?? _capitalizeFirst(name);
  }

  // ===========================================================================
  // ДНИ НЕДЕЛИ — Short & Long Forms
  // ===========================================================================
  
  static const _dayShortTranslations = <String, String>{
    'mon': 'Пн',
    'tue': 'Вт',
    'wed': 'Ср',
    'thu': 'Чт',
    'fri': 'Пт',
    'sat': 'Сб',
    'sun': 'Вс',
  };

  static const _dayLongTranslations = <String, String>{
    'monday': 'Понедельник',
    'tuesday': 'Вторник',
    'wednesday': 'Среда',
    'thursday': 'Четверг',
    'friday': 'Пятница',
    'saturday': 'Суббота',
    'sunday': 'Воскресенье',
  };

  /// Перевод короткого названия дня (Mon → Пн)
  static String translateDayShort(String day, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return day;
    
    final key = day.toLowerCase().trim();
    return _dayShortTranslations[key] ?? day;
  }

  /// Перевод полного названия дня (Monday → Понедельник)
  static String translateDayLong(String day, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return day;
    
    final key = day.toLowerCase().trim();
    return _dayLongTranslations[key] ?? day;
  }

  // ===========================================================================
  // ГРУППЫ МЫШЦ / WORKOUT TYPES
  // ===========================================================================
  
  static const _workoutTypeTranslations = <String, String>{
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

  /// Перевод типа тренировки (Upper Body → Верх тела)
  static String translateWorkoutType(String type, BuildContext context) {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    if (!isRussian) return type;
    
    final key = type.toLowerCase().trim();
    return _workoutTypeTranslations[key] ?? type;
  }

  // ===========================================================================
  // ЕДИНИЦЫ ИЗМЕРЕНИЯ
  // ===========================================================================

  /// Возвращает локализованные граммы (g → г)
  static String grams(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.grams ?? 'g';
  }

  /// Возвращает локализованные килокалории (kcal → ккал)
  static String kcal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.kcal ?? 'kcal';
  }

  // ===========================================================================
  // УТИЛИТЫ
  // ===========================================================================

  static String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Проверка, является ли текущая локаль русской
  static bool isRussianLocale(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ru';
  }
}
