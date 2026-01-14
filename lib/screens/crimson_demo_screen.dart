// =============================================================================
// crimson_demo_screen.dart — Crimson Liquid Glass Demo
// =============================================================================
// Showcase of the "Crimson Pulse" aesthetic with workout summary cards
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/crimson_theme.dart';
import '../widgets/pulse_glass_components.dart';

class CrimsonDemoScreen extends StatefulWidget {
  const CrimsonDemoScreen({super.key});

  @override
  State<CrimsonDemoScreen> createState() => _CrimsonDemoScreenState();
}

class _CrimsonDemoScreenState extends State<CrimsonDemoScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLiquidBlack,
      body: Stack(
        children: [
          // Animated mesh background
          const PulseMeshBackground(
            animated: true,
            showMesh: true,
          ),
          
          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                
                // Live Workout Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(kSpaceMD),
                    child: WorkoutSummaryCard(
                      calories: 347,
                      duration: const Duration(minutes: 23, seconds: 45),
                      heartRate: 156,
                      workoutName: 'HIIT Training',
                      isLive: true,
                    ),
                  ),
                ),
                
                // Stats Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: kSpaceMD),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    delegate: SliverChildListDelegate([
                      PulseStatCard(
                        value: '12',
                        label: 'Workouts',
                        icon: Icons.fitness_center,
                        unit: 'this week',
                        isActive: true,
                      ),
                      PulseStatCard(
                        value: '4.2k',
                        label: 'Calories',
                        icon: Icons.local_fire_department,
                        unit: 'burned',
                      ),
                      PulseStatCard(
                        value: '89',
                        label: 'Avg Heart Rate',
                        icon: Icons.favorite,
                        unit: 'bpm',
                      ),
                      PulseStatCard(
                        value: '7.5',
                        label: 'Hours',
                        icon: Icons.timer,
                        unit: 'trained',
                      ),
                    ]),
                  ),
                ),
                
                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(kSpaceMD),
                    child: Text(
                      'QUICK ACTIONS',
                      style: kOverline.copyWith(
                        color: kTextTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                
                // Action buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: kSpaceMD),
                    child: Column(
                      children: [
                        RubyGlassButton(
                          onPressed: () {},
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 24),
                              SizedBox(width: kSpaceSM),
                              Text('START WORKOUT', style: kButtonText),
                            ],
                          ),
                        ),
                        SizedBox(height: kSpaceMD),
                        _buildSecondaryButton(
                          icon: Icons.calendar_today,
                          label: 'Schedule Training',
                          onTap: () {},
                        ),
                        SizedBox(height: kSpaceSM),
                        _buildSecondaryButton(
                          icon: Icons.analytics,
                          label: 'View Progress',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Progress Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(kSpaceMD),
                    child: _buildProgressSection(),
                  ),
                ),
                
                // Bottom spacing for nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
          
          // Floating Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PulseGlassNavBar(
              currentIndex: _currentNavIndex,
              onTap: (index) => setState(() => _currentNavIndex = index),
              items: const [
                PulseNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                PulseNavItem(
                  icon: Icons.fitness_center_outlined,
                  activeIcon: Icons.fitness_center,
                  label: 'Train',
                ),
                PulseNavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Stats',
                ),
                PulseNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(kSpaceMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GOOD MORNING',
                style: kOverline.copyWith(
                  color: kNeonScarlet,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: kSpaceXS),
              Text(
                'Ready to burn?',
                style: kTitleLarge,
              ),
            ],
          ),
          // Profile avatar with crimson ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: kCrimsonPrimaryGradient,
              boxShadow: kCrimsonGlow(opacity: 0.3),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kObsidianSurface,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://i.pravatar.cc/150?img=3',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PulseGlassCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceMD,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(kSpaceSM),
            decoration: BoxDecoration(
              color: kNeonScarlet.withOpacity(0.15),
              borderRadius: BorderRadius.circular(kRadiusSM),
            ),
            child: Icon(icon, color: kNeonScarlet, size: 20),
          ),
          SizedBox(width: kSpaceMD),
          Expanded(
            child: Text(label, style: kBodyLarge),
          ),
          Icon(
            Icons.chevron_right,
            color: kTextTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return PulseGlassCard(
      padding: EdgeInsets.all(kSpaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY GOAL',
            style: kOverline.copyWith(color: kTextTertiary),
          ),
          SizedBox(height: kSpaceMD),
          Row(
            children: [
              // Circular progress
              PulseCircularIndicator(
                progress: 0.72,
                size: 100,
                strokeWidth: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          kCrimsonPrimaryGradient.createShader(bounds),
                      child: Text(
                        '72',
                        style: kDisplayMedium.copyWith(
                          color: kTextPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '%',
                      style: kCaption.copyWith(color: kTextTertiary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: kSpaceLG),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalRow(
                      label: 'Workouts',
                      current: 5,
                      target: 7,
                      color: kNeonScarlet,
                    ),
                    SizedBox(height: kSpaceMD),
                    _buildGoalRow(
                      label: 'Calories',
                      current: 2800,
                      target: 3500,
                      color: kEmberOrange,
                    ),
                    SizedBox(height: kSpaceMD),
                    _buildGoalRow(
                      label: 'Active Time',
                      current: 4,
                      target: 5,
                      color: kNeonSuccess,
                      unit: 'hrs',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow({
    required String label,
    required int current,
    required int target,
    required Color color,
    String? unit,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: kCaption.copyWith(color: kTextSecondary),
            ),
            Text(
              '$current${unit != null ? ' $unit' : ''} / $target',
              style: kCaption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: kSpaceXS),
        PulseProgressBar(
          progress: progress,
          height: 4,
          showGlow: false,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
          ),
        ),
      ],
    );
  }
}
