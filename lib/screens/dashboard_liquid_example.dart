// =============================================================================
// dashboard_liquid_example.dart — Liquid Glass Dashboard Demo
// =============================================================================
// Example dashboard showcasing the "Liquid Glass" design system:
// - Animated mesh gradient background
// - Glass cards with blur and glow
// - Blue/Cyan gradient progress indicators
// - Floating glass navigation bar
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/liquid_theme.dart';
import '../widgets/liquid_glass_components.dart';

class DashboardLiquidExample extends StatefulWidget {
  const DashboardLiquidExample({super.key});

  @override
  State<DashboardLiquidExample> createState() => _DashboardLiquidExampleState();
}

class _DashboardLiquidExampleState extends State<DashboardLiquidExample> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLiquidBlack,
      extendBody: true,
      body: Stack(
        children: [
          // Animated mesh background
          const LiquidMeshBackground(
            showOrbs: true,
            intensity: 0.6,
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Large title header
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // Stats grid
                SliverPadding(
                  padding: EdgeInsets.all(kLiquidSpaceMD),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildStatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '2,450',
                        label: 'Calories Burned',
                        color: kNeonCyan,
                        progress: 0.75,
                      ),
                      _buildStatCard(
                        icon: Icons.directions_run_rounded,
                        value: '8.5 km',
                        label: 'Distance',
                        color: kElectricBlue,
                        progress: 0.6,
                      ),
                      _buildStatCard(
                        icon: Icons.fitness_center_rounded,
                        value: '12',
                        label: 'Workouts',
                        color: kDeepViolet,
                        progress: 0.85,
                      ),
                      _buildStatCard(
                        icon: Icons.favorite_rounded,
                        value: '72 bpm',
                        label: 'Avg Heart Rate',
                        color: kNeonSuccess,
                        progress: 0.45,
                      ),
                    ]),
                  ),
                ),

                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      kLiquidSpaceMD,
                      kLiquidSpaceSM,
                      kLiquidSpaceMD,
                      kLiquidSpaceSM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: kLiquidTitleSmall,
                        ),
                        GestureDetector(
                          onTap: () => HapticFeedback.selectionClick(),
                          child: Text(
                            'See All',
                            style: kLiquidBodyMedium.copyWith(
                              color: kNeonCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Progress card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: kLiquidSpaceMD),
                    child: _buildProgressCard(),
                  ),
                ),

                // Activity list
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(kLiquidSpaceMD),
                    child: _buildRecentActivitySection(),
                  ),
                ),

                // Bottom padding for nav bar
                SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),

          // Floating glass nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidGlassNavBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
              },
              items: const [
                LiquidNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                LiquidNavItem(
                  icon: Icons.fitness_center_outlined,
                  activeIcon: Icons.fitness_center_rounded,
                  label: 'Workout',
                ),
                LiquidNavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Stats',
                ),
                LiquidNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
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
      padding: EdgeInsets.all(kLiquidSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with avatar and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User greeting
              Row(
                children: [
                  // Glass avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kLiquidPrimaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: kNeonCyan.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: kLiquidSpaceSM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: kLiquidCaption.copyWith(
                          color: kLiquidTextTertiary,
                        ),
                      ),
                      const LiquidGradientText(
                        'Alex',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Notification button
              LiquidIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () => HapticFeedback.selectionClick(),
                showGlow: true,
                color: kNeonCyan,
              ),
            ],
          ),
          SizedBox(height: kLiquidSpaceLG),
          // Large title
          Text(
            'Dashboard',
            style: kLiquidTitleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double progress,
  }) {
    return LiquidGlassContainer(
      padding: EdgeInsets.all(kLiquidSpaceMD),
      borderRadius: BorderRadius.circular(kLiquidRadiusLG),
      showGlow: true,
      glowColor: color,
      onTap: () => HapticFeedback.selectionClick(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(kLiquidRadiusSM),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          // Value with glow effect
          LiquidGlowText(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
            glowColor: color,
            glowRadius: 8,
          ),
          SizedBox(height: kLiquidSpaceXS),
          Text(
            label,
            style: kLiquidCaption.copyWith(
              color: kLiquidTextSecondary,
            ),
          ),
          SizedBox(height: kLiquidSpaceSM),
          // Mini progress bar
          LiquidProgressBar(
            value: progress,
            height: 4,
            gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return LiquidGlassContainer(
      padding: EdgeInsets.all(kLiquidSpaceLG),
      borderRadius: BorderRadius.circular(kLiquidRadiusXL),
      child: Row(
        children: [
          // Circular progress
          LiquidCircularProgress(
            value: 0.72,
            size: 100,
            strokeWidth: 10,
            showGlow: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LiquidGradientText(
                  '72%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Complete',
                  style: kLiquidCaption.copyWith(
                    color: kLiquidTextTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: kLiquidSpaceLG),
          // Progress details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Goal',
                  style: kLiquidHeadline,
                ),
                SizedBox(height: kLiquidSpaceXS),
                Text(
                  'You\'re doing great! Keep it up to reach your fitness target.',
                  style: kLiquidBodySmall.copyWith(
                    color: kLiquidTextSecondary,
                  ),
                ),
                SizedBox(height: kLiquidSpaceMD),
                LiquidGlassButton(
                  onPressed: () => HapticFeedback.mediumImpact(),
                  variant: LiquidButtonVariant.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: kLiquidSpaceMD,
                    vertical: kLiquidSpaceSM,
                  ),
                  borderRadius: BorderRadius.circular(kLiquidRadiusSM),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: kLiquidCaption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: kLiquidSpaceXS),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
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

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: kLiquidTitleSmall,
        ),
        SizedBox(height: kLiquidSpaceMD),
        _buildActivityItem(
          icon: Icons.directions_run_rounded,
          title: 'Morning Run',
          subtitle: '5.2 km • 32 min',
          time: '8:30 AM',
          color: kElectricBlue,
        ),
        SizedBox(height: kLiquidSpaceSM),
        _buildActivityItem(
          icon: Icons.fitness_center_rounded,
          title: 'Strength Training',
          subtitle: '45 min • 320 cal',
          time: '10:00 AM',
          color: kDeepViolet,
        ),
        SizedBox(height: kLiquidSpaceSM),
        _buildActivityItem(
          icon: Icons.self_improvement_rounded,
          title: 'Yoga Session',
          subtitle: '30 min • Relaxation',
          time: '6:00 PM',
          color: kNeonCyan,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return LiquidGlassContainer(
      padding: EdgeInsets.all(kLiquidSpaceMD),
      borderRadius: BorderRadius.circular(kLiquidRadiusMD),
      opacity: kGlassOpacityLight,
      onTap: () => HapticFeedback.selectionClick(),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(kLiquidRadiusSM),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: kLiquidSpaceMD),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kLiquidHeadline),
                SizedBox(height: kLiquidSpaceXXS),
                Text(
                  subtitle,
                  style: kLiquidCaption.copyWith(
                    color: kLiquidTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Time
          Text(
            time,
            style: kLiquidCaption.copyWith(
              color: kLiquidTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
