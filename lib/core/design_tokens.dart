import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Trainer#1 Design System — Futuristic Luxury Tech
/// Black + Chrome + Neon Turquoise aesthetic
/// Inspiration: Apple Design, Mercedes G-Class, premium gym architecture
class DesignTokens {
  // ===== TRAINER#1 COLOR PALETTE =====
  
  /// Base colors (Pure Black & Gray Theme)
  static const Color bgBase = Color(0xFF000000);        // Pure black
  static const Color surface = Color(0xFF1A1A1A);       // Dark gray surface
  static const Color cardSurface = Color(0xFF2A2A2A);   // Elevated gray
  
  /// Accent colors (White only - NO green!)
  static const Color primaryAccent = Color(0xFFFFFFFF);  // Pure white
  static const Color secondaryAccent = Color(0xFFB3B3B3); // Light gray
  static const Color goldAccent = Color(0xFFFFFFFF);     // Pure white
  static const Color chromeAccent = Color(0xFFFFFFFF);   // Pure white
  
  /// Status colors
  static const Color success = Color(0xFF4CAF50);       // Green success
  static const Color warning = Color(0xFFFF9800);       // Orange warning
  static const Color error = Color(0xFFFF5252);         // Red error
  static const Color info = Color(0xFF00D9A3);          // Turquoise info
  
  /// Text colors (per Trainer#1.md)
  static const Color textPrimary = Color(0xFFFFFFFF);   // Main text white
  static const Color textSecondary = Color(0xFFB3B3B3); // Subtext gray
  static const Color textTertiary = Color(0x99FFFFFF);  // 60% opacity
  static const Color textDisabled = Color(0x66FFFFFF);  // 40% opacity
  
  /// Glass overlay (20% transparency, 8px blur per Trainer#1)
  static const Color glassOverlay = Color(0x33FFFFFF); // 20% white
  static const double glassBlur = 8.0;                 // 8px blur
  static const Color glassBorder = Color(0x1AFFFFFF);  // 10% white chrome edge
  
  // ===== GRADIENTS =====
  
  /// Neon turquoise to pink glow
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAccent, secondaryAccent],
  );
  
  /// Pure dark gradient (black to gray)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),  // Pure black
      Color(0xFF0A0A0A),  // Very dark gray
      Color(0xFF1A1A1A),  // Dark gray
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Glassmorphic card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF), // 20% white
      Color(0x14FFFFFF), // 8% white
    ],
  );
  
  // ===== TYPOGRAPHY =====
  
  /// Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: textPrimary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: textPrimary,
  );
  
  /// Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: textSecondary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: textTertiary,
  );
  
  /// Captions
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: textTertiary,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: textTertiary,
  );
  
  /// Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textPrimary,
  );
  
  // ===== SPACING =====
  
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  
  // ===== BORDER RADIUS =====
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 50.0;
  
  // ===== SHADOWS =====
  
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowHard = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24,
      spreadRadius: -6,
      offset: Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: -5,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ===== ANIMATION CURVES =====
  
  static const Curve easeInOutCubic = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve easeOutQuart = Cubic(0.25, 0.46, 0.45, 0.94);
  static const Curve easeInQuart = Cubic(0.55, 0.06, 0.68, 0.19);
  
  // ===== DURATIONS =====
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationXSlow = Duration(milliseconds: 500);
  
  // ===== COMPONENT SIZING =====
  
  /// Button heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 54.0;
  
  /// Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;
  
  /// Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;
  
  /// Minimum touch target
  static const double minTouchTarget = 44.0;
  
  // ===== LAYOUT BREAKPOINTS =====
  
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  
  // ===== Z-INDEX =====
  
  static const double zModal = 1000.0;
  static const double zDropdown = 100.0;
  static const double zOverlay = 50.0;
  static const double zAppBar = 10.0;
  static const double zCard = 1.0;
}

/// Helper для получения responsive spacing
class ResponsiveSpacing {
  static double getSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width < DesignTokens.breakpointMobile) {
      return baseSpacing * 0.8;
    } else if (width < DesignTokens.breakpointTablet) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.2;
    }
  }
}

/// Helper для цветов с учётом доступности
class A11yColors {
  /// Проверяет контраст между двумя цветами
  static double getContrastRatio(Color foreground, Color background) {
    final fLuminance = foreground.computeLuminance();
    final bLuminance = background.computeLuminance();
    
    final lighter = math.max(fLuminance, bLuminance);
    final darker = math.min(fLuminance, bLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Возвращает цвет текста с достаточным контрастом
  static Color getAccessibleTextColor(Color background) {
    final whiteContrast = getContrastRatio(Colors.white, background);
    final blackContrast = getContrastRatio(Colors.black, background);
    
    return whiteContrast >= 4.5 ? Colors.white : Colors.black;
  }
}