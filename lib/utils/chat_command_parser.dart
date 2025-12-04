/// Парсер команд для AI чатов (тренер и нутрициолог)
class ChatCommandParser {
  /// Список доступных команд
  static const List<String> availableCommands = [
    '/fat <value>',
    '/protein <value>',
    '/carbs <value>',
    '/calories <value>',
    '/swap_meal <old> -> <new>',
    '/swap_exercise <old> -> <new>',
    '/help',
  ];

  /// Проверка является ли сообщение командой
  static bool isCommand(String message) {
    return message.trim().startsWith('/');
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
      case '/fat':
      case '/protein':
      case '/carbs':
      case '/calories':
        return _parseNutritionCommand(command, args);
      
      case '/swap_meal':
        return _parseSwapMealCommand(args);
      
      case '/swap_exercise':
        return _parseSwapExerciseCommand(args);
      
      case '/help':
        return CommandResult(
          type: CommandType.help,
          success: true,
          data: {},
          message: _getHelpMessage(),
        );
      
      default:
        return CommandResult(
          type: CommandType.unknown,
          success: false,
          data: {},
          message: 'Unknown command: $command\nType /help to see available commands.',
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
        message: 'Invalid value. Usage: $command <number>\nExample: $command 60',
      );
    }

    // Определяем тип макронутриента
    String nutrientType;
    String unit;
    switch (command) {
      case '/calories':
        nutrientType = 'calories';
        unit = 'kcal';
        break;
      case '/fat':
        nutrientType = 'fat';
        unit = 'g';
        break;
      case '/protein':
        nutrientType = 'protein';
        unit = 'g';
        break;
      case '/carbs':
        nutrientType = 'carbs';
        unit = 'g';
        break;
      default:
        return CommandResult(
          type: CommandType.updateNutrition,
          success: false,
          data: {},
          message: 'Unknown nutrient type',
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
      message: 'Goal updated: $nutrientType = $value $unit',
    );
  }

  /// Парсинг команды замены блюда
  static CommandResult _parseSwapMealCommand(String args) {
    // Формат: old_meal -> new_meal
    final parts = args.split('->');
    
    if (parts.length != 2) {
      return CommandResult(
        type: CommandType.swapMeal,
        success: false,
        data: {},
        message: 'Invalid format. Usage: /swap_meal <old meal> -> <new meal>\n'
                 'Example: /swap_meal pasta -> rice',
      );
    }

    final oldMeal = parts[0].trim();
    final newMeal = parts[1].trim();

    if (oldMeal.isEmpty || newMeal.isEmpty) {
      return CommandResult(
        type: CommandType.swapMeal,
        success: false,
        data: {},
        message: 'Both meal names are required.',
      );
    }

    return CommandResult(
      type: CommandType.swapMeal,
      success: true,
      data: {
        'oldMeal': oldMeal,
        'newMeal': newMeal,
      },
      message: 'Meal swap request: "$oldMeal" → "$newMeal"',
    );
  }

  /// Парсинг команды замены упражнения
  static CommandResult _parseSwapExerciseCommand(String args) {
    // Формат: old_exercise -> new_exercise
    final parts = args.split('->');
    
    if (parts.length != 2) {
      return CommandResult(
        type: CommandType.swapExercise,
        success: false,
        data: {},
        message: 'Invalid format. Usage: /swap_exercise <old> -> <new>\n'
                 'Example: /swap_exercise bench press -> dumbbell press',
      );
    }

    final oldExercise = parts[0].trim();
    final newExercise = parts[1].trim();

    if (oldExercise.isEmpty || newExercise.isEmpty) {
      return CommandResult(
        type: CommandType.swapExercise,
        success: false,
        data: {},
        message: 'Both exercise names are required.',
      );
    }

    return CommandResult(
      type: CommandType.swapExercise,
      success: true,
      data: {
        'oldExercise': oldExercise,
        'newExercise': newExercise,
      },
      message: 'Exercise swap request: "$oldExercise" → "$newExercise"',
    );
  }

  /// Сообщение помощи
  static String _getHelpMessage() {
    return '''
📋 Available Commands:

Nutrition Goals:
/calories <value> - Set daily calorie goal (kcal)
/protein <value> - Set protein goal (g)
/fat <value> - Set fat goal (g)
/carbs <value> - Set carbs goal (g)

Example: /fat 60

Meal Planning:
/swap_meal <old> -> <new> - Replace a meal
Example: /swap_meal pasta -> rice

Workout Planning:
/swap_exercise <old> -> <new> - Replace an exercise
Example: /swap_exercise squat -> leg press

Other:
/help - Show this help message

⚠️ Note: You cannot directly modify statistics or completion data.
Commands only change settings and preferences.
''';
  }
}

/// Тип команды
enum CommandType {
  updateNutrition,
  swapMeal,
  swapExercise,
  help,
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
