import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme.dart';
import '../state/user_state.dart';
import 'home_screen.dart';  // <– импорт главного экрана

class BodyScanScreen extends ConsumerStatefulWidget {
  const BodyScanScreen({super.key});

  @override
  ConsumerState<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends ConsumerState<BodyScanScreen> {
  String? _path;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _path = img.path);
      final n = ref.read(userProvider.notifier);
      await n.setBodyImagePath(img.path);
      n.setComposition(fatPct: 20, musclePct: 70);
    }
  }

  // Переход на экран создания программы тренировок (HomeScreen → вкладка "Тренировка")
  void _closeToTraining() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Фото тела'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Закрыть',
              onPressed: _closeToTraining,  // <– используем новый метод
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _path == null
                      ? const Text('Загрузите фото для анализа тела')
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(File(_path!), fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _pick,
                icon: const Icon(Icons.photo),
                label: Text(_path == null ? 'Загрузить фото' : 'Заменить фото'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
