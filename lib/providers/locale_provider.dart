// =============================================================================
// locale_provider.dart — Robust Internationalization with Auto-Detection
// =============================================================================
// Riverpod StateNotifier for locale management with:
// - SharedPreferences persistence for user choice
// - Platform.localeName fallback for first-time detection
// - Auto-detection for RU/BY/KZ/UA regions → Russian
// - All other regions → English (default)
// =============================================================================

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales in the app
class AppLocales {
  static const Locale english = Locale('en');
  static const Locale russian = Locale('ru');
  
  static const List<Locale> supported = [english, russian];
  
  /// CIS region country codes that default to Russian
  static const Set<String> russianRegions = {'RU', 'BY', 'KZ', 'UA'};
}

/// Locale state container
@immutable
class LocaleState {
  const LocaleState({
    required this.locale,
    this.isInitialized = false,
    this.isUserSelected = false,
  });

  /// Current active locale
  final Locale locale;
  
  /// Whether initial detection has completed
  final bool isInitialized;
  
  /// Whether user explicitly selected this locale (vs auto-detected)
  final bool isUserSelected;

  LocaleState copyWith({
    Locale? locale,
    bool? isInitialized,
    bool? isUserSelected,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isInitialized: isInitialized ?? this.isInitialized,
      isUserSelected: isUserSelected ?? this.isUserSelected,
    );
  }
}

/// Locale notifier with auto-detection and persistence
class LocaleNotifier extends StateNotifier<LocaleState> {
  static const String _localeKey = 'app_locale';
  static const String _userSelectedKey = 'locale_user_selected';

  LocaleNotifier() : super(const LocaleState(locale: AppLocales.english)) {
    _initializeLocale();
  }

  /// Initialize locale with priority:
  /// 1. SharedPreferences (user's previous choice)
  /// 2. Platform.localeName (auto-detection)
  /// 3. English (fallback default)
  Future<void> _initializeLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has previously selected a locale
      final savedLocaleCode = prefs.getString(_localeKey);
      final wasUserSelected = prefs.getBool(_userSelectedKey) ?? false;
      
      if (savedLocaleCode != null) {
        // User has a saved preference — use it
        final locale = Locale(savedLocaleCode);
        state = LocaleState(
          locale: locale,
          isInitialized: true,
          isUserSelected: wasUserSelected,
        );
        return;
      }
      
      // No saved preference — detect from platform
      final detectedLocale = _detectLocaleFromPlatform();
      
      // Save the detected locale for consistency
      await prefs.setString(_localeKey, detectedLocale.languageCode);
      await prefs.setBool(_userSelectedKey, false);
      
      state = LocaleState(
        locale: detectedLocale,
        isInitialized: true,
        isUserSelected: false,
      );
    } catch (e) {
      // Fallback to English on any error
      state = const LocaleState(
        locale: AppLocales.english,
        isInitialized: true,
        isUserSelected: false,
      );
    }
  }

  /// Detect locale from platform settings
  /// Returns Russian for RU/BY/KZ/UA regions, English otherwise
  Locale _detectLocaleFromPlatform() {
    try {
      // Platform.localeName returns strings like "en_US", "ru_RU", "uk_UA"
      final platformLocale = Platform.localeName;
      
      // Extract language code and country code
      final parts = platformLocale.split(RegExp(r'[_-]'));
      final languageCode = parts.isNotEmpty ? parts[0].toLowerCase() : 'en';
      final countryCode = parts.length > 1 ? parts[1].toUpperCase() : '';
      
      // Check if language is Russian
      if (languageCode == 'ru') {
        return AppLocales.russian;
      }
      
      // Check if country is in CIS region (even if language differs)
      if (AppLocales.russianRegions.contains(countryCode)) {
        return AppLocales.russian;
      }
      
      // Default to English for all other cases
      return AppLocales.english;
    } catch (e) {
      // Fallback to English if platform detection fails
      return AppLocales.english;
    }
  }

  /// Set locale explicitly (user choice)
  /// Persists to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (!AppLocales.supported.contains(locale)) {
      // Unsupported locale — fallback to English
      locale = AppLocales.english;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      await prefs.setBool(_userSelectedKey, true);
      
      state = state.copyWith(
        locale: locale,
        isUserSelected: true,
      );
    } catch (e) {
      // Update state even if persistence fails
      state = state.copyWith(
        locale: locale,
        isUserSelected: true,
      );
    }
  }

  /// Toggle between English and Russian
  Future<void> toggleLocale() async {
    final newLocale = state.locale.languageCode == 'ru'
        ? AppLocales.english
        : AppLocales.russian;
    await setLocale(newLocale);
  }

  /// Reset to auto-detected locale
  Future<void> resetToAutoDetected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      await prefs.remove(_userSelectedKey);
      
      // Re-run detection
      await _initializeLocale();
    } catch (e) {
      // Fallback to detection without clearing prefs
      final detectedLocale = _detectLocaleFromPlatform();
      state = state.copyWith(
        locale: detectedLocale,
        isUserSelected: false,
      );
    }
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Main locale provider with full state
final localeStateProvider =
    StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});

/// Convenience provider for just the Locale (backwards compatible)
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(localeStateProvider).locale;
});

/// Provider to check if locale system is initialized
final localeInitializedProvider = Provider<bool>((ref) {
  return ref.watch(localeStateProvider).isInitialized;
});

/// Provider to check current language code
final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(localeStateProvider).locale.languageCode;
});

/// Provider to check if Russian is active
final isRussianProvider = Provider<bool>((ref) {
  return ref.watch(languageCodeProvider) == 'ru';
});
