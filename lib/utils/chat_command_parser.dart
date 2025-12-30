/// Парсер команд для AI чатов (тренер и нутрициолог)
/// Позволяет пользователю управлять настройками приложения через чат
class ChatCommandParser {
  /// Список доступных команд
  static const List<String> availableCommands = [
    // Питание
    '/fat <value>',
    '/protein <value>',
    '/carbs <value>',
    '/calories <value>',
    '/swap_meal <old> -> <new>',
    // Тренировки
    '/swap_exercise <old> -> <new>',
    '/set_goal <fat_loss|muscle_gain|fitness>',
    '/set_level <beginner|intermediate|advanced>',
    // Профиль
    '/set_weight <value>',
    '/set_height <value>',
    '/set_age <value>',
    // Настройки приложения
    '/set_language <ru|en>',
    '/toggle_notifications',
    '/set_reminder <HH:MM>',
    // Система
    '/help',
    '/status',
    '/export',
  ];

  /// Безопасные команды (не меняют критичные данные)
  static const List<String> _safeCommands = [
    '/help',
    '/status',
    '/export',
  ];

  /// Проверка является ли сообщение командой
  static bool isCommand(String message) {
    return message.trim().startsWith('/');
  }

  /// Проверка безопасности команды
  static bool isSafeCommand(String message) {
    final command = message.trim().split(RegExp(r'\s+'))[0].toLowerCase();
    return _safeCommands.contains(command);
  }

  /// Парсинг команды
  static CommandResult? parseCommand(String message) {
    final trimmed = message.trim();
    
    if (!isCommand(trimmed)) {
      return null;
    }

    // Разделяем команду и параметры
    final parts = trimmed.split(RegExp(r'\s+'));
    final command = parts[0].toLowerCase();
    final args = parts.skip(1).join(' ');

    switch (command) {
      // === NUTRITION COMMANDS ===
      case '/fat':
      case '/protein':
      case '/carbs':
      case '/calories':
        return _parseNutritionCommand(command, args);
      
      case '/swap_meal':
        return _parseSwapMealCommand(args);
      
      // === WORKOUT COMMANDS ===
      case '/swap_exercise':
        return _parseSwapExerciseCommand(args);
      
      case '/set_goal':
        return _parseSetGoalCommand(args);
      
      case '/set_level':
        return _parseSetLevelCommand(args);
      
      // === PROFILE COMMANDS ===
      case '/set_weight':
        return _parseSetWeightCommand(args);
      
      case '/set_height':
        return _parseSetHeightCommand(args);
      
      case '/set_age':
        return _parseSetAgeCommand(args);
      
      // === SETTINGS COMMANDS ===
      case '/set_language':
        return _parseSetLanguageCommand(args);
      
      case '/toggle_notifications':
        return CommandResult(
          type: CommandType.toggleNotifications,
          success: true,
          data: {},
          message: '🔔 Notifications toggled',
        );
      
      case '/set_reminder':
        return _parseSetReminderCommand(args);
      
      // === SYSTEM COMMANDS ===
      case '/help':
        return CommandResult(
          type: CommandType.help,
          success: true,
          data: {},
          message: _getHelpMessage(),
        );
      
      case '/status':
        return CommandResult(
          type: CommandType.status,
          success: true,
          data: {},
          message: '📊 Requesting current status...',
        );
      
      case '/export':
        return CommandResult(
          type: CommandType.export,
          success: true,
          data: {},
          message: '📤 Preparing data export...',
        );
      
      default:
        return CommandResult(
          type: CommandType.unknown,
          success: false,
          data: {},
          message: '❌ Неизвестная команда: $command\n\nВведите /help для списка команд.',
        );
    }
  }

  /// Парсинг команд изменения макронутриентов
  static CommandResult _parseNutritionCommand(String command, String args) {
    final value = int.tryParse(args);
    
    if (value == null || value <= 0) {
      return CommandResult(
        type: CommandType.updateNutrition,
        success: false,
        data: {},
        message: '❌ Неверное значение. Использование: $command <число>\nПример: $command 60',
      );
    }

    // Валидация разумных пределов
    String nutrientType;
    String unit;
    int minVal, maxVal;
    
    switch (command) {
      case '/calories':
        nutrientType = 'calories';
        unit = 'kcal';
        minVal = 1000;
        maxVal = 5000;
        break;
      case '/fat':
        nutrientType = 'fat';
        unit = 'г';
        minVal = 20;
        maxVal = 200;
        break;
      case '/protein':
        nutrientType = 'protein';
        unit = 'г';
        minVal = 30;
        maxVal = 300;
        break;
      case '/carbs':
        nutrientType = 'carbs';
        unit = 'г';
        minVal = 50;
        maxVal = 500;
        break;
      default:
        return CommandResult(
          type: CommandType.updateNutrition,
          success: false,
          data: {},
          message: '❌ Неизвестный тип нутриента',
        );
    }

    if (value < minVal || value > maxVal) {
      return CommandResult(
        type: CommandType.updateNutrition,
        success: false,
        data: {},
        message: '⚠️ Значение должно быть от $minVal до $maxVal $unit',
      );
    }

    return CommandResult(
      type: CommandType.updateNutrition,
      success: true,
      data: {
        'nutrientType': nutrientType,
        'value': value,
        'unit': unit,
      },
      message: '✅ Цель обновлена: $nutrientType = $value $unit',
    );
  }

  /// Парсинг команды замены блюда
  static CommandResult _parseSwapMealCommand(String args) {
    final parts = args.split('->');
    
    if (parts.length != 2) {
      return CommandResult(
        type: CommandType.swapMeal,
        success: false,
        data: {},
        message: '❌ Неверный формат.\nИспользование: /swap_meal <старое> -> <новое>\n'
                 'Пример: /swap_meal паста -> рис',
      );
    }

    final oldMeal = parts[0].trim();
    final newMeal = parts[1].trim();

    if (oldMeal.isEmpty || newMeal.isEmpty) {
      return CommandResult(
        type: CommandType.swapMeal,
        success: false,
        data: {},
        message: '❌ Укажите оба блюда.',
      );
    }

    return CommandResult(
      type: CommandType.swapMeal,
      success: true,
      data: {
        'oldMeal': oldMeal,
        'newMeal': newMeal,
      },
      message: '🍽️ Замена блюда: "$oldMeal" → "$newMeal"',
    );
  }

  /// Парсинг команды замены упражнения
  static CommandResult _parseSwapExerciseCommand(String args) {
    final parts = args.split('->');
    
    if (parts.length != 2) {
      return CommandResult(
        type: CommandType.swapExercise,
        success: false,
        data: {},
        message: '❌ Неверный формат.\nИспользование: /swap_exercise <старое> -> <новое>\n'
                 'Пример: /swap_exercise приседания -> жим ногами',
      );
    }

    final oldExercise = parts[0].trim();
    final newExercise = parts[1].trim();

    if (oldExercise.isEmpty || newExercise.isEmpty) {
      return CommandResult(
        type: CommandType.swapExercise,
        success: false,
        data: {},
        message: '❌ Укажите оба упражнения.',
      );
    }

    return CommandResult(
      type: CommandType.swapExercise,
      success: true,
      data: {
        'oldExercise': oldExercise,
        'newExercise': newExercise,
      },
      message: '💪 Замена упражнения: "$oldExercise" → "$newExercise"',
    );
  }

  /// Парсинг команды установки цели
  static CommandResult _parseSetGoalCommand(String args) {
    final goal = args.toLowerCase().trim();
    
    const validGoals = ['fat_loss', 'muscle_gain', 'fitness', 'похудение', 'масса', 'фитнес'];
    
    if (!validGoals.contains(goal)) {
      return CommandResult(
        type: CommandType.setGoal,
        success: false,
        data: {},
        message: '❌ Неверная цель.\nДоступные: fat_loss, muscle_gain, fitness',
      );
    }

    // Нормализация русских названий
    String normalizedGoal = goal;
    if (goal == 'похудение') normalizedGoal = 'fat_loss';
    if (goal == 'масса') normalizedGoal = 'muscle_gain';
    if (goal == 'фитнес') normalizedGoal = 'fitness';

    return CommandResult(
      type: CommandType.setGoal,
      success: true,
      data: {'goal': normalizedGoal},
      message: '🎯 Цель установлена: $normalizedGoal',
    );
  }

  /// Парсинг команды установки уровня
  static CommandResult _parseSetLevelCommand(String args) {
    final level = args.toLowerCase().trim();
    
    const validLevels = ['beginner', 'intermediate', 'advanced', 'новичок', 'средний', 'продвинутый'];
    
    if (!validLevels.contains(level)) {
      return CommandResult(
        type: CommandType.setLevel,
        success: false,
        data: {},
        message: '❌ Неверный уровень.\nДоступные: beginner, intermediate, advanced',
      );
    }

    String normalizedLevel = level;
    if (level == 'новичок') normalizedLevel = 'beginner';
    if (level == 'средний') normalizedLevel = 'intermediate';
    if (level == 'продвинутый') normalizedLevel = 'advanced';

    return CommandResult(
      type: CommandType.setLevel,
      success: true,
      data: {'level': normalizedLevel},
      message: '📈 Уровень установлен: $normalizedLevel',
    );
  }

  /// Парсинг команды установки веса
  static CommandResult _parseSetWeightCommand(String args) {
    final value = double.tryParse(args);
    
    if (value == null || value < 30 || value > 300) {
      return CommandResult(
        type: CommandType.setWeight,
        success: false,
        data: {},
        message: '❌ Вес должен быть от 30 до 300 кг.',
      );
    }

    return CommandResult(
      type: CommandType.setWeight,
      success: true,
      data: {'weight': value},
      message: '⚖️ Вес обновлён: ${value.toStringAsFixed(1)} кг',
    );
  }

  /// Парсинг команды установки роста
  static CommandResult _parseSetHeightCommand(String args) {
    final value = int.tryParse(args);
    
    if (value == null || value < 100 || value > 250) {
      return CommandResult(
        type: CommandType.setHeight,
        success: false,
        data: {},
        message: '❌ Рост должен быть от 100 до 250 см.',
      );
    }

    return CommandResult(
      type: CommandType.setHeight,
      success: true,
      data: {'height': value},
      message: '📏 Рост обновлён: $value см',
    );
  }

  /// Парсинг команды установки возраста
  static CommandResult _parseSetAgeCommand(String args) {
    final value = int.tryParse(args);
    
    if (value == null || value < 13 || value > 100) {
      return CommandResult(
        type: CommandType.setAge,
        success: false,
        data: {},
        message: '❌ Возраст должен быть от 13 до 100 лет.',
      );
    }

    return CommandResult(
      type: CommandType.setAge,
      success: true,
      data: {'age': value},
      message: '🎂 Возраст обновлён: $value лет',
    );
  }

  /// Парсинг команды установки языка
  static CommandResult _parseSetLanguageCommand(String args) {
    final lang = args.toLowerCase().trim();
    
    if (lang != 'ru' && lang != 'en') {
      return CommandResult(
        type: CommandType.setLanguage,
        success: false,
        data: {},
        message: '❌ Доступные языки: ru, en',
      );
    }

    return CommandResult(
      type: CommandType.setLanguage,
      success: true,
      data: {'language': lang},
      message: '🌍 Язык изменён: ${lang == 'ru' ? 'Русский' : 'English'}',
    );
  }

  /// Парсинг команды установки напоминания
  static CommandResult _parseSetReminderCommand(String args) {
    final timeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
    final match = timeRegex.firstMatch(args.trim());
    
    if (match == null) {
      return CommandResult(
        type: CommandType.setReminder,
        success: false,
        data: {},
        message: '❌ Формат: /set_reminder HH:MM\nПример: /set_reminder 09:00',
      );
    }

    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
      return CommandResult(
        type: CommandType.setReminder,
        success: false,
        data: {},
        message: '❌ Неверное время.',
      );
    }

    return CommandResult(
      type: CommandType.setReminder,
      success: true,
      data: {'hours': hours, 'minutes': minutes},
      message: '⏰ Напоминание установлено на ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
    );
  }

  /// Сообщение помощи
  static String _getHelpMessage() {
    return '''
📋 **Доступные команды**

**🍎 Питание:**
• `/calories <число>` - Установить норму калорий (ккал)
• `/protein <число>` - Установить норму белка (г)
• `/fat <число>` - Установить норму жиров (г)
• `/carbs <число>` - Установить норму углеводов (г)
• `/swap_meal <старое> -> <новое>` - Заменить блюдо

**💪 Тренировки:**
• `/swap_exercise <старое> -> <новое>` - Заменить упражнение
• `/set_goal <цель>` - Установить цель (fat_loss, muscle_gain, fitness)
• `/set_level <уровень>` - Установить уровень (beginner, intermediate, advanced)

**👤 Профиль:**
• `/set_weight <число>` - Обновить вес (кг)
• `/set_height <число>` - Обновить рост (см)
• `/set_age <число>` - Обновить возраст

**⚙️ Настройки:**
• `/set_language <ru|en>` - Сменить язык
• `/toggle_notifications` - Вкл/выкл уведомления
• `/set_reminder HH:MM` - Установить напоминание

**📊 Система:**
• `/status` - Показать текущий статус
• `/export` - Экспортировать данные
• `/help` - Эта справка

💡 *Команды безопасны - критичные данные защищены.*
''';
  }
}

/// Тип команды
enum CommandType {
  // Питание
  updateNutrition,
  swapMeal,
  
  // Тренировки
  swapExercise,
  setGoal,
  setLevel,
  
  // Профиль
  setWeight,
  setHeight,
  setAge,
  
  // Настройки
  setLanguage,
  toggleNotifications,
  setReminder,
  
  // Система
  help,
  status,
  export,
  unknown,
}

/// Результат парсинга команды
class CommandResult {
  final CommandType type;
  final bool success;
  final Map<String, dynamic> data;
  final String message;

  CommandResult({
    required this.type,
    required this.success,
    required this.data,
    required this.message,
  });
}
