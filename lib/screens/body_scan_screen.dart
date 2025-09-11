import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme.dart';
import '../state/user_state.dart';
import 'home_screen.dart';  // <– импорт главного экрана

class BodyScanScreen extends ConsumerStatefulWidget {
  final bool fromOnboarding;
  
  const BodyScanScreen({
    super.key,
    this.fromOnboarding = false,
  });

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
      n.setComposition(fatPct: 20, musclePct: 40);
    }
  }

  // Переход на экран в зависимости от источника
  void _closeToNext() {
    if (widget.fromOnboarding) {
      // Из онбординга - переходим на тренировки
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(initialTab: 0), // 0 = вкладка тренировок
        ),
        (route) => false,
      );
    } else {
      // Из профиля - возвращаемся в профиль
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(initialTab: 2), // 2 = вкладка профиля
        ),
        (route) => false,
      );
    }
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
              onPressed: _closeToNext,  // <– используем новый метод
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
              if (_path == null)
                FilledButton.tonalIcon(
                  onPressed: _pick,
                  icon: const Icon(Icons.photo),
                  label: const Text('Загрузить фото'),
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _pick,
                            icon: const Icon(Icons.photo),
                            label: const Text('Заменить фото'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _closeToNext,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Далее'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.fromOnboarding 
                        ? 'Фото загружено! Нажмите "Далее" для перехода к программе тренировок.'
                        : 'Фото загружено! Нажмите "Далее" для перехода к профилю.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
