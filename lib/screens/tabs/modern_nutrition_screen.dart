import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../core/design_tokens.dart';
import '../ai_chat_screen.dart';

/// Modern Nutrition Screen (based on screenshot 3)
/// Features: Consumed/Remaining, circular progress, macro cards, Add meal button
class ModernNutritionScreen extends ConsumerWidget {
  const ModernNutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Text(
                  'Nutrition',
                  style: DesignTokens.h1.copyWith(fontSize: 36),
                ),
              ),
            ),
            
            // Daily Summary subtitle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Daily Summary',
                  style: DesignTokens.bodyLarge.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Consumed/Remaining Cards
            SliverToBoxAdapter(
              child: _buildCalorieCards(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Circular Progress with Food Icons
            SliverToBoxAdapter(
              child: _buildCircularProgress(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Macro Cards (Protein, Fat, Carbs)
            SliverToBoxAdapter(
              child: _buildMacroCards(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // AI Nutritionist Chat Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAINutritionistButton(context),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            
            // Meal Program Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildMealProgramButton(context),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            
            // Fridge Photo Upload Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFridgePhotoButton(context),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            
            // Add Meal Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAddMealButton(),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _CalorieCard(
              label: 'Consumed',
              value: '1070 kcal',
              isConsumed: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _CalorieCard(
              label: 'Remaining',
              value: '930 kcal',
              isConsumed: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth.clamp(250.0, 300.0);
          return Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular progress ring (white instead of emerald)
                  SizedBox.expand(
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: 0.53,
                        progressColor: DesignTokens.textPrimary, // White
                        backgroundColor: DesignTokens.surface,
                      ),
                    ),
                  ),
                  
                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '53%',
                        style: DesignTokens.h1.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'of 2000 kcal',
                        style: DesignTokens.bodyMedium.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Food emoji icons on the ring
                  ..._buildFoodIcons(size),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFoodIcons(double containerSize) {
    final icons = ['🥩', '🥦'];
    final angles = [-90.0, 90.0]; // Left and right positions
    
    return List.generate(icons.length, (index) {
      final angle = angles[index] * (math.pi / 180);
      final radius = (containerSize / 2) - 20; // Position on the ring
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      return Positioned(
        left: (containerSize / 2) + x - 20,
        top: (containerSize / 2) + y - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DesignTokens.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: DesignTokens.textSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              icons[index],
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMacroCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _MacroCard(
              label: 'Protein',
              consumed: '85',
              target: '120',
              unit: 'g',
              color: DesignTokens.textPrimary, // White
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MacroCard(
              label: 'Fat',
              consumed: '65',
              target: '80',
              unit: 'g',
              color: DesignTokens.textPrimary, // White
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MacroCard(
              label: 'Carbs',
              consumed: '180',
              target: '250',
              unit: 'g',
              color: DesignTokens.textPrimary, // White
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAINutritionistButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AIChatScreen(chatType: 'nutrition'),
          ),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, color: DesignTokens.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Nutritionist Chat',
              style: DesignTokens.h3.copyWith(
                color: DesignTokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealProgramButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to meal program screen with manual editing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal Program - Coming Soon')),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DesignTokens.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, color: DesignTokens.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Meal Program',
              style: DesignTokens.h3.copyWith(
                color: DesignTokens.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFridgePhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // TODO: Implement fridge photo upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fridge Photo Upload - Coming Soon')),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DesignTokens.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: DesignTokens.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Upload Fridge Photo',
              style: DesignTokens.h3.copyWith(
                color: DesignTokens.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMealButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: DesignTokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignTokens.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Add meal',
          style: DesignTokens.h3.copyWith(
            color: DesignTokens.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// === COMPONENTS ===

class _CalorieCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isConsumed;

  const _CalorieCard({
    required this.label,
    required this.value,
    required this.isConsumed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignTokens.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: DesignTokens.h2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String consumed;
  final String target;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: DesignTokens.h2.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
              children: [
                TextSpan(text: consumed),
                TextSpan(
                  text: ' / ',
                  style: DesignTokens.h2.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                TextSpan(
                  text: target,
                  style: DesignTokens.h2.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: DesignTokens.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 16.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [progressColor, progressColor.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
