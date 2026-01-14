// =============================================================================
// app_colors.dart — Crimson Pulse Palette Aliases
// =============================================================================
// Backward-compatible color aliases for existing code
// Maps old AppColors references to new Crimson Pulse palette
// =============================================================================

import 'package:flutter/material.dart';
import 'crimson_theme.dart';

/// Global app colors — Crimson Pulse palette with legacy aliases
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY — Deep Crimson to Neon Scarlet
  // ============================================
  
  /// Primary color — Deep Crimson
  static const Color primary = kDeepCrimson;
  
  /// Primary gradient start
  static const Color primaryStart = kDeepCrimson;
  
  /// Primary gradient end
  static const Color primaryEnd = kNeonScarlet;
  
  /// Primary gradient
  static const LinearGradient primaryGradient = kCrimsonPrimaryGradient;

  // ============================================
  // SECONDARY ACCENTS
  // ============================================
  
  /// Secondary — Ember Orange
  static const Color secondary = kEmberOrange;
  
  /// Tertiary — Dark Ruby
  static const Color tertiary = kDarkRuby;
  
  /// Accent — Neon Scarlet (bright accent)
  static const Color accent = kNeonScarlet;

  // ============================================
  // BACKGROUND & SURFACES
  // ============================================
  
  /// Background — True OLED Black
  static const Color background = kLiquidBlack;
  
  /// Surface — Smoked Glass
  static const Color surface = kSmokedGlass;
  
  /// Surface glass — Obsidian Surface with 30% opacity
  static Color get surfaceGlass => kSmokedGlass.withOpacity(0.3);
  
  /// Card background — Obsidian Surface
  static const Color cardBackground = kObsidianSurface;
  
  /// Elevated surface — Blood Night
  static const Color elevatedSurface = kBloodNight;

  // ============================================
  // TEXT
  // ============================================
  
  /// On Primary — White (text on primary buttons)
  static const Color onPrimary = kTextPrimary;
  
  /// On Surface — Primary text color
  static const Color onSurface = kTextPrimary;
  
  /// On Background — Primary text color
  static const Color onBackground = kTextPrimary;
  
  /// Text primary
  static const Color textPrimary = kTextPrimary;
  
  /// Text secondary
  static const Color textSecondary = kTextSecondary;
  
  /// Text tertiary / hint
  static const Color textTertiary = kTextTertiary;
  
  /// Text disabled
  static const Color textDisabled = kTextDisabled;

  // ============================================
  // SEMANTIC — Adjusted for Red Primary
  // Since primary is RED, semantics are swapped:
  // - Success = Teal (NOT green)
  // - Error = Orange (NOT red)
  // ============================================
  
  /// Success — Teal (contrasts with red primary)
  static const Color success = kNeonSuccess;
  
  /// Error — Orange (distinct from red primary)
  static const Color error = kNeonError;
  
  /// Warning — Amber
  static const Color warning = kNeonWarning;
  
  /// Info — Cool blue
  static const Color info = kNeonInfo;

  // ============================================
  // BORDERS & DIVIDERS
  // ============================================
  
  /// Border — Crimson tinted
  static const Color border = kCrimsonBorder;
  
  /// Divider — Subtle white
  static Color get divider => Colors.white.withOpacity(0.08);
  
  /// Border light — Very subtle
  static Color get borderLight => Colors.white.withOpacity(0.06);

  // ============================================
  // CHROME & METALLIC
  // ============================================
  
  /// Chrome — Cool metallic
  static const Color chrome = kCoolChrome;
  
  /// White — Frost white with warmth
  static const Color white = kFrostWhite;
  
  /// Pure black
  static const Color black = kLiquidBlack;

  // ============================================
  // GLOW COLORS
  // ============================================
  
  /// Primary glow — Scarlet glow
  static Color get primaryGlow => kNeonScarlet.withOpacity(0.4);
  
  /// Success glow
  static Color get successGlow => kNeonSuccess.withOpacity(0.4);
  
  /// Error glow
  static Color get errorGlow => kNeonError.withOpacity(0.4);
  
  /// Warning glow
  static Color get warningGlow => kNeonWarning.withOpacity(0.4);

  // ============================================
  // LEGACY ALIASES (for backward compatibility)
  // ============================================
  
  /// @deprecated Use [primaryStart] instead
  static const Color electricAmberStart = kDeepCrimson;
  
  /// @deprecated Use [primaryEnd] instead
  static const Color electricAmberEnd = kNeonScarlet;
  
  /// @deprecated Use [primary] instead
  static const Color neonCyan = kNeonScarlet; // Now scarlet
  
  /// @deprecated Use [accent] instead
  static const Color electricBlue = kDeepCrimson; // Now crimson
  
  /// @deprecated Use [surfaceGlass] instead
  static Color get glassSurface => surfaceGlass;
}

/// Extension for easy access in BuildContext
extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors._();
}
