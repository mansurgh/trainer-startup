// =============================================================================
// rpg_radar_chart_widget.dart — RPG-Style Stats Radar Chart
// =============================================================================
// Premium spider/radar chart for displaying player stats:
// - Semi-transparent white grid
// - Gradient-filled data polygon with opacity
// - Animated data transitions
// - Touch interaction for stat details
// =============================================================================

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// =============================================================================
// RPG STAT DATA MODEL
// =============================================================================

/// Single stat entry for the radar chart.
class RadarStat {
  const RadarStat({
    required this.name,
    required this.localizedName,
    required this.value,
    this.maxValue = 100,
    this.icon,
    this.description,
  });

  /// Internal name/key
  final String name;
  
  /// Display name (localized)
  final String localizedName;
  
  /// Current value (0 - maxValue)
  final double value;
  
  /// Maximum possible value
  final double maxValue;
  
  /// Optional icon
  final IconData? icon;
  
  /// Optional description for tooltip
  final String? description;

  /// Normalized value (0.0 - 1.0)
  double get normalized => (value / maxValue).clamp(0.0, 1.0);

  RadarStat copyWith({
    String? name,
    String? localizedName,
    double? value,
    double? maxValue,
    IconData? icon,
    String? description,
  }) {
    return RadarStat(
      name: name ?? this.name,
      localizedName: localizedName ?? this.localizedName,
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }
}

// =============================================================================
// PREDEFINED RPG STATS
// =============================================================================

/// Standard RPG-style fitness stats
class FitnessStats {
  static const discipline = RadarStat(
    name: 'discipline',
    localizedName: 'Дисциплина',
    value: 0,
    maxValue: 100,
    icon: Icons.psychology,
    description: 'Регулярность и следование плану',
  );
  
  static const nutrition = RadarStat(
    name: 'nutrition',
    localizedName: 'Питание',
    value: 0,
    maxValue: 100,
    icon: Icons.restaurant,
    description: 'Соблюдение режима питания',
  );
  
  static const strength = RadarStat(
    name: 'strength',
    localizedName: 'Сила',
    value: 0,
    maxValue: 100,
    icon: Icons.fitness_center,
    description: 'Максимальный вес в базовых упражнениях',
  );
  
  static const endurance = RadarStat(
    name: 'endurance',
    localizedName: 'Выносливость',
    value: 0,
    maxValue: 100,
    icon: Icons.directions_run,
    description: 'Способность к длительным нагрузкам',
  );
  
  static const balance = RadarStat(
    name: 'balance',
    localizedName: 'Баланс',
    value: 0,
    maxValue: 100,
    icon: Icons.balance,
    description: 'Координация и равновесие',
  );

  static List<RadarStat> get all => [
    discipline, nutrition, strength, endurance, balance,
  ];
}

// =============================================================================
// RPG RADAR CHART WIDGET — Main Component
// =============================================================================

/// Premium radar/spider chart for RPG-style stat visualization.
class RpgRadarChart extends StatefulWidget {
  const RpgRadarChart({
    super.key,
    required this.stats,
    this.size = 280,
    this.gridLevels = 4,
    this.gridColor,
    this.fillGradient,
    this.borderColor,
    this.showLabels = true,
    this.showValues = false,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onStatTap,
  });

  /// List of stats to display (minimum 3)
  final List<RadarStat> stats;
  
  /// Widget size (diameter)
  final double size;
  
  /// Number of concentric grid rings
  final int gridLevels;
  
  /// Grid line color (default: semi-transparent white)
  final Color? gridColor;
  
  /// Data polygon fill gradient
  final Gradient? fillGradient;
  
  /// Data polygon border color
  final Color? borderColor;
  
  /// Show stat labels around the chart
  final bool showLabels;
  
  /// Show numeric values on labels
  final bool showValues;
  
  /// Animation duration for data changes
  final Duration animationDuration;
  
  /// Callback when a stat is tapped
  final void Function(RadarStat stat)? onStatTap;

  @override
  State<RpgRadarChart> createState() => _RpgRadarChartState();
}

class _RpgRadarChartState extends State<RpgRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(RpgRadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-animate if stats changed
    if (_statsChanged(oldWidget.stats, widget.stats)) {
      _controller.forward(from: 0);
    }
  }

  bool _statsChanged(List<RadarStat> old, List<RadarStat> current) {
    if (old.length != current.length) return true;
    for (int i = 0; i < old.length; i++) {
      if (old[i].value != current[i].value) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchPoint = details.localPosition;
    final touchAngle = math.atan2(
      touchPoint.dy - center.dy,
      touchPoint.dx - center.dx,
    );
    
    // Convert to positive angle starting from top
    final normalizedAngle = (touchAngle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);
    final anglePerStat = 2 * math.pi / widget.stats.length;
    final index = (normalizedAngle / anglePerStat).floor() % widget.stats.length;
    
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
    
    HapticFeedback.selectionClick();
    widget.onStatTap?.call(widget.stats[index]);
  }

  @override
  Widget build(BuildContext context) {
    final gridColor = widget.gridColor ?? Colors.white.withOpacity(0.15);
    final fillGradient = widget.fillGradient ?? LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        kElectricAmberStart.withOpacity(0.4),
        kElectricAmberEnd.withOpacity(0.2),
      ],
    );
    final borderColor = widget.borderColor ?? kElectricAmberStart;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onTapDown: (details) => _handleTap(details, Size(widget.size, widget.size)),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RadarChartPainter(
                stats: widget.stats,
                animationValue: _animation.value,
                gridLevels: widget.gridLevels,
                gridColor: gridColor,
                fillGradient: fillGradient,
                borderColor: borderColor,
                showLabels: widget.showLabels,
                showValues: widget.showValues,
                selectedIndex: _selectedIndex,
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// RADAR CHART PAINTER — CustomPainter Implementation
// =============================================================================

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.stats,
    required this.animationValue,
    required this.gridLevels,
    required this.gridColor,
    required this.fillGradient,
    required this.borderColor,
    required this.showLabels,
    required this.showValues,
    this.selectedIndex,
  });

  final List<RadarStat> stats;
  final double animationValue;
  final int gridLevels;
  final Color gridColor;
  final Gradient fillGradient;
  final Color borderColor;
  final bool showLabels;
  final bool showValues;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.length < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35; // Leave room for labels
    final angleStep = 2 * math.pi / stats.length;

    // Draw grid (concentric polygons)
    _drawGrid(canvas, center, radius, angleStep);
    
    // Draw axis lines from center to vertices
    _drawAxisLines(canvas, center, radius, angleStep);
    
    // Draw data polygon with gradient fill
    _drawDataPolygon(canvas, center, radius, angleStep);
    
    // Draw labels
    if (showLabels) {
      _drawLabels(canvas, size, center, radius, angleStep);
    }
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, double angleStep) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= gridLevels; level++) {
      final levelRadius = radius * (level / gridLevels);
      final path = Path();
      
      for (int i = 0; i <= stats.length; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawAxisLines(Canvas canvas, Offset center, double radius, double angleStep) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < stats.length; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius, double angleStep) {
    final path = Path();
    final points = <Offset>[];
    
    for (int i = 0; i <= stats.length; i++) {
      final index = i % stats.length;
      final angle = -math.pi / 2 + index * angleStep;
      final value = stats[index].normalized * animationValue;
      final distance = radius * value;
      
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();

    // Fill with gradient
    final rect = Rect.fromCenter(center: center, width: radius * 2, height: radius * 2);
    final fillPaint = Paint()
      ..shader = fillGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, fillPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, borderPaint);
    
    // Draw vertex dots
    final dotPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    for (int i = 0; i < stats.length; i++) {
      final point = points[i];
      final isSelected = selectedIndex == i;
      
      if (isSelected) {
        canvas.drawCircle(point, 10, glowPaint);
      }
      
      canvas.drawCircle(
        point,
        isSelected ? 6 : 4,
        dotPaint,
      );
      
      // White center for highlight
      canvas.drawCircle(
        point,
        isSelected ? 3 : 2,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawLabels(Canvas canvas, Size size, Offset center, double radius, double angleStep) {
    final labelRadius = radius + 24;
    
    for (int i = 0; i < stats.length; i++) {
      final stat = stats[i];
      final angle = -math.pi / 2 + i * angleStep;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);
      
      final isSelected = selectedIndex == i;
      
      // Create text painter
      final textSpan = TextSpan(
        text: showValues 
            ? '${stat.localizedName}\n${stat.value.round()}'
            : stat.localizedName,
        style: kCaptionText.copyWith(
          fontSize: isSelected ? 12 : 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? kElectricAmberStart : kTextSecondary,
          height: 1.2,
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      
      // Center the text on the label point
      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.selectedIndex != selectedIndex ||
           oldDelegate.stats != stats;
  }
}

// =============================================================================
// RADAR CHART CARD — Wrapped in Obsidian Card
// =============================================================================

/// Radar chart wrapped in a styled card with title and legend.
class RpgRadarChartCard extends StatelessWidget {
  const RpgRadarChartCard({
    super.key,
    required this.stats,
    this.title = 'Характеристики',
    this.onStatTap,
  });

  final List<RadarStat> stats;
  final String title;
  final void Function(RadarStat)? onStatTap;

  @override
  Widget build(BuildContext context) {
    return ObsidianCard(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.radar, color: kElectricAmberStart, size: 20),
              const SizedBox(width: kSpaceSM),
              Text(
                title,
                style: kDenseSubheading.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: kSpaceMD),
          
          // Chart
          Center(
            child: RpgRadarChart(
              stats: stats,
              size: 260,
              showLabels: true,
              showValues: true,
              onStatTap: onStatTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.stat});

  final RadarStat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stat.icon != null) ...[
          Icon(stat.icon, size: 14, color: kTextTertiary),
          const SizedBox(width: 4),
        ],
        Text(
          '${stat.localizedName}: ',
          style: kCaptionText.copyWith(color: kTextTertiary),
        ),
        Text(
          stat.value.round().toString(),
          style: kCaptionText.copyWith(
            color: kElectricAmberStart,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// STAT DETAIL SHEET — Bottom sheet for stat details
// =============================================================================

/// Shows detailed information about a stat when tapped.
void showStatDetailSheet(BuildContext context, RadarStat stat) {
  showModalBottomSheet(
    context: context,
    backgroundColor: kObsidianSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
    ),
    builder: (context) => _StatDetailSheet(stat: stat),
  );
}

class _StatDetailSheet extends StatelessWidget {
  const _StatDetailSheet({required this.stat});

  final RadarStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSpaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: kSpaceLG),
          
          // Stat icon and name
          Row(
            children: [
              if (stat.icon != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kElectricAmberStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusMD),
                  ),
                  child: Icon(
                    stat.icon,
                    color: kElectricAmberStart,
                    size: 24,
                  ),
                ),
              const SizedBox(width: kSpaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.localizedName,
                      style: kDenseHeading.copyWith(fontSize: 20),
                    ),
                    if (stat.description != null)
                      Text(
                        stat.description!,
                        style: kBodyText.copyWith(color: kTextTertiary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpaceLG),
          
          // Progress bar
          Row(
            children: [
              Expanded(
                child: AmberProgressBar(
                  value: stat.normalized,
                  height: 12,
                ),
              ),
              const SizedBox(width: kSpaceMD),
              Text(
                '${stat.value.round()} / ${stat.maxValue.round()}',
                style: kBodyText.copyWith(
                  color: kElectricAmberStart,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: kSpaceLG),
        ],
      ),
    );
  }
}
