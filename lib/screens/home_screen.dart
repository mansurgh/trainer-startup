import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import 'tabs/nutrition_screen_v2.dart';
import 'tabs/modern_profile_screen.dart';
import 'workout_schedule/workout_schedule_screen.dart';
import '../core/design_tokens.dart';

/// Modern Elite Fitness App (3 tabs)
class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
  }

  final pages = const [
    WorkoutScheduleScreen(),        // Workout
    NutritionScreenV2(),            // Nutrition
    ModernProfileScreen(),          // Profile
  ];

  @override
  Widget build(BuildContext context) {
    // Debug info
    print('[HomeScreen] Building with index: $_index, showing: ${pages[_index].runtimeType}');
    
    return Container(
      decoration: BoxDecoration(
        gradient: DesignTokens.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: pages[_index]
              .animate()
              .fadeIn(duration: DesignTokens.durationMedium)
              .slideX(begin: 0.1, end: 0),
        ),
        bottomNavigationBar: _buildGlassBottomNavigation(),
      ),
    );
  }

  Widget _buildGlassBottomNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: DesignTokens.glassBlur,
            sigmaY: DesignTokens.glassBlur,
          ),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: DesignTokens.primaryAccent.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.fitness_center_rounded, 'Workout'),
                _buildNavItem(1, Icons.restaurant_rounded, 'Nutrition'),
                _buildNavItem(2, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _index = index);
        },
        child: Container(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? DesignTokens.primaryAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: DesignTokens.primaryAccent.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ] : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? Colors.black
                      : DesignTokens.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: DesignTokens.caption.copyWith(
                  color: isSelected 
                      ? DesignTokens.textPrimary
                      : DesignTokens.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
