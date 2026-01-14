// =============================================================================
// discipline_rating_widget.dart — RPG-Style Discipline Score Indicator
// =============================================================================
// Premium radial progress indicator with:
// - CustomPainter for smooth arc rendering
// - Animated fill from 0 to current value (Lerp)
// - Gamification ranks with glow effects
// - Electric Amber gradient stroke
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

// =============================================================================
// DISCIPLINE RANKS — Gamification Tiers
// =============================================================================

/// Represents a discipline rank tier with score range and styling.
class DisciplineRank {
  const DisciplineRank({
    required this.nameKey,
    required this.minScore,
    required this.maxScore,
    required this.color,
    this.icon,
    this.glowIntensity = 0.3,
  });

  final String nameKey; // Key for localization (e.g. 'novice', 'apprentice')
  final int minScore;
  final int maxScore;
  final Color color;
  final IconData? icon;
  final double glowIntensity;

  /// Check if a score falls within this rank
  bool contains(int score) => score >= minScore && score < maxScore;
  
  /// Get localized name using BuildContext
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return nameKey.toUpperCase();
    
    switch (nameKey) {
      case 'novice': return l10n.rankNovice;
      case 'apprentice': return l10n.rankApprentice;
      case 'warrior': return l10n.rankWarrior;
      case 'champion': return l10n.rankChampion;
      case 'machine': return l10n.rankMachine;
      case 'legend': return l10n.rankLegend;
      default: return nameKey.toUpperCase();
    }
  }
}

/// Predefined discipline ranks (RPG-style progression)
class DisciplineRanks {
  static const List<DisciplineRank> all = [
    DisciplineRank(
      nameKey: 'novice',
      minScore: 0,
      maxScore: 200,
      color: Color(0xFF6B7280), // Gray
      icon: Icons.fitness_center,
      glowIntensity: 0.1,
    ),
    DisciplineRank(
      nameKey: 'apprentice',
      minScore: 200,
      maxScore: 400,
      color: Color(0xFF10B981), // Green
      icon: Icons.trending_up,
      glowIntensity: 0.2,
    ),
    DisciplineRank(
      nameKey: 'warrior',
      minScore: 400,
      maxScore: 600,
      color: Color(0xFF3B82F6), // Blue
      icon: Icons.shield,
      glowIntensity: 0.3,
    ),
    DisciplineRank(
      nameKey: 'champion',
      minScore: 600,
      maxScore: 800,
      color: Color(0xFF8B5CF6), // Purple
      icon: Icons.emoji_events,
      glowIntensity: 0.4,
    ),
    DisciplineRank(
      nameKey: 'machine',
      minScore: 800,
      maxScore: 950,
      color: kElectricAmberStart, // Gold
      icon: Icons.auto_awesome,
      glowIntensity: 0.5,
    ),
    DisciplineRank(
      nameKey: 'legend',
      minScore: 950,
      maxScore: 1001,
      color: Color(0xFFFF6B6B), // Red/Fire
      icon: Icons.local_fire_department,
      glowIntensity: 0.7,
    ),
  ];

  /// Get rank for a given score
  static DisciplineRank forScore(int score) {
    return all.firstWhere(
      (rank) => rank.contains(score),
      orElse: () => all.first,
    );
  }

  /// Get progress within current rank (0.0 - 1.0)
  static double progressInRank(int score) {
    final rank = forScore(score);
    final rangeSize = rank.maxScore - rank.minScore;
    final progress = (score - rank.minScore) / rangeSize;
    return progress.clamp(0.0, 1.0);
  }
}

// =============================================================================
// DISCIPLINE RATING WIDGET — Main Component
// =============================================================================

/// Premium radial discipline score indicator with animated fill.
class DisciplineRatingWidget extends StatefulWidget {
  const DisciplineRatingWidget({
    super.key,
    required this.score,
    this.maxScore = 1000,
    this.size = 200,
    this.strokeWidth = 12,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.showRankLabel = true,
    this.showProgressToNext = true,
    this.onTap,
  });

  /// Current discipline score (0 - maxScore)
  final int score;
  
  /// Maximum possible score
  final int maxScore;
  
  /// Widget size (diameter)
  final double size;
  
  /// Progress arc stroke width
  final double strokeWidth;
  
  /// Duration of fill animation
  final Duration animationDuration;
  
  /// Show rank name below score
  final bool showRankLabel;
  
  /// Show progress to next rank
  final bool showProgressToNext;
  
  /// Tap callback
  final VoidCallback? onTap;

  @override
  State<DisciplineRatingWidget> createState() => _DisciplineRatingWidgetState();
}

class _DisciplineRatingWidgetState extends State<DisciplineRatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / widget.maxScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void didUpdateWidget(DisciplineRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.score / widget.maxScore,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rank = DisciplineRanks.forScore(widget.score);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect behind
                  if (rank.glowIntensity > 0.2)
                    Container(
                      width: widget.size * 0.9,
                      height: widget.size * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rank.color.withOpacity(rank.glowIntensity * _progressAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  
                  // Background track
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RadialProgressPainter(
                      progress: 1.0,
                      strokeWidth: widget.strokeWidth,
                      trackColor: kObsidianBorder.withOpacity(0.5),
                      isTrack: true,
                    ),
                  ),
                  
                  // Progress arc with gradient
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RadialProgressPainter(
                      progress: _progressAnimation.value,
                      strokeWidth: widget.strokeWidth,
                      gradientColors: [rank.color, rank.color.withOpacity(0.6)],
                      glowColor: rank.color,
                      showGlow: rank.glowIntensity > 0.3,
                    ),
                  ),
                  
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated score number
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.score),
                        duration: widget.animationDuration,
                        builder: (context, value, child) {
                          return Text(
                            value.toString(),
                            style: kGiantNumber.copyWith(
                              fontSize: widget.size * 0.28,
                              color: kTextPrimary,
                              shadows: [
                                Shadow(
                                  color: rank.color.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      // Rank label with glow
                      if (widget.showRankLabel) ...[
                        const SizedBox(height: 4),
                        GlowingText(
                          rank.getLocalizedName(context),
                          style: kOverlineText.copyWith(
                            fontSize: widget.size * 0.06,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: rank.color,
                          ),
                          glowColor: rank.color,
                          glowRadius: rank.glowIntensity * 12,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// RADIAL PROGRESS PAINTER — CustomPainter Implementation
// =============================================================================

class _RadialProgressPainter extends CustomPainter {
  _RadialProgressPainter({
    required this.progress,
    required this.strokeWidth,
    this.trackColor,
    this.gradientColors,
    this.glowColor,
    this.isTrack = false,
    this.showGlow = false,
  });

  final double progress;
  final double strokeWidth;
  final Color? trackColor;
  final List<Color>? gradientColors;
  final Color? glowColor;
  final bool isTrack;
  final bool showGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Start from top (-90°), sweep clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isTrack) {
      // Draw background track
      paint.color = trackColor ?? kObsidianBorder;
      canvas.drawCircle(center, radius, paint);
    } else {
      // Draw progress arc with gradient
      if (gradientColors != null && gradientColors!.length >= 2) {
        // Use LinearGradient rotated to follow the arc
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors!,
          tileMode: TileMode.clamp,
        ).createShader(rect);
      }

      // Glow effect
      if (showGlow && glowColor != null) {
        final glowPaint = Paint()
          ..color = glowColor!.withOpacity(0.4)
          ..strokeWidth = strokeWidth + 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        
        canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      }

      // Main arc
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      // End cap highlight
      if (progress > 0.01) {
        final endAngle = startAngle + sweepAngle;
        final endX = center.dx + radius * math.cos(endAngle);
        final endY = center.dy + radius * math.sin(endAngle);
        
        final dotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(endX, endY), strokeWidth / 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.showGlow != showGlow;
  }
}

// =============================================================================
// COMPACT DISCIPLINE CARD — Alternative Layout
// =============================================================================

/// Compact horizontal discipline score card for use in lists/grids.
class DisciplineScoreCard extends StatelessWidget {
  const DisciplineScoreCard({
    super.key,
    required this.score,
    this.maxScore = 1000,
    this.onTap,
  });

  final int score;
  final int maxScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rank = DisciplineRanks.forScore(score);
    final progress = score / maxScore;
    
    return ObsidianCard(
      onTap: onTap,
      padding: const EdgeInsets.all(kSpaceMD),
      child: Row(
        children: [
          // Mini radial indicator
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: kObsidianBorder,
                  valueColor: AlwaysStoppedAnimation(rank.color),
                ),
                Icon(
                  rank.icon ?? Icons.fitness_center,
                  color: rank.color,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(width: kSpaceMD),
          
          // Score and rank
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      score.toString(),
                      style: kLargeNumber.copyWith(
                        fontSize: 28,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ $maxScore',
                      style: kCaptionText.copyWith(color: kTextTertiary),
                    ),
                  ],
                ),
                GlowingText(
                  rank.getLocalizedName(context),
                  style: kOverlineText.copyWith(
                    color: rank.color,
                    fontWeight: FontWeight.w700,
                  ),
                  glowColor: rank.color,
                  glowRadius: 4,
                ),
              ],
            ),
          ),
          
          // Progress to next
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: kCaptionText.copyWith(
                  color: rank.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: AmberProgressBar(
                  value: progress,
                  height: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DISCIPLINE BREAKDOWN — Detailed Stats
// =============================================================================

/// Shows breakdown of discipline score components.
class DisciplineBreakdown extends StatelessWidget {
  const DisciplineBreakdown({
    super.key,
    required this.components,
    this.animateOnLoad = true,
  });

  /// Score components (e.g., {"Тренировки": 350, "Питание": 200, ...})
  final Map<String, int> components;
  final bool animateOnLoad;

  @override
  Widget build(BuildContext context) {
    final total = components.values.fold<int>(0, (a, b) => a + b);
    final sortedEntries = components.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.map((entry) {
        final percentage = total > 0 ? entry.value / total : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: kSpaceSM),
          child: _BreakdownItem(
            label: entry.key,
            value: entry.value,
            percentage: percentage,
            animate: animateOnLoad,
          ),
        );
      }).toList(),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  const _BreakdownItem({
    required this.label,
    required this.value,
    required this.percentage,
    this.animate = true,
  });

  final String label;
  final int value;
  final double percentage;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: kCaptionText.copyWith(color: kTextSecondary),
            ),
            Text(
              '+$value',
              style: kCaptionText.copyWith(
                color: kElectricAmberStart,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? 0 : percentage, end: percentage),
          duration: animate ? kDurationSlow : Duration.zero,
          curve: kCurveEaseOut,
          builder: (context, value, child) {
            return AmberProgressBar(
              value: value,
              height: 6,
              showGlow: false,
            );
          },
        ),
      ],
    );
  }
}
