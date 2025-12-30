import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Typography System для PulseFit Pro
/// Space Grotesk - для заголовков (геометрический, современный)
/// Inter - для body текста (отличная читаемость на русском/английском)
class PremiumTypography {
  // ===== HEADLINE STYLES =====
  
  /// Hero заголовок - для splash экранов и ключевых моментов
  static TextStyle heroHeadline(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -1.5,
      color: Colors.white,
    );
  }
  
  /// Главный заголовок экрана
  static TextStyle h1(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.8,
      color: Colors.white,
    );
  }
  
  /// Заголовок секции
  static TextStyle h2(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.5,
      color: Colors.white,
    );
  }
  
  /// Подзаголовок
  static TextStyle h3(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: -0.3,
      color: Colors.white,
    );
  }
  
  /// Заголовок карточки
  static TextStyle cardTitle(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.2,
      color: Colors.white,
    );
  }
  
  // ===== BODY STYLES =====
  
  /// Основной текст - большой
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.1,
      color: Colors.white,
    );
  }
  
  /// Основной текст - стандартный
  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.1,
      color: Colors.white.withOpacity(0.85),
    );
  }
  
  /// Основной текст - мелкий
  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: 0.1,
      color: Colors.white.withOpacity(0.7),
    );
  }
  
  // ===== ACCENT STYLES =====
  
  /// Числовые значения (для статистики)
  static TextStyle statNumber(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: -1.0,
      color: Colors.white,
    );
  }
  
  /// Большие числа (прогресс, проценты)
  static TextStyle bigNumber(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: -2.0,
      color: Colors.white,
    );
  }
  
  /// Лейбл для статистики
  static TextStyle statLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.5,
      color: Colors.white.withOpacity(0.5),
    );
  }
  
  /// Overline текст (UPPERCASE метки)
  static TextStyle overline(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 1.2,
      color: Colors.white.withOpacity(0.5),
    );
  }
  
  // ===== BUTTON STYLES =====
  
  /// Основная кнопка
  static TextStyle buttonPrimary(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.3,
      color: Colors.black,
    );
  }
  
  /// Вторичная кнопка
  static TextStyle buttonSecondary(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: Colors.white,
    );
  }
  
  /// Текстовая кнопка
  static TextStyle buttonText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: Colors.white.withOpacity(0.7),
    );
  }
  
  // ===== SPECIAL STYLES =====
  
  /// Для мотивационных цитат
  static TextStyle quote(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: -0.3,
      fontStyle: FontStyle.italic,
      color: Colors.white.withOpacity(0.9),
    );
  }
  
  /// Для таймера/countdown
  static TextStyle timer(BuildContext context) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: -2.0,
      color: Colors.white,
    );
  }
  
  /// Для badges и tags
  static TextStyle badge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0.5,
      color: Colors.white,
    );
  }
  
  /// Для навбара
  static TextStyle navItem(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.3,
      color: Colors.white.withOpacity(0.7),
    );
  }
  
  /// Активный элемент навбара
  static TextStyle navItemActive(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.3,
      color: Colors.white,
    );
  }
}

/// Extension для удобного применения стилей
extension PremiumTextExtension on Text {
  Text withPremiumStyle(TextStyle Function(BuildContext) styleBuilder, BuildContext context) {
    return Text(
      data ?? '',
      style: styleBuilder(context).merge(style),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
