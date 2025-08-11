import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../state/app_providers.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        GlassCard(child: ListTile(
          leading: const CircleAvatar(radius: 28, child: Icon(Icons.person_rounded)),
          title: Text(user == null ? 'Athlete' : 'ID: ${user.id}'),
          subtitle: Text(user == null ? 'Цель не задана' : 'Цель: ${user.goal}'),
        )),
        const SizedBox(height: 12),
        const GlassCard(child: ListTile(
          leading: Icon(Icons.insights_rounded),
          title: Text('Аналитика'),
          subtitle: Text('Общее время, калории, прогресс'),
          trailing: Icon(Icons.chevron_right_rounded),
        )),
        const SizedBox(height: 12),
        const GlassCard(child: ListTile(
          leading: Icon(Icons.settings_rounded),
          title: Text('Настройки'),
          subtitle: Text('Тема, единицы, напоминания'),
          trailing: Icon(Icons.chevron_right_rounded),
        )),
      ],
    );
  }
}