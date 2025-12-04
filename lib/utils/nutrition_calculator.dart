/// Калькулятор рекомендованных значений кБЖУ на основе данных пользователя
class NutritionCalculator {
  /// Расчет базового метаболизма (BMR) по формуле Mifflin-St Jeor
  /// Наиболее точная формула для современных людей
  static double calculateBMR({
    required double weight, // кг
    required int height, // см
    required int age, // лет
    required String gender, // 'm' или 'f'
  }) {
    if (gender.toLowerCase() == 'm') {
      // Мужчины: BMR = 10 * вес(кг) + 6.25 * рост(см) - 5 * возраст + 5
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      // Женщины: BMR = 10 * вес(кг) + 6.25 * рост(см) - 5 * возраст - 161
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  /// Расчет общего расхода калорий (TDEE) с учетом уровня активности
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    double multiplier;
    
    switch (activityLevel.toLowerCase()) {
      case 'sedentary': // Сидячий образ жизни
      case 'low':
        multiplier = 1.2;
        break;
      case 'light': // Легкая активность (1-3 раза в неделю)
      case 'medium':
        multiplier = 1.375;
        break;
      case 'moderate': // Умеренная активность (3-5 раз в неделю)
      case 'high':
        multiplier = 1.55;
        break;
      case 'active': // Высокая активность (6-7 раз в неделю)
      case 'very_high':
        multiplier = 1.725;
        break;
      case 'athlete': // Спортсмен (2 раза в день)
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.55; // По умолчанию умеренная активность
    }
    
    return bmr * multiplier;
  }

  /// Корректировка калорий в зависимости от цели
  static double adjustCaloriesForGoal({
    required double tdee,
    required String goal,
  }) {
    switch (goal.toLowerCase()) {
      case 'fat_loss': // Похудение
      case 'lose_weight':
        return tdee * 0.8; // Дефицит 20%
      case 'muscle_gain': // Набор массы
      case 'gain_weight':
        return tdee * 1.15; // Профицит 15%
      case 'maintenance': // Поддержание
      case 'fitness':
      default:
        return tdee; // Без изменений
    }
  }

  /// Расчет белков (г) - 2-2.5г на кг веса для тренирующихся
  static double calculateProtein({
    required double weight,
    required String goal,
  }) {
    double gramsPerKg;
    
    switch (goal.toLowerCase()) {
      case 'muscle_gain':
      case 'gain_weight':
        gramsPerKg = 2.5; // Больше белка для роста мышц
        break;
      case 'fat_loss':
      case 'lose_weight':
        gramsPerKg = 2.2; // Высокий белок для сохранения мышц
        break;
      default:
        gramsPerKg = 2.0; // Стандарт для тренирующихся
    }
    
    return weight * gramsPerKg;
  }

  /// Расчет жиров (г) - 25-30% от общих калорий
  static double calculateFat({
    required double calories,
    required String goal,
  }) {
    double percentage;
    
    switch (goal.toLowerCase()) {
      case 'fat_loss':
      case 'lose_weight':
        percentage = 0.25; // Меньше жиров при похудении
        break;
      case 'muscle_gain':
      case 'gain_weight':
        percentage = 0.30; // Больше жиров для энергии
        break;
      default:
        percentage = 0.28; // Стандарт
    }
    
    // 1г жира = 9 ккал
    return (calories * percentage) / 9;
  }

  /// Расчет углеводов (г) - остаток калорий после белков и жиров
  static double calculateCarbs({
    required double calories,
    required double proteinGrams,
    required double fatGrams,
  }) {
    // 1г белка = 4 ккал, 1г жира = 9 ккал, 1г углеводов = 4 ккал
    final proteinCalories = proteinGrams * 4;
    final fatCalories = fatGrams * 9;
    final remainingCalories = calories - proteinCalories - fatCalories;
    
    return remainingCalories / 4;
  }

  /// Полный расчет рекомендаций
  static Map<String, double> calculateRecommendations({
    required double weight,
    required int height,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // 1. Базовый метаболизм
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );
    
    // 2. Общий расход энергии
    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: activityLevel,
    );
    
    // 3. Калории с учетом цели
    final calories = adjustCaloriesForGoal(
      tdee: tdee,
      goal: goal,
    );
    
    // 4. Макронутриенты
    final protein = calculateProtein(weight: weight, goal: goal);
    final fat = calculateFat(calories: calories, goal: goal);
    final carbs = calculateCarbs(
      calories: calories,
      proteinGrams: protein,
      fatGrams: fat,
    );
    
    return {
      'bmr': bmr.roundToDouble(),
      'tdee': tdee.roundToDouble(),
      'calories': calories.roundToDouble(),
      'protein': protein.roundToDouble(),
      'fat': fat.roundToDouble(),
      'carbs': carbs.roundToDouble(),
    };
  }

  /// Получить описание рекомендаций
  static String getRecommendationDescription(String goal) {
    switch (goal.toLowerCase()) {
      case 'fat_loss':
      case 'lose_weight':
        return 'Дефицит калорий для эффективного жиросжигания. '
            'Высокий белок для сохранения мышечной массы. '
            'Умеренные углеводы для энергии на тренировках.';
      case 'muscle_gain':
      case 'gain_weight':
        return 'Профицит калорий для роста мышц. '
            'Максимум белка для восстановления и роста. '
            'Достаточно углеводов и жиров для энергии.';
      case 'maintenance':
      case 'fitness':
      default:
        return 'Сбалансированное питание для поддержания формы. '
            'Оптимальное соотношение макронутриентов. '
            'Подходит для регулярных тренировок.';
    }
  }
}
