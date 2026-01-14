// =============================================================================
// floating_nav_bar.dart — Liquid Glass Floating Navigation Bar
// =============================================================================
// Premium monochrome glassmorphism navigation bar with:
// - Oval/stadium shape floating above bottom edge
// - Heavy BackdropFilter blur (20px)
// - Semi-transparent black background (NOT solid)
// - Low opacity white/grey gradient border
// - Strict monochrome design (NO accent colors)
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/noir_theme.dart';
import '../../l10n/app_localizations.dart';

/// Navigation item configuration
class NavBarItem {
  const NavBarItem({
    required this.tab,
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });

  final NavTab tab;
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
}

/// Liquid Glass Floating Navigation Bar
/// 
/// Features:
/// - Floating oval design suspended above screen edge
/// - Heavy BackdropFilter glassmorphism (blur 20px)
/// - Semi-transparent black background
/// - White luminance-based selection indicators
/// - Strict monochrome palette (no accent colors)
class FloatingNavBar extends ConsumerWidget {
  const FloatingNavBar({
    super.key,
    this.horizontalPadding = 40,
    this.bottomPadding = 20,
    this.height = 72,
    this.blurAmount = 20,
    this.surfaceOpacity = 0.08,
    this.borderOpacity = 0.15,
  });

  /// Horizontal padding from screen edges
  final double horizontalPadding;
  
  /// Bottom padding (added to safe area)
  final double bottomPadding;
  
  /// Height of the navigation bar
  final double height;
  
  /// Blur amount for BackdropFilter
  final double blurAmount;
  
  /// Opacity of the semi-transparent background
  final double surfaceOpacity;
  
  /// Opacity of the border
  final double borderOpacity;

  /// Default navigation items
  static const List<NavBarItem> defaultItems = [
    NavBarItem(
      tab: NavTab.workout,
      icon: Icons.fitness_center_outlined,
      activeIcon: Icons.fitness_center_rounded,
      labelKey: 'workout',
    ),
    NavBarItem(
      tab: NavTab.nutrition,
      icon: Icons.restaurant_outlined,
      activeIcon: Icons.restaurant_rounded,
      labelKey: 'nutrition',
    ),
    NavBarItem(
      tab: NavTab.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      labelKey: 'profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: bottomSafeArea + bottomPadding,
      ),
      child: ClipRRect(
        // Stadium/Pill shape
        borderRadius: BorderRadius.circular(height / 2),
        child: BackdropFilter(
          // Heavy blur for premium glass effect
          filter: ImageFilter.blur(
            sigmaX: blurAmount,
            sigmaY: blurAmount,
          ),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              // Semi-transparent black background (NOT solid)
              color: kNoirBlack.withOpacity(surfaceOpacity),
              // Liquid glass gradient overlay
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
              // Low opacity white border for glass edge
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: 1,
              ),
              // Subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: defaultItems.map((item) {
                return _NavBarItemWidget(
                  item: item,
                  isSelected: navState.currentTab == item.tab,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(navigationProvider.notifier).switchTab(item.tab);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation bar item widget
class _NavBarItemWidget extends StatelessWidget {
  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  String _getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (item.labelKey) {
      case 'workout':
        return l10n?.workout ?? 'Workout';
      case 'nutrition':
        return l10n?.nutrition ?? 'Nutrition';
      case 'profile':
        return l10n?.profile ?? 'Profile';
      default:
        return item.labelKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: kDurationMedium,
        curve: kCurveEaseOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                // White luminance-based selection (monochrome)
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                // Subtle glow for selected state
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 26,
              // Strict monochrome: white for selected, grey for unselected
              color: isSelected
                  ? kContentHigh
                  : kContentMedium.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              _getLabel(context),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                // Strict monochrome text colors
                color: isSelected
                    ? kContentHigh
                    : kContentMedium.withOpacity(0.6),
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
