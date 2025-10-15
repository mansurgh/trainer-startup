import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/design_tokens.dart';
import '../core/premium_components.dart';
import '../services/ai_service.dart';
import '../state/app_providers.dart';

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
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    String welcomeMessage;
    switch (widget.chatType) {
      case 'workout':
        welcomeMessage = 'Привет! Я ваш AI тренер. Готов помочь с планированием тренировок и техникой упражнений. О чём хотите поговорить?';
        break;
      case 'nutrition':
        welcomeMessage = 'Здравствуйте! Я AI диетолог. Помогу с планированием питания, подсчётом калорий и здоровыми рецептами. Что вас интересует?';
        break;
      default:
        welcomeMessage = 'Привет! Я ваш персональный AI фитнес-помощник. Могу помочь с тренировками, питанием и мотивацией. Как дела?';
    }

    _messages.add(ChatMessage(
      text: welcomeMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: DesignTokens.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildChatAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.space8),
            decoration: BoxDecoration(
              color: DesignTokens.primaryAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: DesignTokens.primaryAccent,
              size: 24,
            ),
          ),
          SizedBox(width: DesignTokens.space16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getChatTitle(),
                style: DesignTokens.bodyLarge.copyWith(
                  color: DesignTokens.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isTyping)
                Text(
                  'печатает...',
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.primaryAccent,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                 .fadeIn(duration: 500.ms)
                 .then()
                 .fadeOut(duration: 500.ms),
            ],
          ),
        ],
      ),

    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(DesignTokens.space16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isFromUser = message.isFromUser;
    
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.space16),
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            Container(
              padding: EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: DesignTokens.primaryAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: DesignTokens.primaryAccent,
                size: 16,
              ),
            ),
            SizedBox(width: DesignTokens.space8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                color: isFromUser 
                    ? DesignTokens.primaryAccent.withOpacity(0.8)
                    : DesignTokens.glassOverlay,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge).copyWith(
                  bottomRight: isFromUser 
                      ? Radius.circular(DesignTokens.space8)
                      : Radius.circular(DesignTokens.radiusLarge),
                  bottomLeft: !isFromUser 
                      ? Radius.circular(DesignTokens.space8)
                      : Radius.circular(DesignTokens.radiusLarge),
                ),
                border: Border.all(
                  color: isFromUser 
                      ? DesignTokens.primaryAccent.withOpacity(0.3)
                      : DesignTokens.glassBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: DesignTokens.bodyMedium.copyWith(
                      color: isFromUser 
                          ? DesignTokens.textPrimary
                          : DesignTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: DesignTokens.space8),
                  Text(
                    _formatTime(message.timestamp),
                    style: DesignTokens.caption.copyWith(
                      color: isFromUser 
                          ? DesignTokens.textPrimary.withOpacity(0.7)
                          : DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser) ...[
            SizedBox(width: DesignTokens.space8),
            Container(
              padding: EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: DesignTokens.primaryAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: DesignTokens.primaryAccent,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    ).animate()
     .fadeIn(delay: Duration(milliseconds: index * 100))
     .slideY(begin: 0.2, end: 0);
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.glassOverlay,
        border: Border(
          top: BorderSide(
            color: DesignTokens.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.glassOverlay,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                border: Border.all(
                  color: DesignTokens.glassBorder,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Напишите сообщение...',
                  hintStyle: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(DesignTokens.space16),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: DesignTokens.space16),
          PremiumComponents.glassButton(
            onPressed: _sendMessage,
            child: _isTyping 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(DesignTokens.textPrimary),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: DesignTokens.textPrimary,
                  ),
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
    if (text.isEmpty || _isTyping) return;

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isFromUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
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

  void _clearChat() {
    setState(() {
      _messages.clear();
      _initializeChat();
    });
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

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}
