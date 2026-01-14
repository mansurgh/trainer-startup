import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design_tokens.dart';
import '../theme/app_theme.dart';
import '../core/premium_components.dart';
import '../widgets/app_alert.dart';
import '../services/ai_service.dart';
import '../services/workout_service.dart';
import '../services/notification_service.dart';
import '../state/app_providers.dart';
import '../state/user_state.dart';
import '../utils/chat_command_parser.dart';
import '../screens/tabs/nutrition_screen_v2.dart';
import '../l10n/app_localizations.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final String chatType; // 'workout', 'nutrition', 'general'
  
  const AIChatScreen({
    super.key,
    this.chatType = 'general',
  });

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isTyping = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    // Defer initialization until after first frame to have proper context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    String welcomeMessage;
    switch (widget.chatType) {
      case 'workout':
        welcomeMessage = isRussian
            ? '💪 Привет! Я ваш AI тренер.\n\n'
              'Доступные команды:\n'
              '• /plan - создать план тренировок\n'
              '• /form - проверить технику упражнения\n'
              '• /advice - получить совет по тренировкам\n'
              '• /progress - анализ прогресса\n\n'
              'Или просто задайте вопрос!'
            : '💪 Hi! I am your AI trainer.\n\n'
              'Available commands:\n'
              '• /plan - create workout plan\n'
              '• /form - check exercise form\n'
              '• /advice - get training advice\n'
              '• /progress - progress analysis\n\n'
              'Or just ask a question!';
        break;
      case 'nutrition':
        welcomeMessage = isRussian
            ? '🥗 Здравствуйте! Я AI диетолог.\n\n'
              'Доступные команды:\n'
              '• /meal - создать план питания\n'
              '• /analyze - проанализировать фото еды\n'
              '• /recipe - получить рецепт\n'
              '• /calories - рассчитать калорийность\n\n'
              'Чем могу помочь?'
            : '🥗 Hello! I am your AI nutritionist.\n\n'
              'Available commands:\n'
              '• /meal - create meal plan\n'
              '• /analyze - analyze food photo\n'
              '• /recipe - get a recipe\n'
              '• /calories - calculate calories\n\n'
              'How can I help?';
        break;
      default:
        welcomeMessage = isRussian
            ? '👋 Привет! Я ваш персональный AI фитнес-помощник.\n\n'
              'Могу помочь с:\n'
              '• Тренировками и упражнениями\n'
              '• Планированием питания\n'
              '• Мотивацией и советами\n'
              '• Анализом прогресса\n\n'
              'Что вас интересует?'
            : '👋 Hi! I am your personal AI fitness assistant.\n\n'
              'I can help with:\n'
              '• Workouts and exercises\n'
              '• Meal planning\n'
              '• Motivation and tips\n'
              '• Progress analysis\n\n'
              'What are you interested in?';
    }

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeMessage,
        isFromUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOledBlack, // OLED Black background
      appBar: _buildChatAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: kOledBlack,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kTextPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: kElectricAmberGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getChatTitle(),
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isTyping)
                  Text(
                    Localizations.localeOf(context).languageCode == 'ru' 
                        ? 'печатает...' 
                        : 'typing...',
                    style: const TextStyle(
                      color: kInfoCyan,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: kOledBlack,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isFromUser = message.isFromUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Аватар для AI (слева)
          if (!isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: kElectricAmberGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
          
          // Сообщение
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser 
                    ? kInfoCyan.withOpacity(0.25) // Neon Cyan для пользователя
                    : kObsidianSurface.withOpacity(0.6), // Темно-серый для AI
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isFromUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isFromUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: Border.all(
                  color: isFromUser
                      ? kInfoCyan.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Изображение, если прикреплено
                  if (message.imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(message.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  
                  // Текст сообщения
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Время
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isFromUser
                              ? kTextPrimary.withOpacity(0.6)
                              : kTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (isFromUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: kInfoCyan.withOpacity(0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Отступ справа для исходящих
          if (isFromUser) const SizedBox(width: 8),
        ],
      ),
    ).animate()
     .fadeIn(duration: 200.ms, delay: Duration(milliseconds: index * 50))
     .slideX(begin: isFromUser ? 0.2 : -0.2, end: 0);
  }

  Widget _buildInputArea() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: bottomPadding + 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image preview
              if (_selectedImagePath != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kInfoCyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_selectedImagePath!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'ru'
                              ? 'Изображение прикреплено'
                              : 'Image attached',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedImagePath = null);
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withOpacity(0.6),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Поле ввода и кнопки
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Кнопка прикрепления фото
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _pickImage();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 22,
                      ),
                    ),
                  ),
                  
                  // Поле ввода - glassmorphic pill
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120, minHeight: 44),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: Localizations.localeOf(context).languageCode == 'ru'
                              ? 'Сообщение…'
                              : 'Message…',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Send button - amber gradient
                  GestureDetector(
                    onTap: _isTyping ? null : () {
                      HapticFeedback.mediumImpact();
                      _sendMessage();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: kElectricAmberGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kElectricAmberStart.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isTyping
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getChatTitle() {
    final l10n = AppLocalizations.of(context);
    switch (widget.chatType) {
      case 'workout':
        return l10n?.aiTrainer ?? 'AI Trainer';
      case 'nutrition':
        return l10n?.aiNutritionist ?? 'AI Nutritionist';
      default:
        return l10n?.aiAssistant ?? 'AI Assistant';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final imagePath = _selectedImagePath;
    
    if (text.isEmpty && imagePath == null) return;
    if (_isTyping) return;

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(ChatMessage(
        text: text.isEmpty ? 'Изображение' : text,
        isFromUser: true,
        timestamp: DateTime.now(),
        imagePath: imagePath,
      ));
      _isTyping = true;
      _selectedImagePath = null; // Очищаем выбранное изображение
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Проверяем является ли сообщение командой
      if (ChatCommandParser.isCommand(text)) {
        final commandResult = ChatCommandParser.parseCommand(text);
        
        if (commandResult != null) {
          // Обрабатываем команду
          await _handleCommand(commandResult);
          
          // Показываем результат
          setState(() {
            _messages.add(ChatMessage(
              text: commandResult.message,
              isFromUser: false,
              timestamp: DateTime.now(),
            ));
            _isTyping = false;
          });
          _scrollToBottom();
          return;
        }
      }
      
      // Обычный AI ответ если это не команда
      final aiService = ref.read(aiServiceProvider);
      String response;

      // Выбираем метод AI сервиса в зависимости от типа чата
      switch (widget.chatType) {
        case 'workout':
          final aiResponse = await aiService.generateWorkoutPlan(
            fitnessLevel: 'intermediate',
            goals: text,
            daysPerWeek: 3,
          );
          response = aiResponse.message;
          break;
        case 'nutrition':
          final aiResponse = await aiService.analyzeNutrition(
            currentDiet: 'Анализ текущего рациона',
            goals: text,
          );
          response = aiResponse.message;
          break;
        default:
          // Создаём общий AI чат запрос
          response = await _getGeneralAIResponse(text);
      }

      // Добавляем ответ AI
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isFromUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });

      // Проверяем, содержит ли ответ AI команду
      if (ChatCommandParser.isCommand(response)) {
        // Ищем команду в тексте ответа (может быть в конце или отдельной строкой)
        final lines = response.split('\n');
        for (final line in lines) {
          if (ChatCommandParser.isCommand(line)) {
            final commandResult = ChatCommandParser.parseCommand(line);
            if (commandResult != null) {
              await _handleCommand(commandResult);
              // Опционально: показать сообщение о выполнении команды
              /*
              setState(() {
                _messages.add(ChatMessage(
                  text: '⚡ Auto-executed: ${commandResult.message}',
                  isFromUser: false,
                  timestamp: DateTime.now(),
                ));
              });
              */
            }
          }
        }
      }

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Извините, произошла ошибка. Попробуйте ещё раз.',
          isFromUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
  }

  Future<String> _getGeneralAIResponse(String userMessage) async {
    // Простая имитация AI ответа для демо
    await Future.delayed(const Duration(seconds: 2));
    
    final responses = [
      'Отличный вопрос! Рекомендую начать с базовых упражнений и постепенно увеличивать нагрузку.',
      'Это важная тема для здоровья. Сбалансированное питание и регулярные тренировки - основа успеха.',
      'Помните, что постоянство важнее интенсивности. Лучше заниматься 3 раза в неделю регулярно.',
      'Отличная мотивация! Правильное планирование поможет достичь ваших целей быстрее.',
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: DesignTokens.durationMedium,
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _pickImage() async {
    // Check platform - ImagePicker camera doesn't work on Windows/Linux/macOS
    if (!Platform.isAndroid && !Platform.isIOS) {
      // On desktop - only gallery is available
      try {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            _selectedImagePath = image.path;
          });
        }
      } catch (e) {
        // Silently ignore - gallery might not be supported
        if (mounted) {
          AppAlert.showError(
            context, 
            Localizations.localeOf(context).languageCode == 'ru'
                ? 'Выбор изображений недоступен'
                : 'Image selection not available',
          );
        }
      }
      return;
    }
    
    // Mobile platforms - show picker options
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppAlert.showError(
          context, 
          Localizations.localeOf(context).languageCode == 'ru'
              ? 'Не удалось выбрать изображение'
              : 'Failed to pick image',
        );
      }
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _initializeChat();
    });
  }
  
  Future<void> _handleCommand(CommandResult command) async {
    final prefs = await SharedPreferences.getInstance();
    final user = ref.read(userProvider);
    final userId = user?.id ?? 'anonymous';
    
    switch (command.type) {
      case CommandType.updateNutrition:
        // Получаем тип макронутриента и значение из data
        final nutrientType = command.data['nutrientType'] as String;
        final value = command.data['value'] as int;
        
        // Сохраняем новое значение
        await prefs.setInt('nutrition_goal_${userId}_$nutrientType', value);
        
        // Инвалидируем провайдеры для обновления UI с задержкой
        ref.invalidate(dailyTotalsProvider);
        await Future.delayed(const Duration(milliseconds: 150));
        ref.invalidate(dailyTotalsProvider);
        break;
        
      case CommandType.swapMeal:
        // TODO: Реализовать замену блюда через базу данных
        // Требуется доступ к MealService и обновление meal_plans
        break;
        
      case CommandType.swapExercise:
        // Получаем старое и новое упражнение
        final oldExercise = command.data['oldExercise'] as String;
        final newExercise = command.data['newExercise'] as String;
        
        // Используем WorkoutService для замены
        final workoutService = WorkoutService();
        final success = await workoutService.swapExercise(oldExercise, newExercise);
        
        if (!success) {
          // Если замена не удалась, добавляем сообщение об ошибке
          setState(() {
            _messages.add(ChatMessage(
              text: 'Не удалось найти упражнение "$oldExercise" в текущей тренировке. Добавлено новое упражнение "$newExercise".',
              isFromUser: false,
              timestamp: DateTime.now(),
            ));
          });
        }
        break;
      
      case CommandType.setGoal:
        final goal = command.data['goal'] as String;
        // Обновляем через userProvider для синхронизации с Supabase
        await ref.read(userProvider.notifier).setParams(goal: goal);
        break;
      
      case CommandType.setLevel:
        final level = command.data['level'] as String;
        await prefs.setString('user_level_$userId', level);
        break;
      
      case CommandType.setWeight:
        final weight = command.data['weight'] as double;
        // Обновляем через userProvider для синхронизации с Supabase
        await ref.read(userProvider.notifier).setParams(weight: weight);
        break;
      
      case CommandType.setHeight:
        final height = command.data['height'] as int;
        // Обновляем через userProvider для синхронизации с Supabase
        await ref.read(userProvider.notifier).setParams(height: height);
        break;
      
      case CommandType.setAge:
        final age = command.data['age'] as int;
        // Обновляем через userProvider для синхронизации с Supabase
        await ref.read(userProvider.notifier).setParams(age: age);
        break;
      
      case CommandType.setLanguage:
        final language = command.data['language'] as String;
        await prefs.setString('app_language', language);
        // Требуется перезапуск приложения для применения
        setState(() {
          _messages.add(ChatMessage(
            text: '🔄 Перезапустите приложение для применения нового языка.',
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        break;
      
      case CommandType.toggleNotifications:
        final current = prefs.getBool('notifications_enabled') ?? true;
        await prefs.setBool('notifications_enabled', !current);
        setState(() {
          _messages.add(ChatMessage(
            text: !current ? '🔔 Уведомления включены' : '🔕 Уведомления выключены',
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        break;
      
      case CommandType.setReminder:
        final hours = command.data['hours'] as int;
        final minutes = command.data['minutes'] as int;
        await prefs.setInt('reminder_hours', hours);
        await prefs.setInt('reminder_minutes', minutes);
        
        // Интегрируем с NotificationService
        try {
          final now = DateTime.now();
          var scheduledTime = DateTime(now.year, now.month, now.day, hours, minutes);
          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }
          
          await NotificationService.scheduleWorkoutReminder(
            id: 1001,
            title: '💪 Время тренировки!',
            body: 'Не забудь сегодня позаниматься. Твой фитнес-помощник ждёт!',
            scheduledTime: scheduledTime,
          );
          
          setState(() {
            _messages.add(ChatMessage(
              text: '⏰ Напоминание установлено на ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
              isFromUser: false,
              timestamp: DateTime.now(),
            ));
          });
        } catch (e) {
          setState(() {
            _messages.add(ChatMessage(
              text: '⚠️ Не удалось установить напоминание: $e',
              isFromUser: false,
              timestamp: DateTime.now(),
            ));
          });
        }
        break;
      
      case CommandType.status:
        // Собираем данные из userProvider (синхронизировано с Supabase)
        final currentUser = ref.read(userProvider);
        final weight = currentUser?.weight ?? 0;
        final height = currentUser?.height ?? 0;
        final age = currentUser?.age ?? 0;
        final goal = currentUser?.goal ?? 'не указана';
        final calories = prefs.getInt('nutrition_goal_${userId}_calories') ?? 2000;
        final protein = prefs.getInt('nutrition_goal_${userId}_protein') ?? 150;
        
        setState(() {
          _messages.add(ChatMessage(
            text: '''📊 **Текущий статус**

👤 Профиль:
• Вес: ${weight > 0 ? '${weight.toStringAsFixed(1)} кг' : 'не указан'}
• Рост: ${height > 0 ? '$height см' : 'не указан'}
• Возраст: ${age > 0 ? '$age лет' : 'не указан'}
• Цель: $goal

🍎 Цели питания:
• Калории: $calories ккал
• Белок: $protein г

💪 Тренировки:
• Уровень: ${prefs.getString('user_level_$userId') ?? 'не указан'}

☁️ Синхронизация: ${currentUser != null ? 'активна' : 'офлайн'}
''',
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        break;
      
      case CommandType.export:
        setState(() {
          _messages.add(ChatMessage(
            text: '📤 Функция экспорта данных скоро будет доступна!\n\nДанные будут экспортированы в формате JSON.',
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });
        break;
        
      case CommandType.help:
        // Помощь отображается через commandResult.message
        break;
        
      case CommandType.unknown:
        // Ошибка отображается через commandResult.message
        break;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? imagePath;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.imagePath,
  });
}
