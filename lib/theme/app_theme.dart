// =============================================================================
// app_theme.dart — Obsidian Glass Theme System (Monochrome)
// =============================================================================
// "Liquid Noir" Design System: Pure Black & White
// Zero color hues — only luminance and grey scale
// Inspired by Dieter Rams, Apple Pro, Carbon Fiber aesthetics
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// CONSTANTS — Obsidian Noir Monochrome Palette (NO HUES!)
// =============================================================================

/// True OLED Black — saves battery on OLED screens, creates depth
const Color kOledBlack = Color(0xFF000000);

/// Charcoal — elevated background
const Color kMidnightBlue = Color(0xFF0A0A0A);

/// Obsidian Surface — elevated dark
const Color kDeepSpace = Color(0xFF121212);

/// Smoked Glass — card/container background
const Color kNebulaSurface = Color(0xFF1A1A1A);

/// Grey Border — subtle edge
const Color kLiquidBorder = Color(0xFF2A2A2A);

/// Pure White — primary accent (was Electric Blue)
const Color kElectricBlue = Color(0xFFFFFFFF);

/// Light Grey — secondary (was Royal Blue)
const Color kRoyalBlue = Color(0xFFCCCCCC);

/// Pure White — accent end (was Neon Cyan)
const Color kNeonCyan = Color(0xFFFFFFFF);

/// Soft White — glow (was Ice Cyan)
const Color kIceCyan = Color(0xFFE0E0E0);

/// Medium Grey — secondary accent (was Deep Violet)
const Color kDeepViolet = Color(0xFF808080);

/// Cool Chrome — metallic text
const Color kCoolWhite = Color(0xFFE0E0E0);

/// Success — White (luminance-based, not green)
const Color kNeonSuccess = Color(0xFFFFFFFF);

/// Error — Medium Grey (luminance-based, not red)
const Color kNeonError = Color(0xFF909090);

/// Warning — Light Grey
const Color kNeonWarning = Color(0xFFB0B0B0);

/// Info — White
const Color kNeonInfo = Color(0xFFFFFFFF);

// --- Legacy aliases for backward compatibility ---
const Color kObsidianSurface = kDeepSpace;
const Color kObsidianBorder = kLiquidBorder;
const Color kElectricAmberStart = kElectricBlue;
const Color kElectricAmberEnd = kNeonCyan;
const Color kSteelBlue = kRoyalBlue;
const Color kSuccessGreen = kNeonSuccess;
const Color kErrorRed = kNeonError;
const Color kWarningAmber = kNeonWarning;
const Color kInfoCyan = kNeonCyan;

// =============================================================================
// TEXT COLORS — Pure Grey Scale (No Warm/Cool Tint)
// =============================================================================

/// Primary text — pure white for maximum contrast
const Color kTextPrimary = Color(0xFFFFFFFF);

/// Secondary text — neutral grey for less emphasis
const Color kTextSecondary = Color(0xFFB0B0B0);

/// Tertiary text — subtle grey for hints/placeholders
const Color kTextTertiary = Color(0xFF707070);

/// Disabled text — very low opacity grey
const Color kTextDisabled = Color(0xFF404040);

// =============================================================================
// GRADIENTS — Monochrome Light System (White → Transparent)
// =============================================================================

/// Primary gradient — White to White (monochrome)
const LinearGradient kElectricAmberGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFFFFFFF), Color(0xFFCCCCCC)],
);

/// Primary gradient alias
const LinearGradient kLiquidPrimaryGradient = kElectricAmberGradient;

/// Secondary gradient — Grey scale
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

/// Legacy alias
RadialGradient kAmberGlowGradient({double opacity = 0.25}) => kBlueGlowGradient(opacity: opacity);

/// Dark background gradient — pure black
const LinearGradient kDarkBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0A0A0A),
    kOledBlack,
    Color(0xFF050505),
  ],
  stops: [0.0, 0.6, 1.0],
);

// =============================================================================
// GLASSMORPHISM 4.0 — iOS 26 Liquid Glass Effects
// =============================================================================

/// Light blur — subtle frosted effect
const double kGlassBlurLight = 12.0;

/// Standard glass blur sigma (enhanced for Liquid Glass)
const double kGlassBlurSigma = 20.0;

/// Heavy glass blur for modals
const double kGlassBlurHeavy = 40.0;

/// Extra heavy blur for full overlays
const double kGlassBlurXHeavy = 60.0;

/// Glass surface color with transparency (lower for cleaner look)
const Color kGlassSurface = Color(0x14FFFFFF); // 8% white

/// Glass border color (rim light effect)
const Color kGlassBorder = Color(0x1AFFFFFF); // 10% white

/// Glass opacity levels
const double kGlassOpacityLight = 0.05;
const double kGlassOpacityMedium = 0.08;
const double kGlassOpacityHeavy = 0.12;

// =============================================================================
// TYPOGRAPHY TOKENS — Premium Number Display System
// =============================================================================

/// Giant thin numbers — for stats, metrics, scores (Thin/Light weight)
TextStyle get kGiantNumber => GoogleFonts.manrope(
  fontSize: 72,
  fontWeight: FontWeight.w300, // Light
  height: 1.0,
  letterSpacing: 0,
  color: kTextPrimary,
);

/// Large thin numbers — secondary stats
TextStyle get kLargeNumber => GoogleFonts.manrope(
  fontSize: 48,
  fontWeight: FontWeight.w300, // Light
  height: 1.1,
  letterSpacing: 0,
  color: kTextPrimary,
);

/// Medium numbers — tertiary stats
TextStyle get kMediumNumber => GoogleFonts.manrope(
  fontSize: 32,
  fontWeight: FontWeight.w400,
  height: 1.2,
  letterSpacing: 0,
  color: kTextPrimary,
);

/// Dense heading — bold, compact titles
TextStyle get kDenseHeading => GoogleFonts.manrope(
  fontSize: 24,
  fontWeight: FontWeight.w800, // ExtraBold
  height: 1.1,
  letterSpacing: 0,
  color: kTextPrimary,
);

/// Dense subheading
TextStyle get kDenseSubheading => GoogleFonts.manrope(
  fontSize: 18,
  fontWeight: FontWeight.w700, // Bold
  height: 1.2,
  letterSpacing: 0,
  color: kTextPrimary,
);

/// Body text
TextStyle get kBodyText => GoogleFonts.manrope(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.1,
  color: kTextSecondary,
);

/// Caption text
TextStyle get kCaptionText => GoogleFonts.manrope(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.4,
  letterSpacing: 0.2,
  color: kTextTertiary,
);

/// Overline text — small labels
TextStyle get kOverlineText => GoogleFonts.manrope(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 1.0,
  color: kTextTertiary,
);

// =============================================================================
// SPACING TOKENS
// =============================================================================

const double kSpaceXS = 4.0;
const double kSpaceSM = 8.0;
const double kSpaceMD = 16.0;
const double kSpaceLG = 24.0;
const double kSpaceXL = 32.0;
const double kSpaceXXL = 48.0;

// =============================================================================
// RADIUS TOKENS — Premium iOS-style Smooth Corners
// =============================================================================

const double kRadiusSM = 12.0;  // Increased from 8
const double kRadiusMD = 16.0;  // Increased from 12
const double kRadiusLG = 20.0;  // Increased from 16
const double kRadiusXL = 24.0;  // Same, already premium
const double kRadiusXXL = 32.0; // New: Extra large for modals
const double kRadiusFull = 999.0;

// =============================================================================
// ANIMATION TOKENS
// =============================================================================

const Duration kDurationFast = Duration(milliseconds: 150);
const Duration kDurationMedium = Duration(milliseconds: 300);
const Duration kDurationSlow = Duration(milliseconds: 500);
const Duration kDurationXSlow = Duration(milliseconds: 800);

const Curve kCurveEaseOut = Curves.easeOutCubic;
const Curve kCurveEaseIn = Curves.easeInCubic;
const Curve kCurveEaseInOut = Curves.easeInOutCubic;
const Curve kCurveBounce = Curves.elasticOut;

// =============================================================================
// THEME EXTENSION — IndustrialThemeExtension
// =============================================================================

/// Custom theme extension for Premium Dark Industrial design system.
/// Access via `Theme.of(context).extension<IndustrialThemeExtension>()`.
@immutable
class IndustrialThemeExtension extends ThemeExtension<IndustrialThemeExtension> {
  const IndustrialThemeExtension({
    required this.oledBlack,
    required this.obsidianSurface,
    required this.obsidianBorder,
    required this.electricAmberStart,
    required this.electricAmberEnd,
    required this.glassSurface,
    required this.glassBorder,
    required this.glassBlurSigma,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
  });

  final Color oledBlack;
  final Color obsidianSurface;
  final Color obsidianBorder;
  final Color electricAmberStart;
  final Color electricAmberEnd;
  final Color glassSurface;
  final Color glassBorder;
  final double glassBlurSigma;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;

  /// Electric Amber gradient for progress indicators
  LinearGradient get amberGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [electricAmberStart, electricAmberEnd],
  );

  /// Radial glow effect
  RadialGradient amberGlow({double opacity = 0.3}) => RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      electricAmberStart.withOpacity(opacity),
      Colors.transparent,
    ],
  );

  @override
  IndustrialThemeExtension copyWith({
    Color? oledBlack,
    Color? obsidianSurface,
    Color? obsidianBorder,
    Color? electricAmberStart,
    Color? electricAmberEnd,
    Color? glassSurface,
    Color? glassBorder,
    double? glassBlurSigma,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
  }) {
    return IndustrialThemeExtension(
      oledBlack: oledBlack ?? this.oledBlack,
      obsidianSurface: obsidianSurface ?? this.obsidianSurface,
      obsidianBorder: obsidianBorder ?? this.obsidianBorder,
      electricAmberStart: electricAmberStart ?? this.electricAmberStart,
      electricAmberEnd: electricAmberEnd ?? this.electricAmberEnd,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      warningColor: warningColor ?? this.warningColor,
    );
  }

  @override
  IndustrialThemeExtension lerp(
    covariant ThemeExtension<IndustrialThemeExtension>? other,
    double t,
  ) {
    if (other is! IndustrialThemeExtension) return this;
    return IndustrialThemeExtension(
      oledBlack: Color.lerp(oledBlack, other.oledBlack, t)!,
      obsidianSurface: Color.lerp(obsidianSurface, other.obsidianSurface, t)!,
      obsidianBorder: Color.lerp(obsidianBorder, other.obsidianBorder, t)!,
      electricAmberStart: Color.lerp(electricAmberStart, other.electricAmberStart, t)!,
      electricAmberEnd: Color.lerp(electricAmberEnd, other.electricAmberEnd, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBlurSigma: lerpDouble(glassBlurSigma, other.glassBlurSigma, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
    );
  }

  /// Default dark industrial theme
  static const IndustrialThemeExtension dark = IndustrialThemeExtension(
    oledBlack: kOledBlack,
    obsidianSurface: kObsidianSurface,
    obsidianBorder: kObsidianBorder,
    electricAmberStart: kElectricAmberStart,
    electricAmberEnd: kElectricAmberEnd,
    glassSurface: kGlassSurface,
    glassBorder: kGlassBorder,
    glassBlurSigma: kGlassBlurSigma,
    textPrimary: kTextPrimary,
    textSecondary: kTextSecondary,
    textTertiary: kTextTertiary,
    successColor: kSuccessGreen,
    errorColor: kErrorRed,
    warningColor: kWarningAmber,
  );
}

// =============================================================================
// HELPER EXTENSION — Easy Access to IndustrialTheme
// =============================================================================

extension IndustrialThemeContext on BuildContext {
  /// Quick access to Industrial theme extension
  IndustrialThemeExtension get industrial =>
      Theme.of(this).extension<IndustrialThemeExtension>() ??
      IndustrialThemeExtension.dark;
}

// =============================================================================
// BUILD PREMIUM THEME — Full ThemeData Construction
// =============================================================================

/// Builds the complete Premium Dark Industrial ThemeData.
/// Usage: `MaterialApp(theme: buildPremiumDarkTheme())`
ThemeData buildPremiumDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kElectricAmberStart,
    brightness: Brightness.dark,
    surface: kObsidianSurface,
    primary: kElectricAmberStart,
    secondary: kElectricAmberEnd,
    error: kErrorRed,
    onSurface: kTextPrimary,
    onPrimary: kOledBlack,
  );

  // Build text theme with premium typography (Manrope - Big Tech 2025 aesthetic)
  final baseTextTheme = GoogleFonts.manropeTextTheme(base.textTheme);
  final textTheme = baseTextTheme.apply(
    bodyColor: kTextPrimary,
    displayColor: kTextPrimary,
  ).copyWith(
    // Display — Giant thin numbers
    displayLarge: kGiantNumber,
    displayMedium: kLargeNumber,
    displaySmall: kMediumNumber,
    // Headlines — Dense bold
    headlineLarge: kDenseHeading,
    headlineMedium: kDenseSubheading,
    headlineSmall: kDenseSubheading.copyWith(fontSize: 16),
    // Titles
    titleLarge: kDenseSubheading,
    titleMedium: kBodyText.copyWith(fontWeight: FontWeight.w600),
    titleSmall: kCaptionText.copyWith(fontWeight: FontWeight.w600),
    // Body
    bodyLarge: kBodyText,
    bodyMedium: kBodyText.copyWith(fontSize: 14),
    bodySmall: kCaptionText,
    // Labels
    labelLarge: kCaptionText.copyWith(fontWeight: FontWeight.w600),
    labelMedium: kCaptionText,
    labelSmall: kOverlineText,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kOledBlack,
    canvasColor: kOledBlack,
    textTheme: textTheme,
    
    // Extensions
    extensions: const [IndustrialThemeExtension.dark],
    
    // AppBar — transparent, floating
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: kDenseHeading.copyWith(fontSize: 18),
      iconTheme: const IconThemeData(color: kTextPrimary, size: 24),
    ),
    
    // Cards — Obsidian with subtle border
    cardTheme: CardThemeData(
      color: kObsidianSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLG),
        side: const BorderSide(color: kObsidianBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // Elevated buttons — Amber gradient style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kObsidianSurface,
        foregroundColor: kTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: kSpaceLG, vertical: kSpaceMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          side: const BorderSide(color: kObsidianBorder),
        ),
        textStyle: kBodyText.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    
    // Filled buttons — Primary amber
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kElectricAmberStart,
        foregroundColor: kOledBlack,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: kSpaceLG, vertical: kSpaceMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
        ),
        textStyle: kBodyText.copyWith(
          fontWeight: FontWeight.w700,
          color: kOledBlack,
        ),
      ),
    ),
    
    // Outlined buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kElectricAmberStart,
        side: const BorderSide(color: kElectricAmberStart, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: kSpaceLG, vertical: kSpaceMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
        ),
        textStyle: kBodyText.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kObsidianSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kObsidianBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kObsidianBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kElectricAmberStart, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kErrorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceMD),
      hintStyle: kBodyText.copyWith(color: kTextTertiary),
      labelStyle: kBodyText.copyWith(color: kTextSecondary),
    ),
    
    // Bottom navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kOledBlack.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      indicatorColor: kElectricAmberStart.withOpacity(0.15),
      elevation: 0,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kCaptionText.copyWith(
            color: kElectricAmberStart,
            fontWeight: FontWeight.w700,
          );
        }
        return kCaptionText.copyWith(color: kTextTertiary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kElectricAmberStart, size: 26);
        }
        return const IconThemeData(color: kTextTertiary, size: 24);
      }),
    ),
    
    // Dividers
    dividerTheme: const DividerThemeData(
      color: kObsidianBorder,
      thickness: 1,
      space: 1,
    ),
    
    // Icons
    iconTheme: const IconThemeData(
      color: kTextPrimary,
      size: 24,
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: kObsidianSurface,
      selectedColor: kElectricAmberStart.withOpacity(0.2),
      side: const BorderSide(color: kObsidianBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusFull),
      ),
      labelStyle: kCaptionText,
      padding: const EdgeInsets.symmetric(horizontal: kSpaceSM, vertical: kSpaceXS),
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: kObsidianSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusXL),
        side: const BorderSide(color: kObsidianBorder),
      ),
    ),
    
    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kObsidianSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      dragHandleColor: kTextTertiary,
      dragHandleSize: Size(36, 4),
    ),
    
    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: kElectricAmberStart,
      inactiveTrackColor: kObsidianBorder,
      thumbColor: kElectricAmberStart,
      overlayColor: kElectricAmberStart.withOpacity(0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    
    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kElectricAmberStart,
      linearTrackColor: kObsidianBorder,
      circularTrackColor: kObsidianBorder,
    ),
    
    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kElectricAmberStart;
        return kTextTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kElectricAmberStart.withOpacity(0.3);
        }
        return kObsidianBorder;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}

// =============================================================================
// GLASSMORPHISM WIDGETS — Premium Frosted Glass Components
// =============================================================================

/// Premium glassmorphic card with blur effect.
/// Use over content (images, gradients) for best visual effect.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(kSpaceMD),
    this.borderRadius = kRadiusLG,
    this.blurSigma = kGlassBlurSigma,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.industrial;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? theme.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.glassSurface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Obsidian card — solid dark surface with subtle border
class ObsidianCard extends StatelessWidget {
  const ObsidianCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(kSpaceMD),
    this.borderRadius = kRadiusLG,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.industrial;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: theme.electricAmberStart.withOpacity(0.1),
        highlightColor: theme.electricAmberStart.withOpacity(0.05),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.obsidianSurface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: theme.obsidianBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Amber gradient text for emphasis
class AmberGradientText extends StatelessWidget {
  const AmberGradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = context.industrial;
    
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [theme.electricAmberStart, theme.electricAmberEnd],
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? kDenseHeading).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

/// Glowing text with shadow effect
class GlowingText extends StatelessWidget {
  const GlowingText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.glowRadius = 8.0,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Color? glowColor;
  final double glowRadius;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = context.industrial;
    final effectiveGlowColor = glowColor ?? theme.electricAmberStart;
    
    return Text(
      text,
      style: (style ?? kDenseHeading).copyWith(
        shadows: [
          Shadow(
            color: effectiveGlowColor.withOpacity(0.6),
            blurRadius: glowRadius,
          ),
          Shadow(
            color: effectiveGlowColor.withOpacity(0.3),
            blurRadius: glowRadius * 2,
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

// =============================================================================
// GRADIENT PROGRESS INDICATOR — Electric Amber Fill
// =============================================================================

/// Linear progress bar with Electric Amber gradient
class AmberProgressBar extends StatelessWidget {
  const AmberProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.borderRadius = kRadiusFull,
    this.backgroundColor,
    this.showGlow = true,
  });

  /// Progress value from 0.0 to 1.0
  final double value;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final theme = context.industrial;
    final clampedValue = value.clamp(0.0, 1.0);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.obsidianBorder,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Progress fill
              AnimatedContainer(
                duration: kDurationMedium,
                curve: kCurveEaseOut,
                width: constraints.maxWidth * clampedValue,
                decoration: BoxDecoration(
                  gradient: theme.amberGradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: showGlow ? [
                    BoxShadow(
                      color: theme.electricAmberStart.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ] : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
