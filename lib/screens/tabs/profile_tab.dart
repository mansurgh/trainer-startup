import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, name, avatarProvider()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  
                  // User Stats Overview
                  _buildStatsOverview(user).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Body Composition Chart
                  _buildBodyComposition(context, user).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Physical Parameters
                  _buildPhysicalParams(context, user).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Achievements Section
                  _buildAchievements(context).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  _buildQuickActions(context).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Profile Management
                  _buildProfileManagement(context).animate().fadeIn(duration: 800.ms, delay: 1000.ms).slideY(begin: 0.3),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String name, ImageProvider avatarProvider) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () => _showSettingsModal(context),
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Настройки',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: avatarProvider,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(UserModel? user) {
    final bmi = _calculateBMI(user);
    final fitnessLevel = _getFitnessLevel(user);
    
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'ИМТ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bmi,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.greenAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Уровень',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fitnessLevel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.timeline,
                  color: Colors.blueAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Прогресс',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '85%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyComposition(BuildContext context, UserModel? user) {
    final fatPct = user?.bodyFatPct ?? 20.0;
    final musclePct = user?.musclePct ?? 70.0;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.donut_large,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Состав тела',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularProgress(
                'Жир',
                fatPct,
                Colors.orangeAccent,
                100,
              ),
              _buildCircularProgress(
                'Мышцы',
                musclePct,
                Colors.greenAccent,
                100,
              ),
              _buildCircularProgress(
                'Вода',
                100 - fatPct - (musclePct * 0.4),
                Colors.blueAccent,
                100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(String label, double value, Color color, double max) {
    final percentage = (value / max).clamp(0.0, 1.0);
    
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.1)),
              ),
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Center(
                child: Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalParams(BuildContext context, UserModel? user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Физические параметры',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildParamCard('Пол', _genderRu(user?.gender), Icons.person),
              _buildParamCard('Возраст', '${user?.age ?? '—'} лет', Icons.cake),
              _buildParamCard('Рост', '${user?.height ?? '—'} см', Icons.height),
              _buildParamCard('Вес', '${user?.weight ?? '—'} кг', Icons.monitor_weight),
              _buildParamCard('Цель', _getGoalRu(user?.goal), Icons.flag),
              _buildParamCard('ИМТ', _calculateBMI(user), Icons.analytics),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParamCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amberAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Достижения',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAchievement(
                Icons.local_fire_department,
                'Огонь',
                '7 дней',
                Colors.redAccent,
                true,
              ),
              _buildAchievement(
                Icons.fitness_center,
                'Силач',
                '50 тренировок',
                Colors.blueAccent,
                true,
              ),
              _buildAchievement(
                Icons.schedule,
                'Постоянство',
                '30 дней',
                Colors.greenAccent,
                false,
              ),
              _buildAchievement(
                Icons.trending_up,
                'Прогресс',
                '10 кг',
                Colors.purpleAccent,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(IconData icon, String title, String subtitle, Color color, bool achieved) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: achieved ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: achieved ? color : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: achieved ? color : Colors.white.withOpacity(0.4),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: achieved ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Быстрые действия',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.camera_alt,
                  'Фото прогресса',
                  Colors.purpleAccent,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BodyScanScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.share,
                  'Поделиться',
                  Colors.greenAccent,
                  () => _shareProgress(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.analytics,
                  'Статистика',
                  Colors.blueAccent,
                  () => _showStatsModal(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.backup,
                  'Экспорт данных',
                  Colors.orangeAccent,
                  () => _exportData(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileManagement(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileDataScreen()),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Редактировать профиль'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showResetDialog(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Сбросить данные'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _calculateBMI(UserModel? user) {
    if (user?.height == null || user?.weight == null) return '—';
    final heightM = user!.height! / 100.0;
    final bmi = user.weight! / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  String _getFitnessLevel(UserModel? user) {
    final bmi = double.tryParse(_calculateBMI(user));
    if (bmi == null) return 'Новичок';
    
    if (bmi < 18.5) return 'Недовес';
    if (bmi < 25) return 'Норма';
    if (bmi < 30) return 'Избыток';
    return 'Ожирение';
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

  String _getGoalRu(String? goal) {
    switch (goal) {
      case 'fat_loss':
        return 'Похудение';
      case 'muscle_gain':
        return 'Набор массы';
      case 'fitness':
        return 'Фитнес';
      default:
        return '—';
    }
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Уведомления'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Настройки уведомлений скоро ✨')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Приватность'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Настройки приватности скоро ✨')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareProgress(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция поделиться скоро будет доступна! 🔥'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showStatsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Подробная статистика',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Детальная аналитика скоро будет доступна!'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Экспорт данных скоро будет доступен! 📊'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning,
                color: Colors.orangeAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Сбросить все данные?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Это действие нельзя отменить.',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Функция сброса скоро! 🔄')),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Сбросить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fitness_center,
                color: Colors.purpleAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Trainer App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Версия 1.0.0',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ваш персональный фитнес помощник с ИИ',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}