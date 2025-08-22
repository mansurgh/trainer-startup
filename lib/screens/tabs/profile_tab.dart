import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/user_state.dart';
import '../body_scan_screen.dart';
import '../edit_profile_data_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    ImageProvider avatarProvider() {
      if (user?.bodyImagePath != null && user!.bodyImagePath!.isNotEmpty) {
        final f = File(user.bodyImagePath!);
        if (f.existsSync()) return FileImage(f);
      }
      return const AssetImage('assets/placeholder/profile.jpg');
    }

    final name = (user?.name?.isNotEmpty == true) ? user!.name! : 'Гость';

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Профиль'),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BodyScanScreen())),
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: 'Фото тела',
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
            const SizedBox(height: 12),

            // параметры
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip('Пол', _genderRu(user?.gender)),
                _infoChip('Возраст', user?.age?.toString() ?? '—'),
                _infoChip('Рост', user?.height?.toString() ?? '—'),
                _infoChip('Вес', user?.weight?.toString() ?? '—'),
                _infoChip('Цель', (user?.goal ?? '—')),
              ],
            ),
            const SizedBox(height: 12),

            FilledButton.tonal(
              onPressed: () {
                // перейти на экран редактирования данных профиля
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileDataScreen()));
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
