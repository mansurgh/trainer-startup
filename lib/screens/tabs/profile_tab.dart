import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../core/modern_components.dart';
import '../../core/sexy_components.dart';
import '../../state/user_state.dart';
import '../../models/user_model.dart';
import '../../services/noir_toast_service.dart';
import '../../l10n/app_localizations.dart';
import '../body_scan_screen.dart';
import '../edit_profile_data_screen.dart';
import '../settings_screen.dart';
import '../about_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    ImageProvider avatarProvider() {
      // Показываем пользовательскую аватарку или аватарку по умолчанию
      if (user?.avatarPath != null && user!.avatarPath!.isNotEmpty) {
        final f = File(user.avatarPath!);
        if (f.existsSync()) return FileImage(f);
      }
      return const AssetImage('assets/placeholder/profile.jpg');
    }

    // Правильное отображение имени пользователя
    final name = (user?.name?.isNotEmpty == true) ? user!.name! : 'Пользователь';

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, name, avatarProvider(), ref),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  
                  // User Stats Overview
                  _buildStatsOverview(user, context).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Activity Section
                  _buildActivitySection(context).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Body Composition Chart
                  _buildBodyComposition(context, user).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Physical Parameters
                  _buildPhysicalParams(context, user).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Progress Tracking Section
                  _buildProgressTracking(context, user).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Achievements Section
                  _buildAchievements(context).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  _buildQuickActions(context).animate().fadeIn(duration: 800.ms, delay: 1000.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 20),
                  
                  // Profile Management
                  _buildProfileManagement(context).animate().fadeIn(duration: 800.ms, delay: 1200.ms).slideY(begin: 0.3),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sliver App Bar with parallax effect
  Widget _buildSliverAppBar(BuildContext context, String name, ImageProvider avatarProvider, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _changeAvatar(context, ref),
            icon: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Сменить аватарку',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _showSettingsModal(context),
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Настройки',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
                Shadow(
                  color: Colors.black87,
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
                Shadow(
                  color: Colors.black54,
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
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

  // Stats Overview Cards
  Widget _buildStatsOverview(UserModel? user, BuildContext context) {
    final bmi = _calculateBMI(user);
    final fitnessLevel = _getFitnessLevel(user);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monitor_weight,
                      color: Colors.orangeAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Вес',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user?.weight?.toStringAsFixed(1) ?? '0'} кг',
                      textAlign: TextAlign.center,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showBMIDialog(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ИМТ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bmi,
                      textAlign: TextAlign.center,
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
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      color: Colors.purpleAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Тренировки',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '12',
                      textAlign: TextAlign.center,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timeline,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Прогресс',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '85%',
                      textAlign: TextAlign.center,
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
        ),
      ],
    );
  }

  // Activity Section
  Widget _buildActivitySection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.greenAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Активность',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Activity summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'На этой неделе: 5 тренировок',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                'Стрик: 7 дней',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Activity grid (GitHub style)
          Container(
            height: 120,
            child: Column(
              children: [
                // Days of week labels
                Row(
                  children: [
                    const SizedBox(width: 20), // Space for month labels
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Пн', 'Ср', 'Пт']
                            .map((day) => Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Activity grid
                Expanded(
                  child: Row(
                    children: [
                      // Month labels column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Янв', 'Фев', 'Мар']
                            .map((month) => Text(
                                  month,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(width: 8),
                      
                      // Grid itself
                      Expanded(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 12,
                            crossAxisSpacing: 3,
                            mainAxisSpacing: 3,
                          ),
                          itemCount: 84, // 7 days * 12 weeks
                          itemBuilder: (context, index) {
                            // Simulate activity intensity (0-4)
                            final intensity = _getActivityIntensity(index);
                            return Container(
                              decoration: BoxDecoration(
                                color: _getActivityColor(intensity),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for activity grid
  int _getActivityIntensity(int index) {
    // Simulate activity data - in real app would come from user data
    if (index % 7 == 0 || index % 7 == 1) return 0; // Weekend rest
    if (index % 14 < 5) return (index % 4) + 1; // Weekday activity
    return (index % 3); // Varying activity
  }

  Color _getActivityColor(int intensity) {
    switch (intensity) {
      case 0:
        return const Color(0xFF1a1a1a); // Dark gray for no activity
      case 1:
        return const Color(0xFF0d4429); // Dark green
      case 2:
        return const Color(0xFF006d32); // Medium green
      case 3:
        return const Color(0xFF26a641); // Bright green
      case 4:
        return const Color(0xFF39d353); // Very bright green
      default:
        return const Color(0xFF1a1a1a);
    }
  }

  // Body Composition Circular Progress
  Widget _buildBodyComposition(BuildContext context, UserModel? user) {
    final fatPct = user?.bodyFatPct ?? 20.0;
    final musclePct = user?.musclePct ?? 40.0;
    
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
              Flexible(
                child: _buildCircularProgress(
                  'Жир',
                  fatPct,
                  Colors.orangeAccent,
                  100,
                ),
              ),
              Flexible(
                child: _buildCircularProgress(
                  'Мышцы',
                  musclePct,
                  Colors.greenAccent,
                  100,
                ),
              ),
              Flexible(
                child: _buildCircularProgress(
                  'Вода',
                  (100 - fatPct - (musclePct * 0.4)).clamp(0, 100),
                  Colors.blueAccent,
                  100,
                ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Фоновое кольцо
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 16,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.1)),
                ),
              ),
              // Основное кольцо
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 16,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Physical Parameters Grid
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
                'Параметры',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _navigateToEditProfile(context),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Изменить'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
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
              _buildParamCard('Возраст', user?.age != null ? '${user!.age} лет' : '—', Icons.cake),
              _buildParamCard('Рост', user?.height != null ? '${user!.height} см' : '—', Icons.height),
              _buildParamCard('Вес', user?.weight != null ? '${user!.weight} кг' : '—', Icons.monitor_weight),
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

  // Achievements Section
  Widget _buildAchievements(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: achieved ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // Quick Actions
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
                    MaterialPageRoute(builder: (_) => const BodyScanScreen(fromOnboarding: false)),
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

  // Profile Management
  Widget _buildProfileManagement(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ModernComponents.glassButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileDataScreen()),
              );
            },
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit, size: 20),
                const SizedBox(width: 8),
                const Text('Редактировать профиль'),
              ],
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

  // Helper methods
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

  // Modal and action methods
  void _showSettingsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _shareProgress(BuildContext context) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    NoirToast.info(context, l10n.comingSoon);
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
              ModernComponents.glassButton(
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
    final l10n = AppLocalizations.of(context)!;
    NoirToast.info(context, l10n.comingSoon);
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
                    child: ModernComponents.glassButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ModernComponents.animatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final l10n = AppLocalizations.of(context)!;
                        NoirToast.info(context, l10n.comingSoon);
                      },
                      backgroundColor: Colors.red,
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

  // Progress Tracking Section
  Widget _buildProgressTracking(BuildContext context, UserModel? user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.greenAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Прогресс',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showProgressGallery(context, user),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Галерея'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
          if (user?.photoHistory != null && user!.photoHistory!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(user.photoHistory!.last),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        'Последнее фото: ${_formatDate(user.lastActive ?? DateTime.now())}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${user.photoHistory!.length} фото',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Colors.white38,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Сделайте первое фото для отслеживания прогресса',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ModernComponents.animatedButton(
                      onPressed: () => _navigateToBodyScan(context),
                      backgroundColor: Colors.greenAccent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_rounded, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text('Сделать фото', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Progress Gallery Dialog
  void _showProgressGallery(BuildContext context, UserModel? user) {
    final photoHistory = user?.photoHistory ?? <String>[];
    
    showDialog(
      context: context,
      builder: (context) => _ProgressGalleryDialog(photoHistory: photoHistory),
    );
  }

  // Navigation methods
  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileDataScreen()),
    );
  }

  void _navigateToBodyScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BodyScanScreen(fromOnboarding: false)),
    );
  }

  // BMI Dialog
  void _showBMIDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Индекс массы тела (ИМТ)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ИМТ = вес (кг) / рост² (м)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Интерпретация:\n'
                '• < 18.5 - Недостаточный вес\n'
                '• 18.5-24.9 - Нормальный вес\n'
                '• 25.0-29.9 - Избыточный вес\n'
                '• ≥ 30.0 - Ожирение',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Понятно'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for date formatting
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  // Change avatar method
  Future<void> _changeAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final userNotifier = ref.read(userProvider.notifier);
        await userNotifier.setAvatarPath(image.path);
        
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          NoirToast.success(context, l10n.avatarUpdated);
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        NoirToast.error(context, l10n.error);
      }
    }
  }
}

class _ProgressGalleryDialog extends StatefulWidget {
  final List<String> photoHistory;
  
  const _ProgressGalleryDialog({required this.photoHistory});
  
  @override
  State<_ProgressGalleryDialog> createState() => _ProgressGalleryDialogState();
}

class _ProgressGalleryDialogState extends State<_ProgressGalleryDialog> {
  late PageController _pageController;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.photo_library_rounded, color: Colors.greenAccent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Галерея прогресса',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            if (widget.photoHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            itemCount: widget.photoHistory.length,
                            itemBuilder: (context, index) {
                              final photoPath = widget.photoHistory[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(photoPath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Стрелка влево
                          if (widget.photoHistory.length > 1)
                            Positioned(
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_currentPage > 0) {
                                      _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Icon(
                                      Icons.chevron_left,
                                      color: _currentPage > 0 ? Colors.white : Colors.white38,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Стрелка вправо
                          if (widget.photoHistory.length > 1)
                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_currentPage < widget.photoHistory.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: _currentPage < widget.photoHistory.length - 1 ? Colors.white : Colors.white38,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Индикаторы страниц
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.photoHistory.length,
                        (index) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentPage 
                                  ? Colors.greenAccent 
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Фото ${_currentPage + 1} из ${widget.photoHistory.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (widget.photoHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет фотографий',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Загрузите фото тела для отслеживания прогресса',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}