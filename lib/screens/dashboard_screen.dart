import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../core/design_tokens.dart';
import '../state/user_state.dart';
import 'ai_chat_screen.dart';

/// Trainer#1 Dashboard — Main Screen
/// Features: Daily workout summary, 3D muscle visualization, floating AI button
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with greeting
              SliverToBoxAdapter(
                child: _buildHeader(context, user?.name),
              ),
              
              // Today's workout summary
              SliverToBoxAdapter(
                child: _buildWorkoutSummary(context),
              ),
              
              // 3D Muscle visualization placeholder
              SliverToBoxAdapter(
                child: _buildMuscleVisualization(context),
              ),
              
              // Quick stats
              SliverToBoxAdapter(
                child: _buildQuickStats(context),
              ),
              
              // Recent activity
              SliverToBoxAdapter(
                child: _buildRecentActivity(context),
              ),
              
              // Bottom spacing for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // Floating AI Chat button (bottom right)
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildAIChatButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRAINER',
            style: DesignTokens.h3.copyWith(
              color: DesignTokens.primaryAccent,
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Better than a real one.',
            style: DesignTokens.bodySmall.copyWith(
              color: DesignTokens.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Hello, ',
                style: DesignTokens.h1.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                name ?? 'Athlete',
                style: DesignTokens.h1.copyWith(
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildWorkoutSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: DesignTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'TODAY\'S WORKOUT',
                  style: DesignTokens.h3.copyWith(
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'EXERCISES',
                    value: '4',
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatTile(
                    label: 'DURATION',
                    value: '45m',
                    icon: Icons.timer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Focus: Upper Body',
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _GradientButton(
              label: 'START WORKOUT',
              onTap: () {},
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 600.ms)
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildMuscleVisualization(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: _GlassCard(
        child: Column(
          children: [
            Text(
              'MUSCLE ACTIVATION',
              style: DesignTokens.h3.copyWith(
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            // Placeholder for 3D muscle model
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    DesignTokens.primaryAccent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.accessibility_new,
                  size: 120,
                  color: DesignTokens.primaryAccent.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chest • Shoulders • Triceps',
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 400.ms, duration: 600.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '12',
                    style: DesignTokens.h1.copyWith(
                      color: DesignTokens.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DAY STREAK',
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '87%',
                    style: DesignTokens.h1.copyWith(
                      color: DesignTokens.secondaryAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'VICTORY',
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 600.ms, duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'RECENT ACTIVITY',
              style: DesignTokens.h3.copyWith(
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
          _ActivityItem(
            title: 'Upper Body Workout',
            subtitle: 'Completed • 45 min',
            time: '2h ago',
          ),
          const SizedBox(height: 8),
          _ActivityItem(
            title: 'Nutrition Log',
            subtitle: '2,340 kcal logged',
            time: '5h ago',
          ),
          const SizedBox(height: 8),
          _ActivityItem(
            title: 'Lower Body Workout',
            subtitle: 'Completed • 50 min',
            time: 'Yesterday',
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildAIChatButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatScreen()),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: DesignTokens.primaryGradient,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primaryAccent.withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 32,
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: 2000.ms,
      color: Colors.white.withOpacity(0.3),
    );
  }
}

// === REUSABLE COMPONENTS ===

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _GlassCard({
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DesignTokens.glassBlur,
          sigmaY: DesignTokens.glassBlur,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: DesignTokens.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DesignTokens.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: DesignTokens.primaryAccent,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: DesignTokens.h2,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: DesignTokens.caption.copyWith(
              color: DesignTokens.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: DesignTokens.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primaryAccent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: DesignTokens.buttonText.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: DesignTokens.primaryAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primaryAccent.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignTokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: DesignTokens.caption.copyWith(
              color: DesignTokens.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
