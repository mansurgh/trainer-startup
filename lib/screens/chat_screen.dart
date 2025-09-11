import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';
import '../models/ai_response.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _Msg {
  final bool fromUser;
  final String? text;
  final String? imagePath;
  _Msg.user({this.text, this.imagePath}) : fromUser = true;
  _Msg.bot({this.text}) : fromUser = false, imagePath = null;
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _listCtrl = ScrollController();
  final List<_Msg> _msgs = [];
  final AIService _aiService = AIService();
  bool _isLoading = false;
  bool get _empty => _msgs.isEmpty;

  Future<void> _send({String? text, String? imagePath}) async {
    if ((text == null || text.trim().isEmpty) && imagePath == null) return;
    setState(() {
      _msgs.add(_Msg.user(text: text?.trim(), imagePath: imagePath));
      _isLoading = true;
    });
    _controller.clear();

    // автоскролл
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    try {
      // Получаем ответ от AI
      final response = await _aiService.getResponse(
        text ?? 'Проанализируй это фото',
        imagePath: imagePath,
      );
      
      if (mounted) {
        setState(() {
          _msgs.add(_Msg.bot(text: response.message));
          _isLoading = false;
        });
        
        // автоскролл после ответа
        await Future.delayed(const Duration(milliseconds: 100));
        _listCtrl.animateTo(
          _listCtrl.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _msgs.add(_Msg.bot(text: 'Извините, произошла ошибка. Попробуйте еще раз.'));
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
      appBar: AppBar(title: const Text('Чат с тренером')),
      body: Column(
        children: [
          if (_empty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Отправь текст — отвечу: «Привет! Я твой тренер.»\n'
                'Пришли фото блюда — отвечу примерной калорийностью.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _listCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _msgs.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
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
                  );
                }
                final m = _msgs[i];
                final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                final bg = m.fromUser
                    ? const Color(0xFFB7A6FF).withOpacity(0.2)
                    : Colors.white.withValues(alpha: 0.06);
                final fg = m.fromUser ? Colors.white : Colors.white;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
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
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_outlined),
                    tooltip: 'Фото блюда',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Сообщение…'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _send(text: _controller.text),
                    child: const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
