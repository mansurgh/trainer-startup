// =============================================================================
// noir_glass_scaffold.dart — Premium Noir Glass Scaffold Wrapper
// =============================================================================
// Unified scaffold wrapper that ensures consistent navigation across all screens:
// - OLED black background with transparent scaffold
// - extendBody: true for content to flow behind navigation
// - FloatingNavBar positioned via Stack for complete control
// - Consistent safe area handling
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/noir_theme.dart';
import '../../providers/navigation_provider.dart';
import 'floating_nav_bar.dart';

/// NoirGlassScaffold — Premium scaffold wrapper with floating navigation
/// 
/// Use this instead of raw Scaffold to ensure:
/// - Consistent OLED black background
/// - Content extends behind floating nav bar
/// - Unified navigation behavior across all tabs
/// 
/// Example:
/// ```dart
/// NoirGlassScaffold(
///   body: YourScreenContent(),
///   showNavBar: true,
/// )
/// ```
class NoirGlassScaffold extends ConsumerWidget {
  const NoirGlassScaffold({
    super.key,
    required this.body,
    this.showNavBar = true,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });

  /// Main content widget
  final Widget body;

  /// Whether to show the floating navigation bar
  final bool showNavBar;

  /// Optional app bar
  final PreferredSizeWidget? appBar;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// Background color (defaults to OLED black)
  final Color? backgroundColor;

  /// Whether to extend body behind app bar
  final bool extendBodyBehindAppBar;

  /// Whether to resize body when keyboard appears
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // OLED Black base for true blacks
      color: backgroundColor ?? kNoirBlack,
      child: Scaffold(
        // Transparent scaffold to show base color
        backgroundColor: Colors.transparent,
        // Allow content to flow behind nav bar
        extendBody: true,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        // Use Stack to position body and nav bar independently
        body: Stack(
          children: [
            // Main content fills entire screen
            Positioned.fill(child: body),
            
            // Floating nav bar at bottom (if enabled)
            if (showNavBar)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingNavBar(),
              ),
          ],
        ),
      ),
    );
  }
}

/// NoirGlassTabScaffold — Tab-based scaffold with animated transitions
/// 
/// Use this for the main app shell that hosts multiple tab screens.
/// Handles tab switching with fade animations.
class NoirGlassTabScaffold extends ConsumerWidget {
  const NoirGlassTabScaffold({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.animationDuration,
  });

  /// List of tab content widgets (must match NavTab order)
  final List<Widget> tabs;

  /// Initial tab index
  final int initialIndex;

  /// Animation duration for tab transitions
  final Duration? animationDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);
    
    // Clamp index to valid range
    final safeIndex = currentIndex.clamp(0, tabs.length - 1);

    return NoirGlassScaffold(
      showNavBar: true,
      body: AnimatedSwitcher(
        duration: animationDuration ?? kDurationMedium,
        switchInCurve: kCurveEaseOut,
        switchOutCurve: kCurveEaseIn,
        child: KeyedSubtree(
          key: ValueKey<int>(safeIndex),
          child: tabs[safeIndex],
        ),
      ),
    );
  }
}

/// Extension for adding bottom padding to scroll views within NoirGlassScaffold
/// to account for the floating navigation bar
extension NoirGlassScrollPadding on Widget {
  /// Adds bottom padding for floating nav bar clearance
  /// Use this at the end of scroll views to prevent content from being hidden
  static EdgeInsets navBarPadding(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    // Nav bar height (72) + bottom padding (20) + safe area + extra clearance
    return EdgeInsets.only(bottom: 72 + 20 + bottomSafeArea + 16);
  }
}

/// Sliver equivalent for adding bottom spacing in CustomScrollView
class SliverNavBarSpacer extends StatelessWidget {
  const SliverNavBarSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return SliverToBoxAdapter(
      child: SizedBox(height: 72 + 20 + bottomSafeArea + 16),
    );
  }
}
