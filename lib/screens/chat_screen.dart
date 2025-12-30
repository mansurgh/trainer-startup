import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/design_tokens.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../models/ai_response.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _Msg {
  final String id;
  final bool fromUser;
  final String? text;
  final String? imagePath;
  final DateTime createdAt;
  
  _Msg.user({this.text, this.imagePath, String? id}) 
      : fromUser = true, 
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();
        
  _Msg.bot({this.text, String? id}) 
      : fromUser = false, 
        imagePath = null,
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();
        
  _Msg.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        fromUser = (json['role'] as String) == 'user',
        text = json['content'] as String?,
        imagePath = json['image_path'] as String?,
        createdAt = DateTime.parse(json['created_at'] as String);
        
  Map<String, dynamic> toDbJson(String userId) => {
    'user_id': userId,
    'role': fromUser ? 'user' : 'assistant',
    'content': text ?? '',
    'image_path': imagePath,
  };
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _listCtrl = ScrollController();
  final List<_Msg> _msgs = [];
  final AIService _aiService = AIService();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }
  
  Future<void> _loadChatHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _showWelcomeMessage();
        return;
      }

      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .limit(100);

      final List<dynamic> data = response as List<dynamic>;
      
      setState(() {
        _msgs.clear();
        for (final json in data) {
          _msgs.add(_Msg.fromJson(json));
        }
        _historyLoaded = true;
        
        // Если история пустая, показываем приветствие
        if (_msgs.isEmpty) {
          _showWelcomeMessage();
        }
      });
      
      // Скролл в конец
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _listCtrl.hasClients) {
        _listCtrl.jumpTo(_listCtrl.position.maxScrollExtent);
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      _showWelcomeMessage();
    }
  }
  
  void _showWelcomeMessage() {
    setState(() {
      _msgs.add(_Msg.bot(
        text: '👋 Привет! Я PulseFit AI — твой персональный помощник.\n\n'
              '💬 Что я умею:\n'
              '• Анализ фото еды — узнай калории\n'
              '• Разбор техники упражнений\n'
              '• Советы по тренировкам и питанию\n'
              '• Мотивация и поддержка\n\n'
              '📝 Команды:\n'
              '/help — показать помощь\n'
              '/clear — очистить историю чата\n'
              '/stats — твоя статистика\n\n'
              'Спрашивай что угодно! 💪',
      ));
      _historyLoaded = true;
    });
  }
  
  Future<void> _saveMsgToDb(_Msg msg) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase.from('chat_messages').insert(msg.toDbJson(userId));
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }
  
  Future<void> _clearChatHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase.from('chat_messages').delete().eq('user_id', userId);
      
      setState(() {
        _msgs.clear();
        _showWelcomeMessage();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('История чата очищена'),
            backgroundColor: kSuccessGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }
  }
  
  void _handleCommand(String cmd) {
    switch (cmd.toLowerCase()) {
      case '/help':
        setState(() {
          _msgs.add(_Msg.bot(
            text: '📚 Справка по командам:\n\n'
                  '/help — показать это сообщение\n'
                  '/clear — очистить историю чата\n'
                  '/stats — показать твою статистику\n\n'
                  '💡 Подсказки:\n'
                  '• Отправь фото еды для анализа калорий\n'
                  '• Отправь фото упражнения для разбора техники\n'
                  '• Задавай любые вопросы о фитнесе!',
          ));
        });
        break;
        
      case '/clear':
        _clearChatHistory();
        break;
        
      case '/stats':
        setState(() {
          _msgs.add(_Msg.bot(
            text: '📊 Твоя статистика:\n\n'
                  '💬 Сообщений: ${_msgs.length}\n'
                  '📅 Сегодня: ${_getTodayMsgCount()} сообщений\n\n'
                  'Подробную статистику смотри в профиле! 📈',
          ));
        });
        break;
        
      default:
        // Не команда, обработать как обычное сообщение
        break;
    }
  }
  
  int _getTodayMsgCount() {
    final today = DateTime.now();
    return _msgs.where((m) => 
      m.createdAt.year == today.year &&
      m.createdAt.month == today.month &&
      m.createdAt.day == today.day
    ).length;
  }

  Future<void> _send({String? text, String? imagePath}) async {
    if ((text == null || text.trim().isEmpty) && imagePath == null) return;
    
    final trimmedText = text?.trim();
    
    // Проверяем команды
    if (trimmedText != null && trimmedText.startsWith('/')) {
      _handleCommand(trimmedText);
      _controller.clear();
      return;
    }
    
    final userMsg = _Msg.user(text: trimmedText, imagePath: imagePath);
    setState(() {
      _msgs.add(userMsg);
      _isLoading = true;
    });
    _controller.clear();
    
    // Сохраняем сообщение пользователя
    _saveMsgToDb(userMsg);

    // автоскролл
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted && _listCtrl.hasClients) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    try {
      // Получаем ответ от AI
      final response = await _aiService.getResponse(
        trimmedText ?? 'Проанализируй это фото',
        imagePath: imagePath,
      );
      
      if (mounted) {
        final botMsg = _Msg.bot(text: response.message);
        setState(() {
          _msgs.add(botMsg);
          _isLoading = false;
        });
        
        // Сохраняем ответ бота
        _saveMsgToDb(botMsg);
        
        // автоскролл после ответа
        await Future.delayed(const Duration(milliseconds: 100));
        if (_listCtrl.hasClients) {
          _listCtrl.animateTo(
            _listCtrl.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _Msg.bot(text: 'Извините, произошла ошибка. Попробуйте еще раз.');
        setState(() {
          _msgs.add(errorMsg);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) _send(imagePath: img.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOledBlack, // OLED Black background
      appBar: AppBar(
        title: const Text('Чат с тренером'),
        backgroundColor: kOledBlack,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _listCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _msgs.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: kObsidianSurface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'AI думает...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final m = _msgs[i];
                final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                // Glassmorphism для сообщений
                final bg = m.fromUser
                    ? kInfoCyan.withOpacity(0.2) // Neon Cyan для пользователя
                    : kObsidianSurface.withOpacity(0.6); // Темно-серый для бота
                final fg = kTextPrimary;

                return Align(
                  alignment: align,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: m.fromUser 
                                ? kInfoCyan.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (m.imagePath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(File(m.imagePath!), width: 260, fit: BoxFit.cover),
                              ),
                            if (m.text != null) ...[
                              if (m.imagePath != null) const SizedBox(height: 8),
                              Text(m.text!, style: TextStyle(color: fg)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: kObsidianSurface.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            style: const TextStyle(color: kTextPrimary),
                            decoration: InputDecoration(
                              hintText: 'Сообщение…',
                              hintStyle: TextStyle(color: kTextSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (text) => _send(text: text),
                          ),
                        ),
                        IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.attach_file_rounded, color: kInfoCyan, size: 22),
                          tooltip: 'Прикрепить фото',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            gradient: kElectricAmberGradient,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => _send(text: _controller.text),
                            icon: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
