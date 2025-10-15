import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'design_tokens.dart';

/// Premium компоненты для Trainer App
/// Следует референсам: стеклянные панели, анимации, премиум UX
class PremiumComponents {
  
  // ===== GLASS COMPONENTS =====
  
  /// Стеклянная карточка с размытием и обводкой
  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: DesignTokens.glassBlur, sigmaY: DesignTokens.glassBlur),
        child: Container(
          decoration: BoxDecoration(
            gradient: DesignTokens.cardGradient,
            borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLarge),
            border: Border.all(
              color: borderColor ?? DesignTokens.glassBorder,
              width: 1,
            ),
            boxShadow: DesignTokens.shadowSoft,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLarge),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(DesignTokens.space16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Стеклянная кнопка с акцентом
  static Widget glassButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? accentColor,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
    bool isPrimary = false,
  }) {
    final accent = accentColor ?? DesignTokens.primaryAccent;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: DesignTokens.buttonHeightLarge,
          decoration: BoxDecoration(
            gradient: isPrimary 
              ? DesignTokens.primaryGradient
              : DesignTokens.cardGradient,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
              color: isPrimary ? accent.withOpacity(0.5) : DesignTokens.glassBorder,
              width: 1,
            ),
            boxShadow: isPrimary 
              ? DesignTokens.glowShadow(accent)
              : DesignTokens.shadowSoft,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space24,
                  vertical: DesignTokens.space12,
                ),
                child: Center(
                  child: isLoading 
                    ? SizedBox(
                        width: DesignTokens.iconMedium,
                        height: DesignTokens.iconMedium,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            isPrimary ? Colors.white : accent,
                          ),
                        ),
                      )
                    : child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Верхняя панель со стеклянным эффектом
  static Widget glassAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool pinned = true,
  }) {
    return SliverAppBar(
      pinned: pinned,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      actions: actions,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DesignTokens.glassOverlay,
                  DesignTokens.glassOverlay.withOpacity(0.5),
                ],
              ),
              border: const Border(
                bottom: BorderSide(
                  color: DesignTokens.glassBorder,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: DesignTokens.h2,
      ),
    );
  }
  
  // ===== ACTIVITY HEATMAP =====
  
  /// GitHub-style activity heatmap
  static Widget activityHeatmap({
    required Map<DateTime, int> activities,
    required int maxLevel,
    double cellSize = 12.0,
    double spacing = 2.0,
  }) {
    // Генерируем последние 12 недель
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 84)); // 12 недель
    
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Активность',
            style: DesignTokens.h3,
          ),
          const SizedBox(height: DesignTokens.space16),
          
          // Дни недели
          Row(
            children: [
              const SizedBox(width: 32), // Отступ для меток недель
              ...['Пн', 'Ср', 'Пт'].map((day) => Container(
                width: cellSize,
                margin: EdgeInsets.only(right: spacing * 7 + cellSize * 6),
                child: Text(
                  day,
                  style: DesignTokens.caption,
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          
          // Сетка активности
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Метки месяцев
              Column(
                children: List.generate(7, (index) {
                  if (index % 2 == 0) {
                    return Container(
                      height: cellSize,
                      margin: EdgeInsets.only(bottom: spacing),
                      child: Text(
                        ['', 'Пн', '', 'Ср', '', 'Пт', ''][index],
                        style: DesignTokens.caption.copyWith(fontSize: 10),
                      ),
                    );
                  }
                  return Container(
                    height: cellSize,
                    margin: EdgeInsets.only(bottom: spacing),
                  );
                }),
              ),
              
              // Сетка дней
              Expanded(
                child: Row(
                  children: List.generate(12, (weekIndex) {
                    return Column(
                      children: List.generate(7, (dayIndex) {
                        final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                        final activity = activities[DateTime(date.year, date.month, date.day)] ?? 0;
                        
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: EdgeInsets.only(
                            right: spacing,
                            bottom: spacing,
                          ),
                          decoration: BoxDecoration(
                            color: _getHeatmapColor(activity, maxLevel),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: DesignTokens.glassBorder,
                              width: 0.5,
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ],
          ),
          
          // Легенда
          const SizedBox(height: DesignTokens.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Меньше', style: DesignTokens.caption),
              const SizedBox(width: DesignTokens.space8),
              ...List.generate(5, (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  color: _getHeatmapColor(index, 4),
                  borderRadius: BorderRadius.circular(1),
                ),
              )),
              const SizedBox(width: DesignTokens.space8),
              Text('Больше', style: DesignTokens.caption),
            ],
          ),
        ],
      ),
    );
  }
  
  static Color _getHeatmapColor(int activity, int maxLevel) {
    if (activity == 0) {
      return DesignTokens.glassBorder;
    }
    
    final intensity = (activity / maxLevel).clamp(0.0, 1.0);
    return Color.lerp(
      DesignTokens.primaryAccent.withOpacity(0.2),
      DesignTokens.primaryAccent,
      intensity,
    )!;
  }
  
  // ===== MUSCLE MAP WIDGET =====
  
  /// Виджет карты мышц с подсветкой активных групп
  static Widget muscleMap({
    required Set<String> activeMuscleGroups,
    bool showFront = true,
    VoidCallback? onToggleView,
  }) {
    return glassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Группы мышц',
                style: DesignTokens.h3,
              ),
              if (onToggleView != null)
                GestureDetector(
                  onTap: onToggleView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space12,
                      vertical: DesignTokens.space8,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.glassOverlay,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                      border: Border.all(color: DesignTokens.glassBorder),
                    ),
                    child: Text(
                      showFront ? 'Спереди' : 'Сзади',
                      style: DesignTokens.caption,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.space24),
          
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Силуэт человека
                CustomPaint(
                  size: const Size(200, 280),
                  painter: MuscleMapPainter(
                    activeMuscleGroups: activeMuscleGroups,
                    showFront: showFront,
                  ),
                ),
                
                // Интерактивные зоны
                ...getMuscleZones(showFront).map((zone) {
                  final isActive = activeMuscleGroups.contains(zone.name);
                  return Positioned(
                    left: zone.position.dx,
                    top: zone.position.dy,
                    child: GestureDetector(
                      onTap: () => zone.onTap?.call(),
                      child: Container(
                        width: zone.size.width,
                        height: zone.size.height,
                        decoration: BoxDecoration(
                          color: isActive 
                            ? DesignTokens.primaryAccent.withOpacity(0.3)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isActive 
                            ? Border.all(
                                color: DesignTokens.primaryAccent,
                                width: 2,
                              )
                            : null,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Легенда активных мышц
          if (activeMuscleGroups.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.space16),
            Wrap(
              spacing: DesignTokens.space8,
              runSpacing: DesignTokens.space8,
              children: activeMuscleGroups.map((muscle) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space12,
                  vertical: DesignTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  border: Border.all(
                    color: DesignTokens.primaryAccent.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  muscle,
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  // ===== PROGRESS CHIPS =====
  
  /// Чип прогресса упражнения
  static Widget progressChip({
    required String text,
    required Color color,
    IconData? icon,
    bool isIncrease = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: DesignTokens.iconSmall, color: color),
            const SizedBox(width: DesignTokens.space4),
          ],
          Text(
            text,
            style: DesignTokens.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  // ===== SEGMENTED CONTROL =====
  
  /// Segmented control для фильтров
  static Widget segmentedControl<T>({
    required List<T> options,
    required T selectedOption,
    required void Function(T) onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space4),
      decoration: BoxDecoration(
        color: DesignTokens.glassOverlay,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: DesignTokens.glassBorder),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space12,
                  vertical: DesignTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? DesignTokens.primaryAccent.withOpacity(0.2)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  border: isSelected 
                    ? Border.all(
                        color: DesignTokens.primaryAccent.withOpacity(0.5),
                      )
                    : null,
                ),
                child: Text(
                  labelBuilder(option),
                  textAlign: TextAlign.center,
                  style: DesignTokens.bodySmall.copyWith(
                    color: isSelected 
                      ? DesignTokens.primaryAccent
                      : DesignTokens.textSecondary,
                    fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // ===== KPI CARDS =====
  
  /// KPI карточка с иконкой и значением
  static Widget kpiCard({
    required String title,
    required String value,
    required IconData icon,
    String? subtitle,
    Color? accentColor,
    String? trend,
    VoidCallback? onTap,
  }) {
    final accent = accentColor ?? DesignTokens.primaryAccent;
    
    return glassCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Icon(icon, color: accent, size: DesignTokens.iconMedium),
              ),
              const Spacer(),
              if (trend != null)
                progressChip(
                  text: trend,
                  color: accent,
                  icon: trend.startsWith('+') ? Icons.trending_up : Icons.trending_down,
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          Flexible(
            child: Text(value, 
              style: DesignTokens.h2.copyWith(color: accent),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: DesignTokens.space2),
          Flexible(
            child: Text(title, 
              style: DesignTokens.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: DesignTokens.space2),
            Flexible(
              child: Text(subtitle, 
                style: DesignTokens.caption,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===== MUSCLE MAP PAINTER =====

class MuscleMapPainter extends CustomPainter {
  final Set<String> activeMuscleGroups;
  final bool showFront;
  
  MuscleMapPainter({
    required this.activeMuscleGroups,
    required this.showFront,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DesignTokens.textTertiary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Простой силуэт человека
    final path = Path();
    
    if (showFront) {
      // Голова
      path.addOval(Rect.fromCenter(
        center: Offset(center.dx, 30),
        width: 40,
        height: 50,
      ));
      
      // Тело
      path.addRect(Rect.fromCenter(
        center: Offset(center.dx, 120),
        width: 80,
        height: 120,
      ));
      
      // Руки
      path.addRect(Rect.fromLTRB(center.dx - 60, 80, center.dx - 40, 160));
      path.addRect(Rect.fromLTRB(center.dx + 40, 80, center.dx + 60, 160));
      
      // Ноги
      path.addRect(Rect.fromLTRB(center.dx - 30, 180, center.dx - 10, 260));
      path.addRect(Rect.fromLTRB(center.dx + 10, 180, center.dx + 30, 260));
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ===== MUSCLE ZONES DATA =====

class MuscleZone {
  final String name;
  final Offset position;
  final Size size;
  final VoidCallback? onTap;
  
  MuscleZone({
    required this.name,
    required this.position,
    required this.size,
    this.onTap,
  });
}

List<MuscleZone> getMuscleZones(bool showFront) {
  if (showFront) {
    return [
      MuscleZone(
        name: 'Грудь',
        position: const Offset(80, 90),
        size: const Size(40, 30),
      ),
      MuscleZone(
        name: 'Плечи',
        position: const Offset(60, 80),
        size: const Size(80, 20),
      ),
      MuscleZone(
        name: 'Руки',
        position: const Offset(40, 80),
        size: const Size(20, 80),
      ),
      MuscleZone(
        name: 'Пресс',
        position: const Offset(80, 120),
        size: const Size(40, 40),
      ),
      MuscleZone(
        name: 'Ноги',
        position: const Offset(70, 180),
        size: const Size(60, 80),
      ),
    ];
  } else {
    return [
      MuscleZone(
        name: 'Спина',
        position: const Offset(80, 90),
        size: const Size(40, 60),
      ),
      MuscleZone(
        name: 'Ягодицы',
        position: const Offset(80, 150),
        size: const Size(40, 30),
      ),
      MuscleZone(
        name: 'Икры',
        position: const Offset(75, 220),
        size: const Size(50, 40),
      ),
    ];
  }
}