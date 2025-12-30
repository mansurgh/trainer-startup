import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import 'tabs/nutrition_screen_v2.dart';
import 'profile_screen.dart';
import 'workout_schedule/workout_schedule_screen.dart';
import '../core/design_tokens.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Modern Elite Fitness App (3 tabs) — iOS 26 Liquid Glass Style
class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  final pages = const [
    WorkoutScheduleScreen(),        // Workout
    NutritionScreenV2(),            // Nutrition
    ProfileScreen(),                // Profile (Premium Dark Industrial)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Premium Dark Industrial - OLED Black base
        color: kOledBlack,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Content extends behind tab bar
        body: pages[_index]
            .animate()
            .fadeIn(duration: kDurationMedium),
        bottomNavigationBar: _buildIOSTabBar(),
      ),
    );
  }

  /// iOS 26 style tab bar — floating ovoid liquid glass pill
  Widget _buildIOSTabBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 40,
        right: 40,
        bottom: bottomPadding + 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // Pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              // Liquid glass gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIOSTabItem(
                  index: 0,
                  icon: Icons.fitness_center_outlined,
                  activeIcon: Icons.fitness_center_rounded,
                  label: AppLocalizations.of(context)?.workout ?? 'Workout',
                ),
                _buildIOSTabItem(
                  index: 1,
                  icon: Icons.restaurant_outlined,
                  activeIcon: Icons.restaurant_rounded,
                  label: AppLocalizations.of(context)?.nutrition ?? 'Nutrition',
                ),
                _buildIOSTabItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: AppLocalizations.of(context)?.profile ?? 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _index == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _index = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected ? BoxDecoration(
          color: kElectricAmberStart.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 26,
              color: isSelected ? kElectricAmberStart : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? kElectricAmberStart : Colors.white.withOpacity(0.6),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
