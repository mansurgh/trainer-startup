import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design_tokens.dart';
import '../../core/premium_components.dart';
import '../../core/theme.dart';
import '../../state/user_state.dart';
import '../../models/user_model.dart';
import '../body_scan_screen.dart';
import '../edit_profile_data_screen.dart';
import '../settings_screen.dart';

/// Premium Profile Screen с Activity Heatmap и achievements
class PremiumProfileTab extends ConsumerStatefulWidget {
  const PremiumProfileTab({super.key});

  @override
  ConsumerState<PremiumProfileTab> createState() => _PremiumProfileTabState();
}

class _PremiumProfileTabState extends ConsumerState<PremiumProfileTab> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Простой заголовок для профиля
              Row(
                children: [
                  Text(
                    'Профиль',
                    style: DesignTokens.h1.copyWith(
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showSettingsModal(context),
                    icon: Icon(
                      Icons.settings_rounded,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space24),
              // Единый обзор без верхних вкладок
              _buildOverviewContent(),
            ]),
          ),
        ),
      ],
    );
  }

  // Убрали фильтры согласно требованиям

  Widget _buildOverviewContent() {
    final user = ref.watch(userProvider);
    
    return Column(
      children: [
        // Профиль пользователя
        _buildUserProfile(user),
        const SizedBox(height: DesignTokens.space24),
        
  // KPI карточки
  _buildKPIGrid(user),
  const SizedBox(height: DesignTokens.space24),
        
  // График успеха
  _buildSuccessChart(),
  const SizedBox(height: DesignTokens.space24),
        
  // Активность
  _buildActivityHeatmap(),
  const SizedBox(height: DesignTokens.space24),
        
  // Достижения
  _buildAchievements(),
      ],
    );
  }

  Widget _buildWorkoutsContent() {
    final user = ref.watch(userProvider);
    
    return Column(
      children: [
        // Muscle Map
        PremiumComponents.muscleMap(
          activeMuscleGroups: {'Грудь', 'Плечи', 'Руки'},
          onToggleView: () {
            // Переключение вида
          },
        ),
        const SizedBox(height: DesignTokens.space24),
        
        // Статистика тренировок
        _buildWorkoutStats(user),
        const SizedBox(height: DesignTokens.space24),
        
        // Недавние тренировки
        _buildRecentWorkouts(),
      ],
    );
  }

  Widget _buildNutritionContent() {
    return Column(
      children: [
        // Калории за сегодня
        _buildTodayCalories(),
        const SizedBox(height: DesignTokens.space24),
        
        // БЖУ распределение
        _buildMacroBreakdown(),
        const SizedBox(height: DesignTokens.space24),
        
        // История питания
        _buildNutritionHistory(),
      ],
    );
  }

  Widget _buildProgressContent() {
    final user = ref.watch(userProvider);
    
    return Column(
      children: [
        // Фото прогресса
        _buildProgressPhotos(user),
        const SizedBox(height: DesignTokens.space24),
        
        // Метрики тела
        _buildBodyMetrics(user),
        const SizedBox(height: DesignTokens.space24),
        
        // График веса
        _buildWeightChart(),
      ],
    );
  }

  Widget _buildPremiumAppBar(BuildContext context, UserModel? user, WidgetRef ref) {
    ImageProvider avatarProvider() {
      if (user?.avatarPath != null && user!.avatarPath!.isNotEmpty) {
        final f = File(user.avatarPath!);
        if (f.existsSync()) return FileImage(f);
      }
      return const AssetImage('assets/placeholder/profile.jpg');
    }

    final name = (user?.name?.isNotEmpty == true) ? user!.name! : 'Тренер';
    final streak = _calculateStreak(user);

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: PremiumComponents.glassButton(
            onPressed: () => _changeAvatar(context, ref),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: DesignTokens.iconMedium,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: PremiumComponents.glassButton(
            onPressed: () => _showSettingsModal(context),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: DesignTokens.iconMedium,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16, 
            vertical: DesignTokens.space8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: DesignTokens.h1.copyWith(
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.space4),
              if (streak > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: DesignTokens.warning,
                      size: DesignTokens.iconSmall,
                    ),
                    const SizedBox(width: DesignTokens.space4),
                    Text(
                      '$streak дней подряд',
                      style: DesignTokens.caption.copyWith(
                        color: DesignTokens.warning,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          const Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: avatarProvider(),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(UserModel? user) {
    return PremiumComponents.glassCard(
      child: Column(
        children: [
          Row(
            children: [
              // Аватар пользователя (квадратный и больше)
              GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: DesignTokens.primaryAccent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: user?.avatarPath != null
                        ? Image.file(
                            File(user!.avatarPath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: DesignTokens.primaryAccent.withOpacity(0.1),
                            child: Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: DesignTokens.primaryAccent,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Информация о пользователе
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Пользователь',
                      style: DesignTokens.h2.copyWith(
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user?.age != null || user?.height != null) ...[
                      Text(
                        [
                          if (user?.age != null) '${user!.age} лет',
                          if (user?.height != null) '${user!.height} см',
                        ].join(' • '),
                        style: DesignTokens.bodyMedium.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Уровень активности
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getActivityLevel(user),
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Кнопка редактирования
              IconButton(
                onPressed: () => _editProfile(),
                icon: Icon(
                  Icons.edit_rounded,
                  color: DesignTokens.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Прогресс к цели
          if (user?.targetWeight != null) ...[
            Row(
              children: [
                Icon(Icons.flag_rounded, 
                  color: DesignTokens.primaryAccent, 
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Цель: ${user!.targetWeight} кг',
                  style: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _getProgressToGoal(user),
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _getProgressValue(user),
              backgroundColor: DesignTokens.surface.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(DesignTokens.primaryAccent),
              minHeight: 6,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKPIGrid(UserModel? user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: DesignTokens.space12,
      crossAxisSpacing: DesignTokens.space12,
      childAspectRatio: 1.2,
      children: [
        PremiumComponents.kpiCard(
          title: 'Вес',
          value: user?.weight != null ? '${user!.weight} кг' : '—',
          icon: Icons.monitor_weight,
          accentColor: DesignTokens.primaryAccent,
          trend: '+0.5 кг',
          onTap: () => _showWeightDialog(),
        ),
        PremiumComponents.kpiCard(
          title: 'ИМТ',
          value: _calculateBMI(user),
          icon: Icons.analytics,
          accentColor: DesignTokens.success,
          subtitle: _getBMICategory(user),
        ),
        PremiumComponents.kpiCard(
          title: 'Тренировки',
          value: '12',
          icon: Icons.fitness_center,
          accentColor: DesignTokens.secondaryAccent,
          trend: '+3',
          subtitle: 'в этом месяце',
        ),
        // Вместо 4-го KPI — процент прогресса как в питании + инфо-иконка
        PremiumComponents.glassCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignTokens.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('1%', style: DesignTokens.caption.copyWith(color: DesignTokens.success, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Сегодня вы продвинулись на 1% к цели', style: DesignTokens.bodySmall),
              ),
              IconButton(
                onPressed: _showProgressInfo,
                icon: const Icon(Icons.info_outline_rounded, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessChart() {
    // Заглушка графика успеха
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('График успеха', style: DesignTokens.h3),
          const SizedBox(height: 12),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Здесь будет график прогресса', style: DesignTokens.caption)),
          ),
        ],
      ),
    );
  }

  void _showProgressInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DesignTokens.cardSurface,
        title: Text('Как считается %', style: DesignTokens.h3),
        content: Text(
          'Процент рассчитывается как доля пройденного пути к целевому весу относительно начального.',
          style: DesignTokens.bodySmall,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Понятно')),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap() {
    // Генерируем случайные данные активности
    final activities = <DateTime, int>{};
    final now = DateTime.now();
    
    for (int i = 0; i < 84; i++) {
      final date = now.subtract(Duration(days: i));
      final activity = (i % 7 == 0 || i % 7 == 6) ? 0 : (1 + (i % 4)); // Выходные = 0
      activities[DateTime(date.year, date.month, date.day)] = activity;
    }

    return PremiumComponents.activityHeatmap(
      activities: activities,
      maxLevel: 4,
    );
  }

  Widget _buildAchievements() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Достижения', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAchievementBadge(
                Icons.fitness_center,
                'Силач',
                '10 тренировок',
                DesignTokens.success,
                true,
              ),
              _buildAchievementBadge(
                Icons.local_fire_department,
                'Упорный',
                '7 дней подряд',
                DesignTokens.warning,
                true,
              ),
              _buildAchievementBadge(
                Icons.trending_up,
                'Прогресс',
                '+5кг в жиме',
                DesignTokens.primaryAccent,
                false,
              ),
              _buildAchievementBadge(
                Icons.star,
                'Мастер',
                '30 дней',
                DesignTokens.secondaryAccent,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool achieved,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: achieved 
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                )
              : null,
            color: achieved ? null : DesignTokens.glassOverlay,
            border: Border.all(
              color: achieved ? color : DesignTokens.glassBorder,
              width: 2,
            ),
            boxShadow: achieved ? DesignTokens.glowShadow(color) : null,
          ),
          child: Icon(
            icon,
            color: achieved ? Colors.white : DesignTokens.textTertiary,
            size: DesignTokens.iconLarge,
          ),
        ).animate(
          target: achieved ? 1 : 0,
        ).scale(
          duration: DesignTokens.durationMedium,
          curve: DesignTokens.easeOutQuart,
        ),
        const SizedBox(height: DesignTokens.space8),
        Text(
          title,
          style: DesignTokens.caption.copyWith(
            color: achieved ? DesignTokens.textPrimary : DesignTokens.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: DesignTokens.overline.copyWith(
            color: DesignTokens.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Быстрые действия', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: DesignTokens.space12,
            crossAxisSpacing: DesignTokens.space12,
            childAspectRatio: 2.5,
            children: [
              _buildActionButton(
                Icons.fitness_center,
                'Тренировка',
                DesignTokens.primaryAccent,
                () => _startWorkout(),
              ),
              _buildActionButton(
                Icons.restaurant,
                'Питание',
                DesignTokens.success,
                () => _logFood(),
              ),
              _buildActionButton(
                Icons.photo_camera,
                'Фото прогресса',
                DesignTokens.secondaryAccent,
                () => _takeProgressPhoto(),
              ),
              _buildActionButton(
                Icons.analytics,
                'Статистика',
                DesignTokens.warning,
                () => _showStats(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return PremiumComponents.glassButton(
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: DesignTokens.iconMedium),
          const SizedBox(width: DesignTokens.space8),
          Expanded(
            child: Text(
              label,
              style: DesignTokens.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Заглушки для остальных разделов
  Widget _buildWorkoutStats(UserModel? user) {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Статистика тренировок', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Последние тренировки', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTodayCalories() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Калории сегодня', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('БЖУ', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildNutritionHistory() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('История питания', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildProgressPhotos(UserModel? user) {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Фото прогресса', style: DesignTokens.h3),
              PremiumComponents.glassButton(
                onPressed: () => _takeProgressPhoto(),
                child: const Icon(Icons.add, size: DesignTokens.iconMedium),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBodyMetrics(UserModel? user) {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Метрики тела', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('График веса', style: DesignTokens.h3),
          const SizedBox(height: DesignTokens.space16),
          Text('Раздел в разработке...', style: DesignTokens.bodyMedium),
        ],
      ),
    );
  }

  // Helper methods
  String _calculateBMI(UserModel? user) {
    if (user?.height == null || user?.weight == null) return '—';
    final heightM = user!.height! / 100.0;
    final bmi = user.weight! / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  String _getBMICategory(UserModel? user) {
    final bmiString = _calculateBMI(user);
    if (bmiString == '—') return 'Данные не указаны';
    
    final bmi = double.parse(bmiString);
    if (bmi < 18.5) return 'Недостаток веса';
    if (bmi < 25) return 'Нормальный вес';
    if (bmi < 30) return 'Избыточный вес';
    return 'Ожирение';
  }

  int _calculateStreak(UserModel? user) {
    // Заглушка для streak
    return 7;
  }

  // Action methods
  void _showSettingsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Аватар обновлен! 📸'),
              backgroundColor: DesignTokens.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при обновлении аватара: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  void _pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 400,
        maxHeight: 400,
      );
      
      if (image != null) {
        ref.read(userProvider.notifier).updateAvatar(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Аватар обновлён'),
            backgroundColor: DesignTokens.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обновлении аватара: $e'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileDataScreen()),
    );
  }

  String _getActivityLevel(UserModel? user) {
    // Можно расширить логику на основе данных пользователя
    if (user?.activityLevel != null) {
      switch (user!.activityLevel!) {
        case 'low':
          return 'Низкая активность';
        case 'medium':
          return 'Средняя активность';
        case 'high':
          return 'Высокая активность';
        default:
          return 'Активность не указана';
      }
    }
    return 'Начинающий';
  }

  String _getProgressToGoal(UserModel? user) {
    if (user?.weight == null || user?.targetWeight == null) {
      return 'Цель не установлена';
    }
    
    final current = user!.weight!;
    final target = user.targetWeight!;
    final diff = (current - target).abs();
    
    if (current == target) {
      return 'Цель достигнута!';
    } else if (current > target) {
      return 'Осталось сбросить ${diff.toStringAsFixed(1)} кг';
    } else {
      return 'Осталось набрать ${diff.toStringAsFixed(1)} кг';
    }
  }

  double _getProgressValue(UserModel? user) {
    if (user?.weight == null || user?.targetWeight == null || user?.initialWeight == null) {
      return 0.0;
    }
    
    final current = user!.weight!;
    final target = user.targetWeight!;
    final initial = user.initialWeight ?? current;
    
    if (initial == target) return 1.0;
    
    final totalProgress = (initial - target).abs();
    final currentProgress = (initial - current).abs();
    
    return (currentProgress / totalProgress).clamp(0.0, 1.0);
  }

  void _showWeightDialog() {
    HapticFeedback.lightImpact();
    // TODO: Implement weight logging dialog
  }

  void _startWorkout() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to workout screen
  }

  void _logFood() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to nutrition screen
  }

  void _takeProgressPhoto() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BodyScanScreen(fromOnboarding: false)),
    );
  }

  void _showStats() {
    HapticFeedback.lightImpact();
    // TODO: Show analytics screen
  }
}