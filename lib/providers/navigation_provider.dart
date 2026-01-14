// =============================================================================
// navigation_provider.dart — Riverpod Navigation State Management
// =============================================================================
// Manages tab navigation state across the app with strict Riverpod patterns.
// Provides reactive tab index state for FloatingNavBar and screen transitions.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation tabs enum for type safety
enum NavTab {
  workout(0, 'Workout'),
  nutrition(1, 'Nutrition'),
  profile(2, 'Profile');

  const NavTab(this.tabIndex, this.label);
  final int tabIndex;
  final String label;

  static NavTab fromIndex(int index) {
    return NavTab.values.firstWhere(
      (tab) => tab.tabIndex == index,
      orElse: () => NavTab.workout,
    );
  }
}

/// Navigation state container
class NavigationState {
  const NavigationState({
    this.currentTab = NavTab.workout,
    this.previousTab,
  });

  final NavTab currentTab;
  final NavTab? previousTab;

  int get currentIndex => currentTab.tabIndex;

  NavigationState copyWith({
    NavTab? currentTab,
    NavTab? previousTab,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      previousTab: previousTab ?? this.previousTab,
    );
  }
}

/// Navigation notifier — handles tab switching logic
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  /// Switch to a specific tab by enum
  void switchTab(NavTab tab) {
    if (tab == state.currentTab) return;
    
    state = state.copyWith(
      currentTab: tab,
      previousTab: state.currentTab,
    );
  }

  /// Switch to a specific tab by index
  void switchToIndex(int index) {
    final tab = NavTab.fromIndex(index);
    switchTab(tab);
  }

  /// Go back to previous tab (if exists)
  void goBack() {
    if (state.previousTab != null) {
      state = state.copyWith(
        currentTab: state.previousTab,
        previousTab: state.currentTab,
      );
    }
  }

  /// Reset to initial state
  void reset() {
    state = const NavigationState();
  }
}

/// Main navigation provider
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);

/// Convenience provider for just the current tab index
final currentTabIndexProvider = Provider<int>((ref) {
  return ref.watch(navigationProvider).currentIndex;
});

/// Convenience provider for current tab enum
final currentTabProvider = Provider<NavTab>((ref) {
  return ref.watch(navigationProvider).currentTab;
});
