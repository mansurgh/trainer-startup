// =============================================================================
// noir_theme.dart — Obsidian Glass Design System (Strict Monochrome)
// =============================================================================
// "Liquid Noir" aesthetic: 50 Shades of Grey, NO color hues
// Inspired by Dieter Rams, Apple Pro marketing, Carbon Fiber aesthetics
// Hierarchy through LUMINANCE, not color
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// NOIR PALETTE — Strict Grayscale (NO HUES)
// =============================================================================

/// True OLED Black — deepest black, battery efficient
const Color kNoirBlack = Color(0xFF000000);

/// Carbon — near-black for elevated surfaces
const Color kNoirCarbon = Color(0xFF0A0A0A);

/// Asphalt — dark grey surface
const Color kNoirAsphalt = Color(0xFF141414);

/// Graphite — card/container surface
const Color kNoirGraphite = Color(0xFF1C1C1E);

/// Steel — elevated element background
const Color kNoirSteel = Color(0xFF2C2C2E);

/// Slate — medium grey for borders
const Color kNoirSlate = Color(0xFF3A3A3C);

/// Fog — iOS system grey
const Color kNoirFog = Color(0xFF48484A);

/// Mist — secondary content grey
const Color kNoirMist = Color(0xFF636366);

/// Silver — tertiary/placeholder grey
const Color kNoirSilver = Color(0xFF8E8E93);

/// Cloud — subtle grey
const Color kNoirCloud = Color(0xFFAEAEB2);

/// Smoke — light grey
const Color kNoirSmoke = Color(0xFFC7C7CC);

/// Ash — very light grey
const Color kNoirAsh = Color(0xFFD1D1D6);

/// Snow — off-white
const Color kNoirSnow = Color(0xFFE5E5EA);

/// Frost — near-white
const Color kNoirFrost = Color(0xFFF2F2F7);

/// Pure White — maximum luminance
const Color kNoirWhite = Color(0xFFFFFFFF);

// =============================================================================
// SEMANTIC CONTENT HIERARCHY (By Luminance)
// =============================================================================

/// Content High — primary text, active elements (Pure White)
const Color kContentHigh = kNoirWhite;

/// Content Medium — secondary text, labels (Silver)
const Color kContentMedium = kNoirSilver;

/// Content Low — tertiary text, hints, placeholders (Mist)
const Color kContentLow = kNoirMist;

/// Content Disabled — disabled states (Fog with opacity)
const Color kContentDisabled = kNoirFog;

// =============================================================================
// SURFACE HIERARCHY
// =============================================================================

/// Surface Base — true black background
const Color kSurfaceBase = kNoirBlack;

/// Surface Elevated — slightly raised surface
const Color kSurfaceElevated = kNoirCarbon;

/// Surface Card — card background
const Color kSurfaceCard = kNoirGraphite;

/// Surface Glass — translucent glass (use with BackdropFilter)
Color kSurfaceGlass = Colors.white.withOpacity(0.05);

/// Surface Glass Heavy — more visible glass
Color kSurfaceGlassHeavy = Colors.white.withOpacity(0.08);

// =============================================================================
// BORDER HIERARCHY
// =============================================================================

/// Border Light — subtle separator
Color kBorderLight = Colors.white.withOpacity(0.06);

/// Border Medium — visible border
Color kBorderMedium = Colors.white.withOpacity(0.12);

/// Border Strong — prominent border
Color kBorderStrong = Colors.white.withOpacity(0.20);

/// Border Glow — active element border
Color kBorderGlow = Colors.white.withOpacity(0.40);

// =============================================================================
// GLOW EFFECTS (Luminance-based feedback)
// =============================================================================

/// White glow for active/success states
List<BoxShadow> kWhiteGlow({double intensity = 0.3, double blur = 20}) => [
  BoxShadow(
    color: Colors.white.withOpacity(intensity),
    blurRadius: blur,
    spreadRadius: -4,
    offset: Offset.zero,
  ),
];

/// Subtle ambient glow
List<BoxShadow> kAmbientGlow({double intensity = 0.15}) => [
  BoxShadow(
    color: Colors.white.withOpacity(intensity),
    blurRadius: 30,
    spreadRadius: -8,
    offset: Offset.zero,
  ),
];

/// Intense "success" glow (replaces green)
List<BoxShadow> kSuccessGlow = [
  BoxShadow(
    color: Colors.white.withOpacity(0.5),
    blurRadius: 24,
    spreadRadius: 0,
    offset: Offset.zero,
  ),
  BoxShadow(
    color: Colors.white.withOpacity(0.2),
    blurRadius: 50,
    spreadRadius: 5,
    offset: Offset.zero,
  ),
];

/// Deep shadow for depth
List<BoxShadow> kDeepShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.8),
    blurRadius: 30,
    spreadRadius: -5,
    offset: const Offset(0, 10),
  ),
];

// =============================================================================
// GRADIENTS — Light & Shadow Only
// =============================================================================

/// Rim light gradient (light catching glass edge)
const LinearGradient kRimLightGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x50FFFFFF), // 31% white at top-left
    Color(0x15FFFFFF), // 8% white
    Color(0x00000000), // transparent at bottom-right
  ],
  stops: [0.0, 0.4, 1.0],
);

/// Glass surface gradient (subtle luminance variation)
LinearGradient kGlassGradient({double opacity = 0.05}) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(opacity * 1.5),
    Colors.white.withOpacity(opacity * 0.3),
  ],
);

/// Vertical fade gradient (for charts, progress)
LinearGradient kVerticalFade({double topOpacity = 1.0}) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withOpacity(topOpacity),
    Colors.white.withOpacity(topOpacity * 0.3),
    Colors.transparent,
  ],
  stops: const [0.0, 0.5, 1.0],
);

/// Horizontal progress gradient
const LinearGradient kProgressGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFFFFFFFF),
    Color(0xCCFFFFFF),
  ],
);

/// Background gradient (pure black to carbon)
const LinearGradient kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    kNoirBlack,
    kNoirCarbon,
    kNoirBlack,
  ],
  stops: [0.0, 0.5, 1.0],
);

// =============================================================================
// BLUR TOKENS
// =============================================================================

const double kBlurLight = 15.0;
const double kBlurMedium = 25.0;
const double kBlurHeavy = 40.0;
const double kBlurXHeavy = 60.0;

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
// RADIUS TOKENS
// =============================================================================

const double kRadiusXS = 8.0;
const double kRadiusSM = 12.0;
const double kRadiusMD = 16.0;
const double kRadiusLG = 24.0;
const double kRadiusXL = 32.0;
const double kRadiusFull = 999.0;

// =============================================================================
// ANIMATION TOKENS
// =============================================================================

const Duration kDurationFast = Duration(milliseconds: 150);
const Duration kDurationMedium = Duration(milliseconds: 250);
const Duration kDurationSlow = Duration(milliseconds: 400);

const Curve kCurveEaseOut = Curves.easeOutCubic;
const Curve kCurveEaseIn = Curves.easeInCubic;
const Curve kCurveSpring = Curves.easeOutBack;

// =============================================================================
// TYPOGRAPHY — The Hero (No color = Typography carries weight)
// =============================================================================

/// Giant stat number (massive, bold)
TextStyle get kNoirDisplayGiant => GoogleFonts.manrope(
  fontSize: 80,
  fontWeight: FontWeight.w700,
  height: 0.9,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Large stat number
TextStyle get kNoirDisplayLarge => GoogleFonts.manrope(
  fontSize: 56,
  fontWeight: FontWeight.w600,
  height: 0.95,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Medium display
TextStyle get kNoirDisplayMedium => GoogleFonts.manrope(
  fontSize: 40,
  fontWeight: FontWeight.w600,
  height: 1.0,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Small display
TextStyle get kNoirDisplaySmall => GoogleFonts.manrope(
  fontSize: 32,
  fontWeight: FontWeight.w600,
  height: 1.1,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Title Large — bold, tight tracking
TextStyle get kNoirTitleLarge => GoogleFonts.manrope(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  height: 1.1,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Title Medium
TextStyle get kNoirTitleMedium => GoogleFonts.manrope(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Title Small
TextStyle get kNoirTitleSmall => GoogleFonts.manrope(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.25,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Headline
TextStyle get kNoirHeadline => GoogleFonts.manrope(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Body Large
TextStyle get kNoirBodyLarge => GoogleFonts.manrope(
  fontSize: 17,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0,
  color: kContentHigh,
);

/// Body Medium (secondary text)
TextStyle get kNoirBodyMedium => GoogleFonts.manrope(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0.1,
  color: kContentMedium,
);

/// Body Small (tertiary text)
TextStyle get kNoirBodySmall => GoogleFonts.manrope(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.4,
  letterSpacing: 0.1,
  color: kContentLow,
);

/// Caption
TextStyle get kNoirCaption => GoogleFonts.manrope(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.3,
  letterSpacing: 0.2,
  color: kContentMedium,
);

/// Overline (labels, tags)
TextStyle get kNoirOverline => GoogleFonts.manrope(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: 1.0,
  color: kContentLow,
);

/// Button text
TextStyle get kNoirButton => GoogleFonts.manrope(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: 0.2,
  color: kContentHigh,
);

// =============================================================================
// APPCOLORS — Semantic Color Class (Monochrome)
// =============================================================================

/// Strict monochrome palette with semantic naming by luminance
class AppColors {
  AppColors._();

  // === CONTENT (Text & Icons) ===
  static const Color contentHigh = kContentHigh;        // Primary: White
  static const Color contentMedium = kContentMedium;    // Secondary: Silver
  static const Color contentLow = kContentLow;          // Tertiary: Mist
  static const Color contentDisabled = kContentDisabled; // Disabled: Fog

  // === SURFACES ===
  static const Color surfaceBase = kSurfaceBase;        // Background: Black
  static const Color surfaceElevated = kSurfaceElevated; // Elevated: Carbon
  static const Color surfaceCard = kSurfaceCard;        // Cards: Graphite
  static Color surfaceGlass = kSurfaceGlass;            // Glass: 5% White
  static Color surfaceGlassHeavy = kSurfaceGlassHeavy;  // Heavy Glass: 8%

  // === BORDERS ===
  static Color borderLight = kBorderLight;              // Subtle: 6%
  static Color borderMedium = kBorderMedium;            // Visible: 12%
  static Color borderStrong = kBorderStrong;            // Prominent: 20%
  static Color borderGlow = kBorderGlow;                // Active: 40%

  // === GREYS (Full spectrum) ===
  static const Color black = kNoirBlack;
  static const Color carbon = kNoirCarbon;
  static const Color asphalt = kNoirAsphalt;
  static const Color graphite = kNoirGraphite;
  static const Color steel = kNoirSteel;
  static const Color slate = kNoirSlate;
  static const Color fog = kNoirFog;
  static const Color mist = kNoirMist;
  static const Color silver = kNoirSilver;
  static const Color cloud = kNoirCloud;
  static const Color smoke = kNoirSmoke;
  static const Color ash = kNoirAsh;
  static const Color snow = kNoirSnow;
  static const Color frost = kNoirFrost;
  static const Color white = kNoirWhite;

  // === SEMANTIC STATES (No color! Only luminance) ===
  /// Success: Bright white glow + filled icon
  static Color successGlow = Colors.white.withOpacity(0.5);
  
  /// Error: Darker surface + visual cue (shake)
  /// If absolutely critical, use desaturated grey-red
  static const Color errorSurface = Color(0xFF2A2020);
  
  /// Warning: Medium grey highlight
  static const Color warningSurface = kNoirSteel;
  
  /// Info: Standard white
  static const Color info = kContentHigh;

  // === LEGACY ALIASES (Backward compatibility) ===
  static const Color primary = kNoirWhite;
  static const Color secondary = kNoirSilver;
  static const Color background = kNoirBlack;
  static const Color surface = kNoirGraphite;
  static const Color onPrimary = kNoirBlack;
  static const Color onSurface = kNoirWhite;
}

// =============================================================================
// NOIR THEME EXTENSION
// =============================================================================

@immutable
class NoirThemeExtension extends ThemeExtension<NoirThemeExtension> {
  const NoirThemeExtension({
    required this.contentHigh,
    required this.contentMedium,
    required this.contentLow,
    required this.surfaceBase,
    required this.surfaceCard,
    required this.borderLight,
    required this.blurSigma,
  });

  final Color contentHigh;
  final Color contentMedium;
  final Color contentLow;
  final Color surfaceBase;
  final Color surfaceCard;
  final Color borderLight;
  final double blurSigma;

  @override
  NoirThemeExtension copyWith({
    Color? contentHigh,
    Color? contentMedium,
    Color? contentLow,
    Color? surfaceBase,
    Color? surfaceCard,
    Color? borderLight,
    double? blurSigma,
  }) {
    return NoirThemeExtension(
      contentHigh: contentHigh ?? this.contentHigh,
      contentMedium: contentMedium ?? this.contentMedium,
      contentLow: contentLow ?? this.contentLow,
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      borderLight: borderLight ?? this.borderLight,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  NoirThemeExtension lerp(
    covariant ThemeExtension<NoirThemeExtension>? other,
    double t,
  ) {
    if (other is! NoirThemeExtension) return this;
    return NoirThemeExtension(
      contentHigh: Color.lerp(contentHigh, other.contentHigh, t)!,
      contentMedium: Color.lerp(contentMedium, other.contentMedium, t)!,
      contentLow: Color.lerp(contentLow, other.contentLow, t)!,
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
    );
  }

  static NoirThemeExtension noir = NoirThemeExtension(
    contentHigh: kContentHigh,
    contentMedium: kContentMedium,
    contentLow: kContentLow,
    surfaceBase: kSurfaceBase,
    surfaceCard: kSurfaceCard,
    borderLight: kBorderLight,
    blurSigma: kBlurMedium,
  );
}

// =============================================================================
// CONTEXT EXTENSION
// =============================================================================

extension NoirThemeContext on BuildContext {
  NoirThemeExtension get noir =>
      Theme.of(this).extension<NoirThemeExtension>() ?? NoirThemeExtension.noir;
}

// =============================================================================
// BUILD NOIR GLASS THEME
// =============================================================================

ThemeData buildNoirGlassTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  final colorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: kNoirWhite,
    onPrimary: kNoirBlack,
    secondary: kNoirSilver,
    onSecondary: kNoirBlack,
    surface: kNoirGraphite,
    onSurface: kNoirWhite,
    error: kNoirSilver, // No red! Grey for errors
    onError: kNoirBlack,
  );

  // Apply Manrope globally with bodyColor/displayColor for full coverage
  final baseTextTheme = GoogleFonts.manropeTextTheme(base.textTheme);
  final textTheme = baseTextTheme.apply(
    bodyColor: kContentHigh,
    displayColor: kContentHigh,
  ).copyWith(
    displayLarge: kNoirDisplayGiant,
    displayMedium: kNoirDisplayLarge,
    displaySmall: kNoirDisplayMedium,
    headlineLarge: kNoirTitleLarge,
    headlineMedium: kNoirTitleMedium,
    headlineSmall: kNoirTitleSmall,
    titleLarge: kNoirHeadline,
    titleMedium: kNoirBodyLarge.copyWith(fontWeight: FontWeight.w600),
    titleSmall: kNoirBodyMedium.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: kNoirBodyLarge,
    bodyMedium: kNoirBodyMedium,
    bodySmall: kNoirBodySmall,
    labelLarge: kNoirCaption.copyWith(fontWeight: FontWeight.w600),
    labelMedium: kNoirCaption,
    labelSmall: kNoirOverline,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kNoirBlack,
    canvasColor: kNoirBlack,
    textTheme: textTheme,
    extensions: [NoirThemeExtension.noir],

    // AppBar — transparent
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: kNoirHeadline,
      iconTheme: const IconThemeData(color: kContentHigh, size: 24),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // Cards — Glass
    cardTheme: CardThemeData(
      color: kSurfaceGlass,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLG),
        side: BorderSide(color: kBorderLight),
      ),
      margin: EdgeInsets.zero,
    ),

    // Primary Button — Solid White, Black Text
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kNoirWhite,
        foregroundColor: kNoirBlack,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
        ),
        textStyle: kNoirButton.copyWith(color: kNoirBlack),
      ),
    ),

    // Secondary Button — Glass with border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kNoirWhite,
        side: BorderSide(color: kBorderMedium, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
        ),
        textStyle: kNoirButton,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kNoirWhite,
        textStyle: kNoirButton,
      ),
    ),

    // Input — Glass style
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceGlass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: kBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: kBorderGlow, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: kNoirSlate),
      ),
      hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
      labelStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
      prefixIconColor: kContentLow,
      suffixIconColor: kContentLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Navigation Bar — Floating glass island
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: Colors.white.withOpacity(0.1),
      elevation: 0,
      height: 70,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kNoirCaption.copyWith(color: kNoirWhite, fontWeight: FontWeight.w600);
        }
        return kNoirCaption.copyWith(color: kNoirSilver);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kNoirWhite, size: 26);
        }
        return IconThemeData(color: kNoirSilver.withOpacity(0.5), size: 24);
      }),
    ),

    // Dividers
    dividerTheme: DividerThemeData(
      color: kBorderLight,
      thickness: 1,
      space: 1,
    ),

    // Icons
    iconTheme: const IconThemeData(color: kContentHigh, size: 24),

    // Slider — White
    sliderTheme: SliderThemeData(
      activeTrackColor: kNoirWhite,
      inactiveTrackColor: kNoirSlate,
      thumbColor: kNoirWhite,
      overlayColor: Colors.white.withOpacity(0.1),
      trackHeight: 4,
    ),

    // Progress — White
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: kNoirWhite,
      linearTrackColor: kNoirSlate,
      circularTrackColor: kNoirSlate,
    ),

    // Switch — White
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kNoirWhite;
        return kNoirMist;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kNoirSlate;
        return kNoirSteel;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // Chips — Glass
    chipTheme: ChipThemeData(
      backgroundColor: kSurfaceGlass,
      selectedColor: Colors.white.withOpacity(0.15),
      side: BorderSide(color: kBorderLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusFull),
      ),
      labelStyle: kNoirCaption,
    ),

    // Dialog — Glass
    dialogTheme: DialogThemeData(
      backgroundColor: kNoirGraphite.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusXL),
        side: BorderSide(color: kBorderLight),
      ),
    ),

    // Bottom Sheet — Glass
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: kNoirGraphite.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      dragHandleColor: kNoirSlate,
      dragHandleSize: const Size(36, 4),
    ),

    // FAB — White
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kNoirWhite,
      foregroundColor: kNoirBlack,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
      ),
    ),

    // Checkbox — Strict Monochrome (NO BLUE)
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kNoirWhite;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(kNoirBlack),
      side: BorderSide(color: kContentMedium, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Radio — Strict Monochrome (NO BLUE)
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kNoirWhite;
        return kContentMedium;
      }),
    ),
  );
}
