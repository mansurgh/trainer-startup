import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../state/app_providers.dart';
import '../models/ai_response.dart';
import '../models/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(chatProvider);
    final user = ref.watch(userProvider);
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('AI Тренер')),
        body: Column(children: [
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: msgs.length,
            itemBuilder: (_, i) => _Bubble(msgs[i]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Спроси о тренировке/еде...'))),
              const SizedBox(width: 8),
              PrimaryButton(label: 'Send', icon: Icons.send_rounded, onPressed: () async {
                if (user == null || ctrl.text.trim().isEmpty) return;
                final text = ctrl.text.trim(); ctrl.clear();
                await ref.read(chatProvider.notifier).sendText(user.id, text);
              }),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.m);
  final MessageModel m;
  @override
  Widget build(BuildContext context) {
    final isUser = m.actor.toString().contains('user');
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isUser ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.04);
    final border = isUser ? Colors.white38 : Colors.white24;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _bubbleContent(context),
      ),
    );
  }

  Widget _bubbleContent(BuildContext context) {
    if (m.contentType == ContentType.aiResponse && m.aiResponse != null) {
      final AIResponse resp = m.aiResponse!;
      final String title = switch (resp.type) {
        AIResponseType.general => 'Совет',
        AIResponseType.macros => 'КБЖУ',
        AIResponseType.tips => 'Подсказки',
        AIResponseType.program => 'Программа',
        AIResponseType.posture => 'Техника',
      };
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(resp.advice, style: const TextStyle(color: Colors.white70)),
      ]);
    }
    return Text(m.content ?? '', style: const TextStyle(color: Colors.white));
  }
}