import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:io';

import '../../core/design_tokens.dart';
import '../../core/premium_widgets.dart';
import '../../models/activity_day.dart';
import '../../state/user_state.dart';
import '../../state/activity_state.dart';
import '../../widgets/activity_tracker.dart';
import '../../widgets/app_alert.dart';
import '../settings_screen.dart';
import '../../l10n/app_localizations.dart';

/// Premium Profile Screen - Redesigned with premium widgets
/// Features: Avatar with glow, Daily Success Meter, Personal Records, Activity Heatmap
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
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    // Settings icon button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        color: DesignTokens.textPrimary,
                        iconSize: 24,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Avatar and user info - Premium style
            SliverToBoxAdapter(
              child: _buildPremiumUserInfo(context, ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            
            // Streak Badge
            SliverToBoxAdapter(
              child: _buildStreakSection(context, ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Daily Success Meter (Новая статистика)
            SliverToBoxAdapter(
              child: _buildDailySuccessSection(context, ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Personal Records (Личные рекорды)
            SliverToBoxAdapter(
              child: _buildPersonalRecords(context, ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Progress graph - Enhanced
            SliverToBoxAdapter(
              child: _buildProgressSection(context, ref),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
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

  Widget _buildPremiumUserInfo(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final avatarPath = user?.avatarPath;
    final l10n = AppLocalizations.of(context)!;
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Premium Avatar with glow effect - увеличен до 100
          GestureDetector(
            onTap: () => _showAvatarDialog(context, ref),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
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
                        size: 50,
                        color: Colors.white.withOpacity(0.7),
                      )
                    : null,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // User info with premium typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? (isRussian ? 'Пользователь' : 'User'),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (user?.age != null && user!.age! > 0) ...[
                      _buildInfoChip('${user.age} ${isRussian ? 'лет' : 'y.o.'}', Icons.cake_outlined),
                      const SizedBox(width: 8),
                    ],
                    if (user?.weight != null && user!.weight! > 0)
                      _buildInfoChip('${user.weight!.toStringAsFixed(0)} ${isRussian ? 'кг' : 'kg'}', Icons.monitor_weight_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.1);
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(consistencyStreakProvider);
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: streakAsync.when(
        data: (streak) => PremiumWidgets.streakBadge(streak: streak, isRussian: isRussian),
        loading: () => PremiumWidgets.streakBadge(streak: 0, isRussian: isRussian),
        error: (_, __) => PremiumWidgets.streakBadge(streak: 0, isRussian: isRussian),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildDailySuccessSection(BuildContext context, WidgetRef ref) {
    final todaysWinAsync = ref.watch(todaysWinProvider);
    final l10n = AppLocalizations.of(context)!;
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    // Расчёт составляющих успеха дня
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: todaysWinAsync.when(
        data: (percent) {
          // Симулируем данные (в реальном приложении брать из провайдеров)
          final willpower = (percent / 100).clamp(0.0, 1.0);
          final intensity = 0.7; // TODO: Получать из тренировки
          final consistency = 0.85; // TODO: Получать из streak данных
          
          return PremiumWidgets.dailySuccessMeter(
            willpower: willpower,
            intensity: intensity,
            consistency: consistency,
            motivationalText: _getMotivationalText(percent, isRussian),
            isRussian: isRussian,
          );
        },
        loading: () => PremiumWidgets.dailySuccessMeter(
          willpower: 0,
          intensity: 0,
          consistency: 0,
          isRussian: isRussian,
        ),
        error: (_, __) => PremiumWidgets.dailySuccessMeter(
          willpower: 0,
          intensity: 0,
          consistency: 0,
          isRussian: isRussian,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1);
  }

  String _getMotivationalText(int percent, bool isRussian) {
    // Сборник мотивационных цитат - разные каждый день
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    
    final quotesRu = [
      'Сегодня новый день — новые возможности!',
      'Каждый шаг приближает тебя к цели.',
      'Дисциплина — это выбор между тем, чего ты хочешь сейчас, и тем, чего ты хочешь больше всего.',
      'Начни с того места, где ты сейчас.',
      'Прогресс, а не совершенство.',
      'Сложности делают тебя сильнее.',
      'Ты сильнее, чем думаешь.',
      'Делай то, что можешь, с тем, что имеешь.',
      'Успех — это сумма маленьких усилий.',
      'Не останавливайся, пока не гордишься собой.',
      'Единственная плохая тренировка — та, что не состоялась.',
      'Верь в себя и в свои силы.',
      'Каждый день — шанс стать лучше.',
      'Твоё тело может всё. Убеди свой разум.',
      'Боль временна, гордость — навсегда.',
    ];
    
    final quotesEn = [
      'Today is a new day — new opportunities!',
      'Every step brings you closer to your goal.',
      'Discipline is choosing between what you want now and what you want most.',
      'Start where you are.',
      'Progress, not perfection.',
      'Challenges make you stronger.',
      'You are stronger than you think.',
      'Do what you can, with what you have.',
      'Success is the sum of small efforts.',
      "Don't stop until you're proud.",
      "The only bad workout is the one that didn't happen.",
      'Believe in yourself and your strength.',
      'Every day is a chance to get better.',
      'Your body can do anything. Convince your mind.',
      'Pain is temporary, pride is forever.',
    ];
    
    final quotes = isRussian ? quotesRu : quotesEn;
    return quotes[dayOfYear % quotes.length];
  }

  Widget _buildPersonalRecords(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 22),
              const SizedBox(width: 8),
              Text(
                isRussian ? 'Личные рекорды' : 'Personal Records',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // TODO: Получать реальные PR из базы данных
          _buildPRCard(
            exercise: isRussian ? 'Жим лёжа' : 'Bench Press',
            value: '80 ${isRussian ? 'кг' : 'kg'}',
            date: isRussian ? '28 ноя' : 'Nov 28',
          ),
          const SizedBox(height: 8),
          _buildPRCard(
            exercise: isRussian ? 'Приседания' : 'Squats',
            value: '100 ${isRussian ? 'кг' : 'kg'}',
            date: isRussian ? '25 ноя' : 'Nov 25',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildPRCard({
    required String exercise,
    required String value,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.12),
            const Color(0xFFFFD700).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PR',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, WidgetRef ref) {
    final workoutCountAsync = ref.watch(workoutCountProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progress,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              workoutCountAsync.when(
                data: (count) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count ${l10n.workoutsCount}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Enhanced Graph
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: workoutCountAsync.when(
                data: (count) => CustomPaint(
                  size: Size.infinite,
                  painter: _EnhancedGraphPainter(
                    workoutCount: count,
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white24),
                  ),
                ),
                error: (_, __) => CustomPaint(
                  size: Size.infinite,
                  painter: _EnhancedGraphPainter(workoutCount: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.1);
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
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.1);
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
}

// Enhanced Graph Painter with gradient and glow
class _EnhancedGraphPainter extends CustomPainter {
  final int workoutCount;

  _EnhancedGraphPainter({required this.workoutCount});

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Progress line
    final progress = (workoutCount / 20).clamp(0.0, 1.0);
    
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00D9FF),
          const Color(0xFF00FF88),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    final startY = size.height * 0.85;
    final endY = size.height * (0.85 - 0.65 * progress);
    
    if (workoutCount == 0) {
      path.moveTo(0, startY);
      path.lineTo(size.width, startY);
    } else {
      final points = [
        Offset(0, startY),
        Offset(size.width * 0.2, startY - (startY - endY) * 0.15),
        Offset(size.width * 0.4, startY - (startY - endY) * 0.35),
        Offset(size.width * 0.6, startY - (startY - endY) * 0.55),
        Offset(size.width * 0.8, startY - (startY - endY) * 0.85),
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
      
      // Glow effect
      final glowPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withOpacity(0.3),
            const Color(0xFF00FF88).withOpacity(0.3),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawPath(path, glowPaint);
    }
    
    canvas.drawPath(path, linePaint);
    
    // End point dot
    if (workoutCount > 0) {
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(size.width, endY), 5, dotPaint);
      
      final dotGlowPaint = Paint()
        ..color = const Color(0xFF00FF88).withOpacity(0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
      canvas.drawCircle(Offset(size.width, endY), 8, dotGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnhancedGraphPainter oldDelegate) {
    return oldDelegate.workoutCount != workoutCount;
  }
}

// Avatar Dialog Helper
void _showAvatarDialog(BuildContext context, WidgetRef ref) {
  final user = ref.read(userProvider);
  final avatarPath = user?.avatarPath;
  
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.9),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large avatar preview with glow
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
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
                      color: Colors.white.withOpacity(0.5),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Change Avatar button - Premium style
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
                    description: 'Your profile picture has been changed',
                    type: AlertType.success,
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFE0E0E0)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Change avatar',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Close button
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
