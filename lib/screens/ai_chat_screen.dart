import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../core/design_tokens.dart';
import '../core/premium_components.dart';
import '../services/ai_service.dart';
import '../services/workout_service.dart';
import '../state/app_providers.dart';
import '../utils/chat_command_parser.dart';
import '../screens/tabs/nutrition_screen_v2.dart';

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
    _initializeChat();
  }

  void _initializeChat() {
    String welcomeMessage;
    switch (widget.chatType) {
      case 'workout':
        welcomeMessage = '💪 Привет! Я ваш AI тренер.\n\n'
                        'Доступные команды:\n'
                        '• /plan - создать план тренировок\n'
                        '• /form - проверить технику упражнения\n'
                        '• /advice - получить совет по тренировкам\n'
                        '• /progress - анализ прогресса\n\n'
                        'Или просто задайте вопрос!';
        break;
      case 'nutrition':
        welcomeMessage = '🥗 Здравствуйте! Я AI диетолог.\n\n'
                        'Доступные команды:\n'
                        '• /meal - создать план питания\n'
                        '• /analyze - проанализировать фото еды\n'
                        '• /recipe - получить рецепт\n'
                        '• /calories - рассчитать калорийность\n\n'
                        'Чем могу помочь?';
        break;
      default:
        welcomeMessage = '👋 Привет! Я ваш персональный AI фитнес-помощник.\n\n'
                        'Могу помочь с:\n'
                        '• Тренировками и упражнениями\n'
                        '• Планированием питания\n'
                        '• Мотивацией и советами\n'
                        '• Анализом прогресса\n\n'
                        'Что вас интересует?';
    }

    _messages.add(ChatMessage(
      text: welcomeMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgBase,
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
      backgroundColor: DesignTokens.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DesignTokens.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignTokens.cardSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: DesignTokens.textPrimary,
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
                    color: DesignTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isTyping)
                  Text(
                    'печатает...',
                    style: TextStyle(
                      color: DesignTokens.textSecondary,
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
      color: DesignTokens.bgBase,
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
                color: DesignTokens.cardSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: DesignTokens.textSecondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isFromUser 
                    ? const Color(0xFF2B5278) // Telegram синий для исходящих
                    : DesignTokens.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isFromUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isFromUser ? const Radius.circular(4) : const Radius.circular(18),
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
                        color: DesignTokens.textPrimary,
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
                              ? DesignTokens.textPrimary.withOpacity(0.6)
                              : DesignTokens.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (isFromUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: DesignTokens.textPrimary.withOpacity(0.6),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        border: Border(
          top: BorderSide(
            color: DesignTokens.cardSurface,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Предпросмотр выбранного изображения
          if (_selectedImagePath != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.cardSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImagePath!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Изображение прикреплено',
                      style: TextStyle(
                        color: DesignTokens.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: DesignTokens.textSecondary, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedImagePath = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Поле ввода и кнопки
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Кнопка прикрепления фото
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: DesignTokens.cardSurface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.attach_file, color: DesignTokens.textSecondary),
                  onPressed: _pickImage,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
              
              // Поле ввода
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: DesignTokens.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      color: DesignTokens.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Сообщение',
                      hintStyle: TextStyle(
                        color: DesignTokens.textSecondary,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Кнопка отправки
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2B5278), // Telegram синий
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isTyping
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _isTyping ? null : _sendMessage,
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getChatTitle() {
    switch (widget.chatType) {
      case 'workout':
        return 'AI Тренер';
      case 'nutrition':
        return 'AI Диетолог';
      default:
        return 'AI Помощник';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось выбрать изображение: $e'),
          backgroundColor: DesignTokens.error,
        ),
      );
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
    final userId = prefs.getString('user_id') ?? 'anonymous';
    
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
