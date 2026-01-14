// =============================================================================
// unit_system_provider.dart — Metric/Imperial Unit System with Persistence
// =============================================================================
// Riverpod StateNotifier for unit system management with:
// - SharedPreferences persistence for user choice
// - Conversion helpers for weight (kg/lb) and height (cm/ft)
// - Auto-detection based on locale
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported unit systems
enum UnitSystem {
  metric,   // kg, cm
  imperial, // lb, ft/in
}

/// Unit system state container
@immutable
class UnitSystemState {
  const UnitSystemState({
    required this.unitSystem,
    this.isInitialized = false,
  });

  /// Current active unit system
  final UnitSystem unitSystem;
  
  /// Whether initial load has completed
  final bool isInitialized;

  UnitSystemState copyWith({
    UnitSystem? unitSystem,
    bool? isInitialized,
  }) {
    return UnitSystemState(
      unitSystem: unitSystem ?? this.unitSystem,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Unit conversion helpers
class UnitConverter {
  // Weight conversions
  static const double kgToLb = 2.20462;
  static const double lbToKg = 0.453592;
  
  // Height conversions
  static const double cmToInch = 0.393701;
  static const double inchToCm = 2.54;
  static const double cmToFeet = 0.0328084;
  static const double feetToCm = 30.48;

  /// Convert weight FROM metric TO display unit
  static double convertWeightFromMetric(double kg, UnitSystem system) {
    if (system == UnitSystem.imperial) {
      return kg * kgToLb;
    }
    return kg;
  }

  /// Convert weight TO metric FROM display unit
  static double convertWeightToMetric(double value, UnitSystem system) {
    if (system == UnitSystem.imperial) {
      return value * lbToKg;
    }
    return value;
  }

  /// Convert height FROM metric (cm) TO display unit
  static double convertHeightFromMetric(double cm, UnitSystem system) {
    if (system == UnitSystem.imperial) {
      return cm * cmToInch;
    }
    return cm;
  }

  /// Convert height TO metric (cm) FROM display unit
  static double convertHeightToMetric(double value, UnitSystem system) {
    if (system == UnitSystem.imperial) {
      return value * inchToCm;
    }
    return value;
  }

  /// Format weight with unit
  static String formatWeight(double kg, UnitSystem system, {int decimals = 1}) {
    final value = convertWeightFromMetric(kg, system);
    final unit = system == UnitSystem.metric ? 'кг' : 'lb';
    return '${value.toStringAsFixed(decimals)} $unit';
  }

  /// Format height with unit
  static String formatHeight(double cm, UnitSystem system) {
    if (system == UnitSystem.imperial) {
      final totalInches = cm * cmToInch;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return "$feet'$inches\"";
    }
    return '${cm.round()} см';
  }

  /// Get weight unit suffix
  static String weightUnit(UnitSystem system) {
    return system == UnitSystem.metric ? 'кг' : 'lb';
  }

  /// Get height unit suffix
  static String heightUnit(UnitSystem system) {
    return system == UnitSystem.metric ? 'см' : 'in';
  }
  
  /// Get weight range for picker (min, max, step) in display units
  static ({double min, double max, double step}) weightRange(UnitSystem system) {
    if (system == UnitSystem.imperial) {
      return (min: 66.0, max: 440.0, step: 0.5); // 30-200 kg in lb
    }
    return (min: 30.0, max: 200.0, step: 0.1);
  }
}

/// StateNotifier for unit system management
class UnitSystemNotifier extends StateNotifier<UnitSystemState> {
  UnitSystemNotifier() : super(const UnitSystemState(unitSystem: UnitSystem.metric)) {
    _initialize();
  }

  static const String _prefKey = 'unit_system';

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getString(_prefKey);
      
      UnitSystem system = UnitSystem.metric;
      
      if (savedValue != null) {
        system = savedValue == 'imperial' ? UnitSystem.imperial : UnitSystem.metric;
      } else {
        // Auto-detect based on locale: US, UK, Myanmar, Liberia use imperial
        final locale = WidgetsBinding.instance.platformDispatcher.locale;
        final imperialCountries = {'US', 'LR', 'MM'};
        if (imperialCountries.contains(locale.countryCode)) {
          system = UnitSystem.imperial;
        }
      }

      state = UnitSystemState(
        unitSystem: system,
        isInitialized: true,
      );
    } catch (e) {
      state = const UnitSystemState(
        unitSystem: UnitSystem.metric,
        isInitialized: true,
      );
    }
  }

  /// Set unit system explicitly (user choice)
  Future<void> setUnitSystem(UnitSystem system) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, system == UnitSystem.imperial ? 'imperial' : 'metric');
      
      state = state.copyWith(unitSystem: system);
    } catch (e) {
      state = state.copyWith(unitSystem: system);
    }
  }

  /// Toggle between metric and imperial
  Future<void> toggle() async {
    final newSystem = state.unitSystem == UnitSystem.metric 
        ? UnitSystem.imperial 
        : UnitSystem.metric;
    await setUnitSystem(newSystem);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Main unit system provider with full state
final unitSystemStateProvider = StateNotifierProvider<UnitSystemNotifier, UnitSystemState>((ref) {
  return UnitSystemNotifier();
});

/// Convenience provider for just the unit system enum
final unitSystemProvider = Provider<UnitSystem>((ref) {
  return ref.watch(unitSystemStateProvider).unitSystem;
});

/// Whether unit system has been initialized
final unitSystemInitializedProvider = Provider<bool>((ref) {
  return ref.watch(unitSystemStateProvider).isInitialized;
});

/// Is metric system active
final isMetricProvider = Provider<bool>((ref) {
  return ref.watch(unitSystemProvider) == UnitSystem.metric;
});
