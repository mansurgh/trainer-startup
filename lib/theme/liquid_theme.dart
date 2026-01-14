// =============================================================================
// liquid_theme.dart — Obsidian Glass Design System (Monochrome)
// =============================================================================
// "Liquid Noir" aesthetic: Pure Black & White
// Zero color hues — only luminance and grey scale
// Inspired by Dieter Rams, Apple Pro, Carbon Fiber aesthetics
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// OBSIDIAN NOIR COLOR PALETTE — Pure Monochrome
// =============================================================================

/// True OLED Black — maximum depth, battery efficient
const Color kLiquidBlack = Color(0xFF000000);

/// Charcoal — elevated background
const Color kMidnightBlue = Color(0xFF0A0A0A);

/// Obsidian Surface — elevated dark
const Color kDeepSpace = Color(0xFF121212);

/// Smoked Glass — card/container background
const Color kNebulaSurface = Color(0xFF1A1A1A);

/// Grey Border — subtle edge
const Color kLiquidBorder = Color(0xFF2A2A2A);

// =============================================================================
// PRIMARY ACCENT — White (Monochrome — No Hue!)
// =============================================================================

/// Pure White — primary (was Electric Blue)
const Color kElectricBlue = Color(0xFFFFFFFF);

/// Light Grey — mid accent (was Royal Blue)
const Color kRoyalBlue = Color(0xFFCCCCCC);

/// White — lighter accent (was Sky Blue)
const Color kSkyBlue = Color(0xFFE0E0E0);

/// Pure White — primary end (was Neon Cyan)
const Color kNeonCyan = Color(0xFFFFFFFF);

/// Soft White — glow (was Ice Cyan)
const Color kIceCyan = Color(0xFFE0E0E0);

/// Grey — warm accent (was Holographic)
const Color kHolographic = Color(0xFFA0A0A0);

// =============================================================================
// SECONDARY ACCENTS — Grey Scale Only
// =============================================================================

/// Medium Grey — secondary accent (was Deep Violet)
const Color kDeepViolet = Color(0xFF808080);

/// Dark Grey — gradient secondary (was Electric Purple)
const Color kElectricPurple = Color(0xFF505050);

/// Cool Chrome — metallic text
const Color kCoolWhite = Color(0xFFE0E0E0);

/// Frost White — pure white
const Color kFrostWhite = Color(0xFFFFFFFF);

// =============================================================================
// TEXT COLORS — Pure Grey Scale (No Warm/Cool Tint)
// =============================================================================

/// Primary text — pure white for maximum contrast
const Color kLiquidTextPrimary = Color(0xFFFFFFFF);

/// Secondary text — neutral grey
const Color kLiquidTextSecondary = Color(0xFFB0B0B0);

/// Tertiary text — subtle grey
const Color kLiquidTextTertiary = Color(0xFF707070);

/// Disabled text — very low opacity grey
const Color kLiquidTextDisabled = Color(0xFF404040);

// =============================================================================
// SEMANTIC COLORS — Luminance-Based (No Hue!)
// Success = White + Glow
// Error = Grey (lower luminance)
// =============================================================================

/// Success — White (luminance-based)
const Color kNeonSuccess = Color(0xFFFFFFFF);
const Color kNeonSuccessGlow = Color(0x40FFFFFF);

/// Error — Medium Grey
const Color kNeonError = Color(0xFF909090);
const Color kNeonErrorGlow = Color(0x30909090);

/// Warning — Light Grey
const Color kNeonWarning = Color(0xFFB0B0B0);
const Color kNeonWarningGlow = Color(0x30B0B0B0);

/// Info — White
const Color kNeonInfo = Color(0xFFFFFFFF);
const Color kNeonInfoGlow = Color(0x40FFFFFF);

// =============================================================================
// GRADIENTS — Monochrome Light System
// =============================================================================

/// Primary gradient — White to Light Grey
const LinearGradient kLiquidPrimaryGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFFFFFFF), Color(0xFFCCCCCC)],
);

/// Vertical Primary gradient — White to Light Grey
const LinearGradient kLiquidPrimaryGradientVertical = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFFFFF), Color(0xFFCCCCCC)],
);

/// Secondary gradient — Grey to White
const LinearGradient kLiquidSecondaryGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFF808080), Color(0xFFFFFFFF)],
);

/// Holographic gradient — now monochrome spectrum
const LinearGradient kHolographicGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF404040), Color(0xFF808080), Color(0xFFFFFFFF)],
  stops: [0.0, 0.5, 1.0],
);

/// Glass surface gradient — white with low opacity
LinearGradient kGlassSurfaceGradient({double opacity = 0.08}) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(opacity * 1.5),
    Colors.white.withOpacity(opacity * 0.3),
  ],
);

/// Glass border gradient — rim light effect (monochrome)
const LinearGradient kGlassBorderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x40FFFFFF), // 25% white at top-left
    Color(0x08FFFFFF), // 3% white at bottom-right
  ],
);

/// Deep background mesh gradient — pure black
const LinearGradient kDeepBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0A0A0A),
    kLiquidBlack,
    Color(0xFF050505),
  ],
  stops: [0.0, 0.6, 1.0],
);

/// Radial glow gradient — white glow
RadialGradient kBlueGlowGradient({double opacity = 0.3}) => RadialGradient(
  center: Alignment.center,
  radius: 1.0,
  colors: [
    Colors.white.withOpacity(opacity),
    Colors.transparent,
  ],
);

/// Radial glow gradient — same as above (monochrome)
RadialGradient kCyanGlowGradient({double opacity = 0.3}) => RadialGradient(
  center: Alignment.center,
  radius: 1.0,
  colors: [
    Colors.white.withOpacity(opacity),
    Colors.transparent,
  ],
);

// =============================================================================
// GLASSMORPHISM TOKENS
// =============================================================================

/// Light blur — subtle frosted effect
const double kLiquidBlurLight = 12.0;

/// Medium blur — standard glass effect
const double kLiquidBlurMedium = 20.0;

/// Heavy blur — modals, sheets
const double kLiquidBlurHeavy = 40.0;

/// Extra heavy blur — full screen overlays
const double kLiquidBlurXHeavy = 60.0;

/// Glass opacity levels
const double kGlassOpacityXLight = 0.03;
const double kGlassOpacityLight = 0.05;
const double kGlassOpacityMedium = 0.08;
const double kGlassOpacityHeavy = 0.12;
const double kGlassOpacityXHeavy = 0.18;

/// Glass border opacity
const double kGlassBorderOpacityLight = 0.06;
const double kGlassBorderOpacityMedium = 0.10;
const double kGlassBorderOpacityHeavy = 0.15;

// =============================================================================
// SPACING TOKENS
// =============================================================================

const double kLiquidSpaceXXS = 2.0;
const double kLiquidSpaceXS = 4.0;
const double kLiquidSpaceSM = 8.0;
const double kLiquidSpaceMD = 16.0;
const double kLiquidSpaceLG = 24.0;
const double kLiquidSpaceXL = 32.0;
const double kLiquidSpaceXXL = 48.0;
const double kLiquidSpaceXXXL = 64.0;

// =============================================================================
// BORDER RADIUS TOKENS — iOS-style Continuous Corners
// =============================================================================

const double kLiquidRadiusXS = 8.0;
const double kLiquidRadiusSM = 12.0;
const double kLiquidRadiusMD = 16.0;
const double kLiquidRadiusLG = 24.0;
const double kLiquidRadiusXL = 32.0;
const double kLiquidRadiusXXL = 40.0;
const double kLiquidRadiusFull = 999.0;

// =============================================================================
// ANIMATION TOKENS
// =============================================================================

const Duration kLiquidDurationFast = Duration(milliseconds: 150);
const Duration kLiquidDurationMedium = Duration(milliseconds: 250);
const Duration kLiquidDurationSlow = Duration(milliseconds: 400);
const Duration kLiquidDurationXSlow = Duration(milliseconds: 600);

const Curve kLiquidCurveEaseOut = Curves.easeOutCubic;
const Curve kLiquidCurveEaseIn = Curves.easeInCubic;
const Curve kLiquidCurveEaseInOut = Curves.easeInOutCubic;
const Curve kLiquidCurveBounce = Curves.elasticOut;
const Curve kLiquidCurveSpring = Curves.easeOutBack;

// =============================================================================
// TYPOGRAPHY — SF Pro Display Logic
// =============================================================================

/// Giant display numbers — stats, metrics (Thin)
TextStyle get kLiquidDisplayGiant => GoogleFonts.inter(
  fontSize: 72,
  fontWeight: FontWeight.w100,
  height: 1.0,
  letterSpacing: -3,
  color: kLiquidTextPrimary,
);

/// Large display numbers — secondary stats
TextStyle get kLiquidDisplayLarge => GoogleFonts.inter(
  fontSize: 48,
  fontWeight: FontWeight.w200,
  height: 1.1,
  letterSpacing: -2,
  color: kLiquidTextPrimary,
);

/// Medium display numbers
TextStyle get kLiquidDisplayMedium => GoogleFonts.inter(
  fontSize: 32,
  fontWeight: FontWeight.w300,
  height: 1.2,
  letterSpacing: -1,
  color: kLiquidTextPrimary,
);

/// Small display numbers
TextStyle get kLiquidDisplaySmall => GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  height: 1.2,
  letterSpacing: -0.5,
  color: kLiquidTextPrimary,
);

/// Large title — iOS-style (Bold, tight tracking)
TextStyle get kLiquidTitleLarge => GoogleFonts.inter(
  fontSize: 34,
  fontWeight: FontWeight.w700,
  height: 1.1,
  letterSpacing: -1.5,
  color: kLiquidTextPrimary,
);

/// Medium title
TextStyle get kLiquidTitleMedium => GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.8,
  color: kLiquidTextPrimary,
);

/// Small title
TextStyle get kLiquidTitleSmall => GoogleFonts.inter(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: -0.5,
  color: kLiquidTextPrimary,
);

/// Headline
TextStyle get kLiquidHeadline => GoogleFonts.inter(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: -0.3,
  color: kLiquidTextPrimary,
);

/// Body large — primary body text
TextStyle get kLiquidBodyLarge => GoogleFonts.inter(
  fontSize: 17,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0,
  color: kLiquidTextPrimary,
);

/// Body medium — secondary body text
TextStyle get kLiquidBodyMedium => GoogleFonts.inter(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.1,
  color: kLiquidTextSecondary,
);

/// Body small — tertiary text
TextStyle get kLiquidBodySmall => GoogleFonts.inter(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.4,
  letterSpacing: 0.1,
  color: kLiquidTextTertiary,
);

/// Caption
TextStyle get kLiquidCaption => GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.3,
  letterSpacing: 0.2,
  color: kLiquidTextTertiary,
);

/// Overline — labels, tags
TextStyle get kLiquidOverline => GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: 1.5,
  color: kLiquidTextTertiary,
);

/// Button text
TextStyle get kLiquidButton => GoogleFonts.inter(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: -0.2,
  color: kLiquidTextPrimary,
);

// =============================================================================
// SHADOWS — Colored Diffuse Glows
// =============================================================================

/// Blue glow shadow for active elements
List<BoxShadow> kBlueGlowShadow({double opacity = 0.4, double blur = 20}) => [
  BoxShadow(
    color: kElectricBlue.withOpacity(opacity),
    blurRadius: blur,
    spreadRadius: -4,
    offset: const Offset(0, 4),
  ),
];

/// Cyan glow shadow for highlighted elements
List<BoxShadow> kCyanGlowShadow({double opacity = 0.4, double blur = 20}) => [
  BoxShadow(
    color: kNeonCyan.withOpacity(opacity),
    blurRadius: blur,
    spreadRadius: -4,
    offset: const Offset(0, 4),
  ),
];

/// Purple glow shadow
List<BoxShadow> kPurpleGlowShadow({double opacity = 0.4, double blur = 20}) => [
  BoxShadow(
    color: kDeepViolet.withOpacity(opacity),
    blurRadius: blur,
    spreadRadius: -4,
    offset: const Offset(0, 4),
  ),
];

/// Dual gradient glow (blue + cyan)
List<BoxShadow> kDualGlowShadow({double opacity = 0.3}) => [
  BoxShadow(
    color: kElectricBlue.withOpacity(opacity),
    blurRadius: 24,
    spreadRadius: -6,
    offset: const Offset(-4, 4),
  ),
  BoxShadow(
    color: kNeonCyan.withOpacity(opacity),
    blurRadius: 24,
    spreadRadius: -6,
    offset: const Offset(4, 4),
  ),
];

/// Soft dark shadow for depth
List<BoxShadow> kDeepShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.5),
    blurRadius: 30,
    spreadRadius: -8,
    offset: const Offset(0, 12),
  ),
];

/// Inner glow effect (using gradient + border)
List<BoxShadow> kInnerGlow({Color color = kNeonCyan, double opacity = 0.2}) => [
  BoxShadow(
    color: color.withOpacity(opacity),
    blurRadius: 12,
    spreadRadius: -8,
    offset: Offset.zero,
  ),
];

// =============================================================================
// LIQUID GLASS THEME EXTENSION
// =============================================================================

@immutable
class LiquidThemeExtension extends ThemeExtension<LiquidThemeExtension> {
  const LiquidThemeExtension({
    required this.liquidBlack,
    required this.midnightBlue,
    required this.deepSpace,
    required this.nebulaSurface,
    required this.liquidBorder,
    required this.electricBlue,
    required this.neonCyan,
    required this.deepViolet,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.error,
    required this.warning,
    required this.blurSigma,
  });

  final Color liquidBlack;
  final Color midnightBlue;
  final Color deepSpace;
  final Color nebulaSurface;
  final Color liquidBorder;
  final Color electricBlue;
  final Color neonCyan;
  final Color deepViolet;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color error;
  final Color warning;
  final double blurSigma;

  /// Primary gradient
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [electricBlue, neonCyan],
  );

  /// Radial glow
  RadialGradient primaryGlow({double opacity = 0.3}) => RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      electricBlue.withOpacity(opacity),
      Colors.transparent,
    ],
  );

  @override
  LiquidThemeExtension copyWith({
    Color? liquidBlack,
    Color? midnightBlue,
    Color? deepSpace,
    Color? nebulaSurface,
    Color? liquidBorder,
    Color? electricBlue,
    Color? neonCyan,
    Color? deepViolet,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? error,
    Color? warning,
    double? blurSigma,
  }) {
    return LiquidThemeExtension(
      liquidBlack: liquidBlack ?? this.liquidBlack,
      midnightBlue: midnightBlue ?? this.midnightBlue,
      deepSpace: deepSpace ?? this.deepSpace,
      nebulaSurface: nebulaSurface ?? this.nebulaSurface,
      liquidBorder: liquidBorder ?? this.liquidBorder,
      electricBlue: electricBlue ?? this.electricBlue,
      neonCyan: neonCyan ?? this.neonCyan,
      deepViolet: deepViolet ?? this.deepViolet,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  LiquidThemeExtension lerp(
    covariant ThemeExtension<LiquidThemeExtension>? other,
    double t,
  ) {
    if (other is! LiquidThemeExtension) return this;
    return LiquidThemeExtension(
      liquidBlack: Color.lerp(liquidBlack, other.liquidBlack, t)!,
      midnightBlue: Color.lerp(midnightBlue, other.midnightBlue, t)!,
      deepSpace: Color.lerp(deepSpace, other.deepSpace, t)!,
      nebulaSurface: Color.lerp(nebulaSurface, other.nebulaSurface, t)!,
      liquidBorder: Color.lerp(liquidBorder, other.liquidBorder, t)!,
      electricBlue: Color.lerp(electricBlue, other.electricBlue, t)!,
      neonCyan: Color.lerp(neonCyan, other.neonCyan, t)!,
      deepViolet: Color.lerp(deepViolet, other.deepViolet, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
    );
  }

  /// Default Liquid Glass theme
  static const LiquidThemeExtension liquid = LiquidThemeExtension(
    liquidBlack: kLiquidBlack,
    midnightBlue: kMidnightBlue,
    deepSpace: kDeepSpace,
    nebulaSurface: kNebulaSurface,
    liquidBorder: kLiquidBorder,
    electricBlue: kElectricBlue,
    neonCyan: kNeonCyan,
    deepViolet: kDeepViolet,
    textPrimary: kLiquidTextPrimary,
    textSecondary: kLiquidTextSecondary,
    textTertiary: kLiquidTextTertiary,
    success: kNeonSuccess,
    error: kNeonError,
    warning: kNeonWarning,
    blurSigma: kLiquidBlurMedium,
  );
}

// =============================================================================
// CONTEXT EXTENSION — Easy Theme Access
// =============================================================================

extension LiquidThemeContext on BuildContext {
  /// Quick access to Liquid Glass theme extension
  LiquidThemeExtension get liquid =>
      Theme.of(this).extension<LiquidThemeExtension>() ??
      LiquidThemeExtension.liquid;
}

// =============================================================================
// BUILD LIQUID GLASS THEME — Full ThemeData Construction
// =============================================================================

/// Builds the complete Liquid Glass ThemeData.
/// Usage: `MaterialApp(theme: buildLiquidGlassTheme())`
ThemeData buildLiquidGlassTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kElectricBlue,
    brightness: Brightness.dark,
    surface: kNebulaSurface,
    primary: kElectricBlue,
    secondary: kNeonCyan,
    tertiary: kDeepViolet,
    error: kNeonError,
    onSurface: kLiquidTextPrimary,
    onPrimary: kLiquidBlack,
    onSecondary: kLiquidBlack,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    displayLarge: kLiquidDisplayGiant,
    displayMedium: kLiquidDisplayLarge,
    displaySmall: kLiquidDisplayMedium,
    headlineLarge: kLiquidTitleLarge,
    headlineMedium: kLiquidTitleMedium,
    headlineSmall: kLiquidTitleSmall,
    titleLarge: kLiquidHeadline,
    titleMedium: kLiquidBodyLarge.copyWith(fontWeight: FontWeight.w600),
    titleSmall: kLiquidBodyMedium.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: kLiquidBodyLarge,
    bodyMedium: kLiquidBodyMedium,
    bodySmall: kLiquidBodySmall,
    labelLarge: kLiquidCaption.copyWith(fontWeight: FontWeight.w600),
    labelMedium: kLiquidCaption,
    labelSmall: kLiquidOverline,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kLiquidBlack,
    canvasColor: kLiquidBlack,
    textTheme: textTheme,
    
    // Extensions
    extensions: const [LiquidThemeExtension.liquid],
    
    // AppBar — transparent with blur (handled by custom widgets)
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: kLiquidHeadline,
      iconTheme: const IconThemeData(color: kLiquidTextPrimary, size: 24),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Cards — Glass style (prefer custom LiquidGlassContainer)
    cardTheme: CardThemeData(
      color: kNebulaSurface.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusLG),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // Elevated buttons — Glass with gradient
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kDeepSpace,
        foregroundColor: kLiquidTextPrimary,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: kLiquidSpaceLG,
          vertical: kLiquidSpaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kLiquidRadiusMD),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        textStyle: kLiquidButton,
      ),
    ),
    
    // Filled buttons — Primary gradient style
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kElectricBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: kLiquidSpaceLG,
          vertical: kLiquidSpaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kLiquidRadiusMD),
        ),
        textStyle: kLiquidButton,
      ),
    ),
    
    // Outlined buttons — Cyan border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kNeonCyan,
        side: const BorderSide(color: kNeonCyan, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: kLiquidSpaceLG,
          vertical: kLiquidSpaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kLiquidRadiusMD),
        ),
        textStyle: kLiquidButton.copyWith(color: kNeonCyan),
      ),
    ),
    
    // Input decoration — Glass capsule style
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusMD),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusMD),
        borderSide: const BorderSide(color: kNeonCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusMD),
        borderSide: const BorderSide(color: kNeonError),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: kLiquidSpaceMD,
        vertical: kLiquidSpaceMD,
      ),
      hintStyle: kLiquidBodyMedium.copyWith(color: kLiquidTextTertiary),
      labelStyle: kLiquidBodyMedium.copyWith(color: kLiquidTextSecondary),
      prefixIconColor: kLiquidTextTertiary,
      suffixIconColor: kLiquidTextTertiary,
    ),
    
    // Navigation bar — Floating glass style
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kElectricBlue.withOpacity(0.15),
      elevation: 0,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kLiquidCaption.copyWith(
            color: kNeonCyan,
            fontWeight: FontWeight.w700,
          );
        }
        return kLiquidCaption.copyWith(color: kLiquidTextTertiary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kNeonCyan, size: 26);
        }
        return const IconThemeData(color: kLiquidTextTertiary, size: 24);
      }),
    ),
    
    // Dividers
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.08),
      thickness: 1,
      space: 1,
    ),
    
    // Icons
    iconTheme: const IconThemeData(
      color: kLiquidTextPrimary,
      size: 24,
    ),
    
    // Chips — Glass style
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.06),
      selectedColor: kElectricBlue.withOpacity(0.2),
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusFull),
      ),
      labelStyle: kLiquidCaption,
      padding: EdgeInsets.symmetric(
        horizontal: kLiquidSpaceSM,
        vertical: kLiquidSpaceXS,
      ),
    ),
    
    // Dialogs — Glass card
    dialogTheme: DialogThemeData(
      backgroundColor: kDeepSpace.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusXL),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
    ),
    
    // Bottom sheet — Glass style
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: kDeepSpace.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kLiquidRadiusXL),
        ),
      ),
      dragHandleColor: kLiquidTextTertiary,
      dragHandleSize: const Size(36, 4),
    ),
    
    // Slider — Cyan accent
    sliderTheme: SliderThemeData(
      activeTrackColor: kNeonCyan,
      inactiveTrackColor: Colors.white.withOpacity(0.1),
      thumbColor: kCoolWhite,
      overlayColor: kNeonCyan.withOpacity(0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    
    // Progress indicator — Cyan
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: kNeonCyan,
      linearTrackColor: Colors.white.withOpacity(0.1),
      circularTrackColor: Colors.white.withOpacity(0.1),
    ),
    
    // Switch — Blue/Cyan
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kCoolWhite;
        return kLiquidTextTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kElectricBlue;
        }
        return Colors.white.withOpacity(0.1);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kElectricBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kLiquidRadiusMD),
      ),
    ),
  );
}
