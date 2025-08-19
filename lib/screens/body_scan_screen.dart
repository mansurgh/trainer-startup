import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme.dart';
import 'home_screen.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  String? _path;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    setState(() => _path = x.path);
    // TODO: здесь сохранение в профиль, если используешь стейт/бэк
  }

  void _closeToTraining() {
    // уходим на HomeScreen (по умолчанию открывается вкладка "Тренировка")
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
          automaticallyImplyLeading: false, // убираем стрелку
          title: const Text('Фото тела'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Закрыть',
              onPressed: _closeToTraining,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
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
