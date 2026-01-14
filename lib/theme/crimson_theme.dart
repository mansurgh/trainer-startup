// =============================================================================
// crimson_theme.dart — Crimson Liquid Glass Design System
// =============================================================================
// "Crimson Pulse" aesthetic: Deep Crimson to Neon Scarlet gradients
// True OLED Black backgrounds with aggressive sports glassmorphism
// Inspired by Nike/UFC, visionOS, Apple HIG 2025
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// CRIMSON PULSE COLOR PALETTE — Adrenaline & Heart Rate
// =============================================================================

/// True OLED Black — maximum depth, battery efficient
const Color kLiquidBlack = Color(0xFF000000);

/// Blood Night — deep dark background with subtle red tint
const Color kBloodNight = Color(0xFF0A0505);

/// Obsidian Surface — elevated dark surface with red undertone
const Color kObsidianSurface = Color(0xFF1A0A0A);

/// Smoked Glass — card/container background (dark red tint)
const Color kSmokedGlass = Color(0xFF1A0505);

/// Border color — subtle crimson edge
const Color kCrimsonBorder = Color(0xFF3D1515);

// =============================================================================
// PRIMARY ACCENT — Deep Crimson to Neon Scarlet Gradient
// =============================================================================

/// Deep Crimson — primary gradient start (blood red)
const Color kDeepCrimson = Color(0xFFD70040);

/// Crimson Core — mid gradient
const Color kCrimsonCore = Color(0xFFE8102E);

/// Neon Scarlet — primary gradient end (bright red glow)
const Color kNeonScarlet = Color(0xFFFF2400);

/// Plasma Red — intense glow color
const Color kPlasmaRed = Color(0xFFFF3333);

/// Hot Pink — accent for highlights
const Color kHotPink = Color(0xFFFF1744);

// =============================================================================
// SECONDARY ACCENTS
// =============================================================================

/// Dark Ruby — secondary accent for depth
const Color kDarkRuby = Color(0xFF8B0000);

/// Ember Orange — warm secondary
const Color kEmberOrange = Color(0xFFFF6B35);

/// Cool Chrome — metallic text accent
const Color kCoolChrome = Color(0xFFE0E0E0);

/// Frost White — pure white with slight warmth
const Color kFrostWhite = Color(0xFFFFF5F5);

// =============================================================================
// TEXT COLORS — Warm Grey Scale
// =============================================================================

/// Primary text — pure white for maximum contrast
const Color kTextPrimary = Color(0xFFFFFFFF);

/// Secondary text — warm grey for less emphasis
const Color kTextSecondary = Color(0xFFB0A8A8);

/// Tertiary text — subtle warm grey for hints/placeholders
const Color kTextTertiary = Color(0xFF7A7070);

/// Disabled text — very low opacity warm grey
const Color kTextDisabled = Color(0xFF4A4040);

// =============================================================================
// SEMANTIC COLORS — Adjusted for Red Primary
// Since primary is RED, we swap semantic meanings:
// - Success = Teal/Cyan (contrasts with red)
// - Error = Orange (different from primary red)
// - Warning = Amber
// =============================================================================

/// Success — Teal (NOT green, to contrast with red brand)
const Color kNeonSuccess = Color(0xFF00D9B5);
const Color kNeonSuccessGlow = Color(0x4000D9B5);

/// Error — Orange (NOT red, since red is primary)
const Color kNeonError = Color(0xFFFF9500);
const Color kNeonErrorGlow = Color(0x40FF9500);

/// Warning — Amber with glow
const Color kNeonWarning = Color(0xFFFFCC00);
const Color kNeonWarningGlow = Color(0x40FFCC00);

/// Info — Cool blue (neutral)
const Color kNeonInfo = Color(0xFF5AC8FA);
const Color kNeonInfoGlow = Color(0x405AC8FA);

// =============================================================================
// GRADIENTS — Crimson Pulse Progressions
// =============================================================================

/// Primary Crimson gradient — buttons, progress, active states
const LinearGradient kCrimsonPrimaryGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [kDeepCrimson, kNeonScarlet],
);

/// Vertical Primary gradient
const LinearGradient kCrimsonVerticalGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [kDeepCrimson, kNeonScarlet],
);

/// Ruby-Orange gradient — secondary actions
const LinearGradient kRubyOrangeGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [kDarkRuby, kEmberOrange],
);

/// Plasma gradient — premium highlights (intense)
const LinearGradient kPlasmaGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kDarkRuby, kDeepCrimson, kNeonScarlet],
  stops: [0.0, 0.5, 1.0],
);

/// Glass surface gradient — smoked glass with red tint
LinearGradient kGlassSurfaceGradient({double opacity = 0.08}) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(opacity * 1.2),
    kNeonScarlet.withOpacity(opacity * 0.3),
  ],
);

/// Rim Light border gradient — white/red to transparent (light hitting glass edge)
const LinearGradient kRimLightGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x60FFFFFF), // 38% white at top-left
    Color(0x30FF2400), // 19% scarlet red
    Color(0x00000000), // transparent at bottom-right
  ],
  stops: [0.0, 0.3, 1.0],
);

/// Glass border gradient for containers
const LinearGradient kGlassBorderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x50FFFFFF), // bright at top-left
    Color(0x20FF2400), // red tint
    Color(0x05FFFFFF), // subtle at bottom-right
  ],
  stops: [0.0, 0.5, 1.0],
);

/// Deep background gradient (pure black to blood night)
const LinearGradient kDeepBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    kLiquidBlack,
    kBloodNight,
    Color(0xFF050202),
  ],
  stops: [0.0, 0.6, 1.0],
);

/// Radial glow gradient for crimson emphasis
RadialGradient kCrimsonGlowGradient({double opacity = 0.3}) => RadialGradient(
  center: Alignment.center,
  radius: 1.0,
  colors: [
    kDeepCrimson.withOpacity(opacity),
    Colors.transparent,
  ],
);

/// Radial glow gradient for scarlet emphasis (brighter)
RadialGradient kScarletGlowGradient({double opacity = 0.3}) => RadialGradient(
  center: Alignment.center,
  radius: 1.0,
  colors: [
    kNeonScarlet.withOpacity(opacity),
    Colors.transparent,
  ],
);

/// Heart Monitor gradient — for charts (red fading to transparent)
LinearGradient kHeartMonitorGradient({double opacity = 0.8}) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    kNeonScarlet.withOpacity(opacity),
    kDeepCrimson.withOpacity(opacity * 0.5),
    Colors.transparent,
  ],
  stops: const [0.0, 0.5, 1.0],
);

// =============================================================================
// GLASSMORPHISM TOKENS
// =============================================================================

/// Light blur — subtle frosted effect
const double kBlurLight = 12.0;

/// Medium blur — standard glass effect
const double kBlurMedium = 20.0;

/// Heavy blur — modals, sheets
const double kBlurHeavy = 40.0;

/// Extra heavy blur — full screen overlays
const double kBlurXHeavy = 60.0;

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

const double kSpaceXXS = 2.0;
const double kSpaceXS = 4.0;
const double kSpaceSM = 8.0;
const double kSpaceMD = 16.0;
const double kSpaceLG = 24.0;
const double kSpaceXL = 32.0;
const double kSpaceXXL = 48.0;
const double kSpaceXXXL = 64.0;

// =============================================================================
// BORDER RADIUS TOKENS — iOS-style Continuous Corners
// =============================================================================

const double kRadiusXS = 8.0;
const double kRadiusSM = 12.0;
const double kRadiusMD = 16.0;
const double kRadiusLG = 24.0;
const double kRadiusXL = 32.0;
const double kRadiusXXL = 40.0;
const double kRadiusFull = 999.0;

// =============================================================================
// ANIMATION TOKENS
// =============================================================================

const Duration kDurationFast = Duration(milliseconds: 150);
const Duration kDurationMedium = Duration(milliseconds: 250);
const Duration kDurationSlow = Duration(milliseconds: 400);
const Duration kDurationXSlow = Duration(milliseconds: 600);

const Curve kCurveEaseOut = Curves.easeOutCubic;
const Curve kCurveEaseIn = Curves.easeInCubic;
const Curve kCurveEaseInOut = Curves.easeInOutCubic;
const Curve kCurveBounce = Curves.elasticOut;
const Curve kCurveSpring = Curves.easeOutBack;

// =============================================================================
// TYPOGRAPHY — Bold Sports Style
// =============================================================================

/// Giant display numbers — stats, metrics (Bold, Condensed feel)
TextStyle get kDisplayGiant => GoogleFonts.inter(
  fontSize: 72,
  fontWeight: FontWeight.w900,
  height: 0.95,
  letterSpacing: -4,
  color: kTextPrimary,
);

/// Large display numbers — secondary stats
TextStyle get kDisplayLarge => GoogleFonts.inter(
  fontSize: 48,
  fontWeight: FontWeight.w800,
  height: 1.0,
  letterSpacing: -2,
  color: kTextPrimary,
);

/// Medium display numbers
TextStyle get kDisplayMedium => GoogleFonts.inter(
  fontSize: 36,
  fontWeight: FontWeight.w700,
  height: 1.1,
  letterSpacing: -1.5,
  color: kTextPrimary,
);

/// Small display numbers
TextStyle get kDisplaySmall => GoogleFonts.inter(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  height: 1.15,
  letterSpacing: -1,
  color: kTextPrimary,
);

/// Large title — Bold, aggressive (Nike/UFC style)
TextStyle get kTitleLarge => GoogleFonts.inter(
  fontSize: 34,
  fontWeight: FontWeight.w800,
  height: 1.05,
  letterSpacing: -1.5,
  fontStyle: FontStyle.italic, // Momentum effect
  color: kTextPrimary,
);

/// Medium title
TextStyle get kTitleMedium => GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 1.15,
  letterSpacing: -0.8,
  color: kTextPrimary,
);

/// Small title
TextStyle get kTitleSmall => GoogleFonts.inter(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: -0.5,
  color: kTextPrimary,
);

/// Headline
TextStyle get kHeadline => GoogleFonts.inter(
  fontSize: 17,
  fontWeight: FontWeight.w700,
  height: 1.25,
  letterSpacing: -0.3,
  color: kTextPrimary,
);

/// Body large — primary body text
TextStyle get kBodyLarge => GoogleFonts.inter(
  fontSize: 17,
  fontWeight: FontWeight.w500,
  height: 1.5,
  letterSpacing: 0,
  color: kTextPrimary,
);

/// Body medium — secondary body text
TextStyle get kBodyMedium => GoogleFonts.inter(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.1,
  color: kTextSecondary,
);

/// Body small — tertiary text
TextStyle get kBodySmall => GoogleFonts.inter(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.4,
  letterSpacing: 0.1,
  color: kTextTertiary,
);

/// Caption
TextStyle get kCaption => GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0.3,
  color: kTextTertiary,
);

/// Overline — labels, tags (uppercase)
TextStyle get kOverline => GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: 1.8,
  color: kTextTertiary,
);

/// Button text
TextStyle get kButtonText => GoogleFonts.inter(
  fontSize: 17,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.2,
  color: kTextPrimary,
);

/// Stats number — for timers, reps, calories
TextStyle get kStatsNumber => GoogleFonts.inter(
  fontSize: 56,
  fontWeight: FontWeight.w900,
  height: 1.0,
  letterSpacing: -3,
  color: kTextPrimary,
);

// =============================================================================
// SHADOWS — Crimson Glow Effects (Bioluminescence/Neon)
// =============================================================================

/// Crimson glow shadow for active elements
List<BoxShadow> kCrimsonGlow({double opacity = 0.5, double blur = 24}) => [
  BoxShadow(
    color: kDeepCrimson.withOpacity(opacity),
    blurRadius: blur,
    spreadRadius: -4,
    offset: const Offset(0, 4),
  ),
];

/// Scarlet glow shadow for highlighted elements
List<BoxShadow> kScarletGlow({double opacity = 0.5, double blur = 24}) => [
  BoxShadow(
    color: kNeonScarlet.withOpacity(opacity),
    blurRadius: blur,
    spreadRadius: -4,
    offset: const Offset(0, 4),
  ),
];

/// Plasma glow shadow (dual crimson + scarlet)
List<BoxShadow> kPlasmaGlow({double opacity = 0.4}) => [
  BoxShadow(
    color: kDeepCrimson.withOpacity(opacity),
    blurRadius: 28,
    spreadRadius: -6,
    offset: const Offset(-4, 6),
  ),
  BoxShadow(
    color: kNeonScarlet.withOpacity(opacity),
    blurRadius: 28,
    spreadRadius: -6,
    offset: const Offset(4, 6),
  ),
];

/// Soft dark shadow for depth (obsidian)
List<BoxShadow> kDeepShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.6),
    blurRadius: 32,
    spreadRadius: -8,
    offset: const Offset(0, 14),
  ),
];

/// Inner crimson glow for active cards
List<BoxShadow> kInnerCrimsonGlow({double opacity = 0.25}) => [
  BoxShadow(
    color: kNeonScarlet.withOpacity(opacity),
    blurRadius: 16,
    spreadRadius: -10,
    offset: Offset.zero,
  ),
];

// =============================================================================
// CRIMSON THEME EXTENSION
// =============================================================================

@immutable
class CrimsonThemeExtension extends ThemeExtension<CrimsonThemeExtension> {
  const CrimsonThemeExtension({
    required this.liquidBlack,
    required this.bloodNight,
    required this.obsidianSurface,
    required this.smokedGlass,
    required this.crimsonBorder,
    required this.deepCrimson,
    required this.neonScarlet,
    required this.darkRuby,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.error,
    required this.warning,
    required this.blurSigma,
  });

  final Color liquidBlack;
  final Color bloodNight;
  final Color obsidianSurface;
  final Color smokedGlass;
  final Color crimsonBorder;
  final Color deepCrimson;
  final Color neonScarlet;
  final Color darkRuby;
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
    colors: [deepCrimson, neonScarlet],
  );

  /// Radial glow
  RadialGradient primaryGlow({double opacity = 0.3}) => RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      neonScarlet.withOpacity(opacity),
      Colors.transparent,
    ],
  );

  @override
  CrimsonThemeExtension copyWith({
    Color? liquidBlack,
    Color? bloodNight,
    Color? obsidianSurface,
    Color? smokedGlass,
    Color? crimsonBorder,
    Color? deepCrimson,
    Color? neonScarlet,
    Color? darkRuby,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? error,
    Color? warning,
    double? blurSigma,
  }) {
    return CrimsonThemeExtension(
      liquidBlack: liquidBlack ?? this.liquidBlack,
      bloodNight: bloodNight ?? this.bloodNight,
      obsidianSurface: obsidianSurface ?? this.obsidianSurface,
      smokedGlass: smokedGlass ?? this.smokedGlass,
      crimsonBorder: crimsonBorder ?? this.crimsonBorder,
      deepCrimson: deepCrimson ?? this.deepCrimson,
      neonScarlet: neonScarlet ?? this.neonScarlet,
      darkRuby: darkRuby ?? this.darkRuby,
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
  CrimsonThemeExtension lerp(
    covariant ThemeExtension<CrimsonThemeExtension>? other,
    double t,
  ) {
    if (other is! CrimsonThemeExtension) return this;
    return CrimsonThemeExtension(
      liquidBlack: Color.lerp(liquidBlack, other.liquidBlack, t)!,
      bloodNight: Color.lerp(bloodNight, other.bloodNight, t)!,
      obsidianSurface: Color.lerp(obsidianSurface, other.obsidianSurface, t)!,
      smokedGlass: Color.lerp(smokedGlass, other.smokedGlass, t)!,
      crimsonBorder: Color.lerp(crimsonBorder, other.crimsonBorder, t)!,
      deepCrimson: Color.lerp(deepCrimson, other.deepCrimson, t)!,
      neonScarlet: Color.lerp(neonScarlet, other.neonScarlet, t)!,
      darkRuby: Color.lerp(darkRuby, other.darkRuby, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
    );
  }

  /// Default Crimson Pulse theme
  static const CrimsonThemeExtension crimson = CrimsonThemeExtension(
    liquidBlack: kLiquidBlack,
    bloodNight: kBloodNight,
    obsidianSurface: kObsidianSurface,
    smokedGlass: kSmokedGlass,
    crimsonBorder: kCrimsonBorder,
    deepCrimson: kDeepCrimson,
    neonScarlet: kNeonScarlet,
    darkRuby: kDarkRuby,
    textPrimary: kTextPrimary,
    textSecondary: kTextSecondary,
    textTertiary: kTextTertiary,
    success: kNeonSuccess,
    error: kNeonError,
    warning: kNeonWarning,
    blurSigma: kBlurMedium,
  );
}

// =============================================================================
// CONTEXT EXTENSION — Easy Theme Access
// =============================================================================

extension CrimsonThemeContext on BuildContext {
  /// Quick access to Crimson Pulse theme extension
  CrimsonThemeExtension get crimson =>
      Theme.of(this).extension<CrimsonThemeExtension>() ??
      CrimsonThemeExtension.crimson;
}

// =============================================================================
// BUILD CRIMSON LIQUID GLASS THEME — Full ThemeData Construction
// =============================================================================

/// Builds the complete Crimson Liquid Glass ThemeData.
/// Usage: `MaterialApp(theme: buildCrimsonGlassTheme())`
ThemeData buildCrimsonGlassTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kDeepCrimson,
    brightness: Brightness.dark,
    surface: kSmokedGlass,
    primary: kDeepCrimson,
    secondary: kNeonScarlet,
    tertiary: kEmberOrange,
    error: kNeonError,
    onSurface: kTextPrimary,
    onPrimary: kTextPrimary,
    onSecondary: kLiquidBlack,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    displayLarge: kDisplayGiant,
    displayMedium: kDisplayLarge,
    displaySmall: kDisplayMedium,
    headlineLarge: kTitleLarge,
    headlineMedium: kTitleMedium,
    headlineSmall: kTitleSmall,
    titleLarge: kHeadline,
    titleMedium: kBodyLarge.copyWith(fontWeight: FontWeight.w600),
    titleSmall: kBodyMedium.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: kBodyLarge,
    bodyMedium: kBodyMedium,
    bodySmall: kBodySmall,
    labelLarge: kCaption.copyWith(fontWeight: FontWeight.w600),
    labelMedium: kCaption,
    labelSmall: kOverline,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kLiquidBlack,
    canvasColor: kLiquidBlack,
    textTheme: textTheme,
    
    // Extensions
    extensions: const [CrimsonThemeExtension.crimson],
    
    // AppBar — transparent with blur (handled by custom widgets)
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: kHeadline,
      iconTheme: const IconThemeData(color: kTextPrimary, size: 24),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Cards — Obsidian Glass style
    cardTheme: CardThemeData(
      color: kSmokedGlass.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLG),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // Elevated buttons — Ruby Glass style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kObsidianSurface,
        foregroundColor: kTextPrimary,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: kSpaceLG,
          vertical: kSpaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        textStyle: kButtonText,
      ),
    ),
    
    // Filled buttons — Crimson gradient style
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kDeepCrimson,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: kSpaceLG,
          vertical: kSpaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
        ),
        textStyle: kButtonText,
      ),
    ),
    
    // Outlined buttons — Scarlet border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kNeonScarlet,
        side: const BorderSide(color: kNeonScarlet, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: kSpaceLG,
          vertical: kSpaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
        ),
        textStyle: kButtonText.copyWith(color: kNeonScarlet),
      ),
    ),
    
    // Input decoration — Smoked Glass capsule style
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSmokedGlass.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kNeonScarlet, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kNeonError),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceMD,
      ),
      hintStyle: kBodyMedium.copyWith(color: kTextTertiary),
      labelStyle: kBodyMedium.copyWith(color: kTextSecondary),
      prefixIconColor: kTextTertiary,
      suffixIconColor: kTextTertiary,
    ),
    
    // Navigation bar — Floating glass style
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kDeepCrimson.withOpacity(0.2),
      elevation: 0,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kCaption.copyWith(
            color: kNeonScarlet,
            fontWeight: FontWeight.w700,
          );
        }
        return kCaption.copyWith(color: kTextTertiary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kNeonScarlet, size: 26);
        }
        return const IconThemeData(color: kTextTertiary, size: 24);
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
      color: kTextPrimary,
      size: 24,
    ),
    
    // Chips — Glass style
    chipTheme: ChipThemeData(
      backgroundColor: kSmokedGlass.withOpacity(0.3),
      selectedColor: kDeepCrimson.withOpacity(0.3),
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusFull),
      ),
      labelStyle: kCaption,
      padding: EdgeInsets.symmetric(
        horizontal: kSpaceSM,
        vertical: kSpaceXS,
      ),
    ),
    
    // Dialogs — Obsidian Glass card
    dialogTheme: DialogThemeData(
      backgroundColor: kObsidianSurface.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusXL),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
    ),
    
    // Bottom sheet — Glass style
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: kObsidianSurface.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kRadiusXL),
        ),
      ),
      dragHandleColor: kTextTertiary,
      dragHandleSize: const Size(36, 4),
    ),
    
    // Slider — Crimson accent
    sliderTheme: SliderThemeData(
      activeTrackColor: kNeonScarlet,
      inactiveTrackColor: Colors.white.withOpacity(0.1),
      thumbColor: kCoolChrome,
      overlayColor: kNeonScarlet.withOpacity(0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    
    // Progress indicator — Crimson
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: kNeonScarlet,
      linearTrackColor: Colors.white.withOpacity(0.1),
      circularTrackColor: Colors.white.withOpacity(0.1),
    ),
    
    // Switch — Crimson
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kCoolChrome;
        return kTextTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kDeepCrimson;
        }
        return Colors.white.withOpacity(0.1);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kDeepCrimson,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
      ),
    ),
  );
}
