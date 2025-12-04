import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../core/design_tokens.dart';
import '../../models/activity_day.dart';
import '../../state/user_state.dart';
import '../../state/activity_state.dart';
import '../../widgets/activity_tracker.dart';
import '../../widgets/app_alert.dart';
import '../settings_screen.dart';
import '../../l10n/app_localizations.dart';

/// Modern Profile Screen (based on screenshot 2)
/// Features: Avatar, Today's win, BMI, Weight graph, Activity heatmap
class ModernProfileScreen extends ConsumerWidget {
  const ModernProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Settings button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.profile,
                      style: DesignTokens.h1.copyWith(fontSize: 36),
                    ),
                    // Settings icon button
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      color: DesignTokens.textPrimary,
                      iconSize: 28,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Avatar and user info
            SliverToBoxAdapter(
              child: _buildUserInfo(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Today's win and BMI
            SliverToBoxAdapter(
              child: _buildStatsRow(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Progress graph
            SliverToBoxAdapter(
              child: _buildWeightGraph(ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Activity heatmap
            SliverToBoxAdapter(
              child: _buildActivityHeatmap(ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(userProvider);
        final avatarPath = user?.avatarPath;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Avatar - clickable for fullscreen view
              GestureDetector(
                onTap: () {
                  _showAvatarDialog(context, ref);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DesignTokens.primaryAccent.withOpacity(0.3),
                      width: 2,
                    ),
                    image: avatarPath != null && File(avatarPath).existsSync()
                        ? DecorationImage(
                            image: FileImage(File(avatarPath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarPath == null || !File(avatarPath).existsSync()
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: DesignTokens.textSecondary,
                        )
                      : null,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: DesignTokens.h2.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer(
                          builder: (context, ref, child) {
                            final l10n = AppLocalizations.of(context)!;
                            final age = user?.age ?? 0;
                            final height = user?.height ?? 0;
                            
                            return Text(
                              age > 0 && height > 0
                                  ? '$age ${l10n.years} • $height ${l10n.heightUnit}'
                                  : age > 0
                                      ? '$age ${l10n.years}'
                                      : height > 0
                                          ? '$height ${l10n.heightUnit}'
                                          : l10n.completeYourProfile,
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Consumer(
              builder: (context, ref, child) {
                final l10n = AppLocalizations.of(context)!;
                final todaysWinAsync = ref.watch(todaysWinProvider);
                
                return todaysWinAsync.when(
                  data: (percent) => _StatCard(
                    label: l10n.todaysWin,
                    value: '$percent%',
                    color: DesignTokens.primaryAccent,
                    helpText: 'Успех дня рассчитывается как среднее между завершением тренировки (0% или 100%) и выполнением плана питания (процент съеденных калорий от цели КБЖУ). Формула: (Тренировка + Питание) / 2',
                  ),
                  loading: () => _StatCard(
                    label: l10n.todaysWin,
                    value: '...',
                    color: DesignTokens.primaryAccent,
                    helpText: 'Успех дня рассчитывается как среднее между завершением тренировки (0% или 100%) и выполнением плана питания (процент съеденных калорий от цели КБЖУ). Формула: (Тренировка + Питание) / 2',
                  ),
                  error: (_, __) => _StatCard(
                    label: l10n.todaysWin,
                    value: '0%',
                    color: DesignTokens.primaryAccent,
                    helpText: 'Успех дня рассчитывается как среднее между завершением тренировки (0% или 100%) и выполнением плана питания (процент съеденных калорий от цели КБЖУ). Формула: (Тренировка + Питание) / 2',
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final l10n = AppLocalizations.of(context)!;
                final streakAsync = ref.watch(consistencyStreakProvider);
                
                return streakAsync.when(
                  data: (streak) => _StatCard(
                    label: l10n.streakLabel,
                    value: l10n.streakDays(streak),
                    color: DesignTokens.textPrimary,
                    helpText: l10n.streakHelp,
                  ),
                  loading: () => _StatCard(
                    label: l10n.streakLabel,
                    value: '...',
                    color: DesignTokens.textPrimary,
                    helpText: l10n.streakHelp,
                  ),
                  error: (_, __) => _StatCard(
                    label: l10n.streakLabel,
                    value: l10n.streakDays(0),
                    color: DesignTokens.textPrimary,
                    helpText: l10n.streakHelp,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildWeightGraph(WidgetRef ref) {
    final workoutCountAsync = ref.watch(workoutCountProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    l10n.progress,
                    style: DesignTokens.h3.copyWith(
                      color: DesignTokens.primaryAccent,
                      fontSize: 20,
                    ),
                  );
                },
              ),
              workoutCountAsync.when(
                data: (count) => Consumer(
                  builder: (context, ref, child) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      '$count ${l10n.workoutsCount}',
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    );
                  },
                ),
                loading: () => Consumer(
                  builder: (context, ref, child) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      '... ${l10n.workoutsCount}',
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    );
                  },
                ),
                error: (_, __) => Consumer(
                  builder: (context, ref, child) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      '0 ${l10n.workoutsCount}',
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Graph with wave
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DesignTokens.primaryAccent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: workoutCountAsync.when(
                data: (count) => CustomPaint(
                  size: Size.infinite,
                  painter: _WaveGraphPainter(
                    color: DesignTokens.primaryAccent,
                    workoutCount: count,
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => CustomPaint(
                  size: Size.infinite,
                  painter: _WaveGraphPainter(
                    color: DesignTokens.primaryAccent,
                    workoutCount: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap(WidgetRef ref) {
    final activityAsync = ref.watch(activityDataProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: activityAsync.when(
        data: (activityDays) => ActivityTracker(activityDays: activityDays),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ActivityTracker(activityDays: _getEmptyActivityData()),
      ),
    );
  }

  List<ActivityDay> _getEmptyActivityData() {
    final today = DateTime.now();
    final List<ActivityDay> days = [];
    
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      days.add(ActivityDay(
        date: date,
        workoutCompleted: false,
        nutritionGoalMet: false,
      ));
    }
    
    return days;
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              icon: Icons.folder_outlined,
              label: 'History',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: DesignTokens.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DesignTokens.glassBorder,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: DesignTokens.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === COMPONENTS ===

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? helpText;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignTokens.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ),
              if (helpText != null)
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 18),
                  color: DesignTokens.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: DesignTokens.surface,
                        title: Text(label, style: const TextStyle(color: Colors.white)),
                        content: Text(helpText!, style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: DesignTokens.h1.copyWith(
              fontSize: 40,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Wave Graph Painter
class _WaveGraphPainter extends CustomPainter {
  final Color color;
  final int workoutCount;

  _WaveGraphPainter({required this.color, required this.workoutCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Если нет тренировок - плоская линия внизу
    if (workoutCount == 0) {
      final yPosition = size.height * 0.85;
      path.moveTo(0, yPosition);
      path.lineTo(size.width, yPosition);
    } else {
      // Линия растёт с прогрессом (максимум 20 тренировок = верх графика)
      final progress = (workoutCount / 20).clamp(0.0, 1.0);
      
      // Начальная точка (внизу)
      final startY = size.height * 0.85;
      // Конечная точка (вверху)
      final endY = size.height * (0.85 - 0.65 * progress); // Растёт до 0.2 от верха
      
      // Рисуем плавную линию роста
      final points = [
        Offset(0, startY),
        Offset(size.width * 0.25, startY - (startY - endY) * 0.2),
        Offset(size.width * 0.5, startY - (startY - endY) * 0.5),
        Offset(size.width * 0.75, startY - (startY - endY) * 0.8),
        Offset(size.width, endY),
      ];
      
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 0; i < points.length - 1; i++) {
        final xMid = (points[i].dx + points[i + 1].dx) / 2;
        final yMid = (points[i].dy + points[i + 1].dy) / 2;
        
        path.quadraticBezierTo(
          points[i].dx,
          points[i].dy,
          xMid,
          yMid,
        );
      }
      
      path.lineTo(points.last.dx, points.last.dy);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveGraphPainter oldDelegate) {
    return oldDelegate.workoutCount != workoutCount;
  }
}

// Avatar Dialog Helper
void _showAvatarDialog(BuildContext context, WidgetRef ref) {
  final user = ref.read(userProvider);
  final avatarPath = user?.avatarPath;
  
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large avatar preview
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: DesignTokens.primaryAccent.withOpacity(0.5),
                width: 3,
              ),
              image: avatarPath != null && File(avatarPath).existsSync()
                  ? DecorationImage(
                      image: FileImage(File(avatarPath)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarPath == null || !File(avatarPath).existsSync()
                ? Icon(
                    Icons.person,
                    size: 120,
                    color: DesignTokens.textSecondary,
                  )
                : null,
          ),
          
          const SizedBox(height: 32),
          
          // Change Avatar button
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 85,
              );
              
              if (image != null) {
                await ref.read(userProvider.notifier).updateAvatar(image.path);
                
                if (context.mounted) {
                  AppAlert.show(
                    context,
                    title: 'Avatar updated',
                    description: 'Your profile picture has been changed successfully',
                    type: AlertType.success,
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Change avatar',
                    style: DesignTokens.bodyLarge.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
