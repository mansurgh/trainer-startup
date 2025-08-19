import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/user_state.dart';
import '../body_scan_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    ImageProvider avatarProvider() {
      if (user?.bodyImagePath != null && File(user!.bodyImagePath!).existsSync()) {
        return FileImage(File(user.bodyImagePath!));
      }
      return const AssetImage('assets/placeholder/profile.jpg');
    }

    final name = (user?.name?.isNotEmpty == true) ? user!.name! : 'Профиль';

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Профиль'),
          actions: [
            IconButton(
              tooltip: 'Настройки',
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                // TODO: открыть экран настроек
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Шапка с именем в левом-нижнем углу
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image(image: avatarProvider(), fit: BoxFit.cover),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Card(
              color: Colors.white.withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  runSpacing: 10,
                  spacing: 16,
                  children: [
                    _infoChip('Пол', _genderRu(user?.gender)),
                    _infoChip('Возраст', _maybe(user?.age, suffix: ' лет')),
                    _infoChip('Рост', _maybe(user?.height, suffix: ' см')),
                    _infoChip('Вес', _maybeDouble(user?.weight, suffix: ' кг')),
                    _infoChip('Цель', _goalRu(user?.goal)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BodyScanScreen()));
              },
              child: const Text('Обновить фото тела'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () {
                // перейти на экран редактирования данных профиля (онбординг‑форма)
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BodyScanScreen()));
              },
              child: const Text('Изменить данные профиля'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.white.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String _maybe(int? v, {String suffix = ''}) => v == null ? '—' : '$v$suffix';
  String _maybeDouble(double? v, {String suffix = ''}) => v == null ? '—' : '${v.toStringAsFixed(1)}$suffix';

  String _goalRu(String? g) {
    switch (g) {
      case 'fat_loss':
        return 'Похудение';
      case 'muscle_gain':
        return 'Набор массы';
      case 'fitness':
        return 'Поддержание формы';
      default:
        return '—';
    }
  }

  String _genderRu(String? g) {
    switch (g) {
      case 'm':
        return 'Мужской';
      case 'f':
        return 'Женский';
      default:
        return '—';
    }
  }
}
