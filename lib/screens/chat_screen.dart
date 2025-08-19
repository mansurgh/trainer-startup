import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  bool get _empty => _msgs.isEmpty;

  Future<void> _send({String? text, String? imagePath}) async {
    if ((text == null || text.trim().isEmpty) && imagePath == null) return;
    setState(() => _msgs.add(_Msg.user(text: text?.trim(), imagePath: imagePath)));
    _controller.clear();

    // автоскролл
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _listCtrl.animateTo(_listCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

    // заглушка ответа бота
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _msgs.add(_Msg.bot(text: 'Принято ✅\n• Могу посчитать ккал по фото\n• Подскажу рацион\n• Отвечу на вопросы по тренировкам')));
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
                'В этом чате можно:\n'
                '• Получать советы по питанию и тренировкам\n'
                '• Считать калории по фото блюд\n'
                '• Делать аудит рациона/добавок\n'
                '• Связаться с оператором для помощи и отзывов',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _listCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                final bg = m.fromUser ? const Color(0xFF6D5DF6) : Colors.white.withValues(alpha: 0.06);
                final fg = m.fromUser ? Colors.white : Colors.white;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
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
                  IconButton(onPressed: _pickImage, icon: const Icon(Icons.image_rounded)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (v) => _send(text: v),
                      decoration: const InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                        isDense: true,
                      ),
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
