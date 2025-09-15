import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/modern_components.dart';
import '../../state/user_state.dart';
import '../../models/user_model.dart';
import '../body_scan_screen.dart';
import '../edit_profile_data_screen.dart';
import '../settings_screen.dart';
import '../about_screen.dart';
import '../progress_gallery_screen.dart';
import '../../l10n/app_localizations.dart';

/// Современный экран профиля в стиле Today's workout
class ModernProfileTab extends ConsumerStatefulWidget {
  const ModernProfileTab({super.key});

  @override
  ConsumerState<ModernProfileTab> createState() => _ModernProfileTabState();
}

class _ModernProfileTabState extends ConsumerState<ModernProfileTab> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    ImageProvider avatarProvider() {
      if (user?.avatarPath != null && user!.avatarPath!.isNotEmpty) {
        final f = File(user.avatarPath!);
        if (f.existsSync()) return FileImage(f);
      }
      return const AssetImage('assets/images/champ_avatar.jpg');
    }

    final name = (user?.name?.isNotEmpty == true) ? user!.name! : AppLocalizations.of(context)!.user;
    
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // Сексуальный AppBar с аватаром
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const SizedBox.shrink(),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Аватарка пропорционального размера
                          Center(
                            child: GestureDetector(
                              onTap: () => _showAvatarOptions(context, ref),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.85,
                                height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF007AFF),
                                    const Color(0xFF5B21B6),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image(
                                      image: avatarProvider(),
                                      width: MediaQuery.of(context).size.width * 0.85,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Имя на аватарке
                                  Positioned(
                                    left: 16,
                                    bottom: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ),
                          const SizedBox(height: 8),
                          ModernComponents.sexyText(
                            AppLocalizations.of(context)!.fitnessEnthusiast,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Контент
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Статистика
                  ModernComponents.sexyCard(
                    child: Column(
                      children: [
                        ModernComponents.sexyText(
                          AppLocalizations.of(context)!.progressOverview,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                AppLocalizations.of(context)!.workouts,
                                '12',
                                Icons.fitness_center,
                                const Color(0xFF00D4AA),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                AppLocalizations.of(context)!.calories,
                                '2.4k',
                                Icons.local_fire_department,
                                const Color(0xFFFF6B6B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                AppLocalizations.of(context)!.days,
                                '7',
                                Icons.calendar_today,
                                const Color(0xFF007AFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Физические параметры
                  ModernComponents.sexyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ModernComponents.sexyText(
                          AppLocalizations.of(context)!.physicalParameters,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildParameterRow(AppLocalizations.of(context)!.height, '${user?.height ?? 0} cm', Icons.height),
                        const SizedBox(height: 12),
                        _buildParameterRow(AppLocalizations.of(context)!.weight, '${user?.weight ?? 0} kg', Icons.monitor_weight),
                        const SizedBox(height: 12),
                        _buildParameterRow(AppLocalizations.of(context)!.age, '${user?.age ?? 0} years', Icons.cake),
                        const SizedBox(height: 12),
                        _buildParameterRow(AppLocalizations.of(context)!.goal, _getGoalText(user?.goal), Icons.flag),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Прогресс
                  ModernComponents.sexyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ModernComponents.sexyText(
                          'Weekly Progress',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressItem('Workouts', 0.8, const Color(0xFF00D4AA)),
                        const SizedBox(height: 12),
                        _buildProgressItem('Nutrition', 0.6, const Color(0xFF007AFF)),
                        const SizedBox(height: 12),
                        _buildProgressItem('Sleep', 0.9, const Color(0xFF5B21B6)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Достижения
                  ModernComponents.sexyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ModernComponents.sexyText(
                          AppLocalizations.of(context)!.achievements,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAchievementItem(
                          'First Workout',
                          'Completed your first workout!',
                          Icons.star,
                          const Color(0xFFFFD700),
                        ),
                        const SizedBox(height: 12),
                        _buildAchievementItem(
                          AppLocalizations.of(context)!.weekWarrior,
                          AppLocalizations.of(context)!.workedOutFor7Days,
                          Icons.emoji_events,
                          const Color(0xFF00D4AA),
                        ),
                        const SizedBox(height: 12),
                        _buildAchievementItem(
                          AppLocalizations.of(context)!.nutritionMaster,
                          AppLocalizations.of(context)!.trackedMealsFor30Days,
                          Icons.restaurant,
                          const Color(0xFF007AFF),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Кнопки действий
                  _buildActionButton(
                    AppLocalizations.of(context)!.editProfile,
                    Icons.edit,
                    const Color(0xFF007AFF),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileDataScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionButton(
                    AppLocalizations.of(context)!.gallery,
                    Icons.photo_library,
                    const Color(0xFF00D4AA),
                    () {
                      // Открываем галерею прогресса
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressGalleryScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionButton(
                    AppLocalizations.of(context)!.settings,
                    Icons.settings,
                    const Color(0xFF5B21B6),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionButton(
                    AppLocalizations.of(context)!.about,
                    Icons.info,
                    const Color(0xFFFF6B6B),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 100, // Фиксированная высота для всех блоков
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF007AFF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF007AFF),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ModernComponents.sexyProgress(
          value: progress,
          valueColor: color,
          height: 6,
        ),
      ],
    );
  }

  Widget _buildAchievementItem(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Change Avatar',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ModernComponents.sexyButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, ref);
                    },
                    child: const Text('Take Photo'),
                  ),
                  const SizedBox(height: 12),
                  ModernComponents.sexyButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, ref);
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: const Text('Choose from Gallery'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalText(String? goal) {
    switch (goal) {
      case 'fat_loss':
        return AppLocalizations.of(context)!.weightLoss;
      case 'muscle_gain':
        return AppLocalizations.of(context)!.muscleGain;
      case 'strength':
        return AppLocalizations.of(context)!.strength;
      case 'endurance':
        return AppLocalizations.of(context)!.endurance;
      case 'general_fitness':
        return AppLocalizations.of(context)!.generalFitness;
      default:
        return AppLocalizations.of(context)!.notSpecified;
    }
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        await ref.read(userProvider.notifier).setAvatarPath(image.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Avatar updated successfully!'),
              backgroundColor: const Color(0xFF00D4AA),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating avatar: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}