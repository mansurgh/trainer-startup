import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tabs/nutrition_screen_v2.dart';
import 'profile_screen.dart';
import 'workout_schedule/workout_schedule_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/navigation/navigation.dart';
import '../theme/noir_theme.dart';

/// Modern Elite Fitness App (3 tabs) — Noir Glass Design System
/// 
/// Uses NoirGlassTabScaffold for consistent floating navigation
/// across all screens with strict monochrome aesthetics.
class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Tab content pages (order must match NavTab enum)
  static const List<Widget> _pages = [
    WorkoutScheduleScreen(),        // NavTab.workout (index 0)
    NutritionScreenV2(),            // NavTab.nutrition (index 1)
    ProfileScreen(),                // NavTab.profile (index 2)
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab if provided
    if (widget.initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationProvider.notifier).switchToIndex(widget.initialIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const NoirGlassTabScaffold(
      tabs: _pages,
      animationDuration: kDurationMedium,
    );
  }
}
