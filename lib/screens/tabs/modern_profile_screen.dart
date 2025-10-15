import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_tokens.dart';
import '../settings_screen.dart';

/// Modern Profile Screen (based on screenshot 2)
/// Features: Avatar, Today's win, BMI, Weight graph, Activity heatmap
class ModernProfileScreen extends ConsumerWidget {
  const ModernProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Settings button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: DesignTokens.h1.copyWith(fontSize: 36),
                    ),
                    // Settings button will be at bottom
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Avatar and user info
            SliverToBoxAdapter(
              child: _buildUserInfo(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Today's win and BMI
            SliverToBoxAdapter(
              child: _buildStatsRow(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Weight graph
            SliverToBoxAdapter(
              child: _buildWeightGraph(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Activity heatmap
            SliverToBoxAdapter(
              child: _buildActivityHeatmap(),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Bottom buttons
            SliverToBoxAdapter(
              child: _buildBottomButtons(context),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: DesignTokens.primaryAccent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: DesignTokens.textSecondary,
            ),
          ),
          
          const SizedBox(width: 20),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mansur',
                  style: DesignTokens.h2.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '19 years • 192 cm',
                  style: DesignTokens.bodyMedium.copyWith(
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

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "Today's win",
              value: '82%',
              color: DesignTokens.primaryAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              label: 'BMI',
              value: '28',
              color: DesignTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightGraph() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight',
                style: DesignTokens.h3.copyWith(
                  color: DesignTokens.primaryAccent,
                  fontSize: 20,
                ),
              ),
              Text(
                '405 g',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Graph with wave
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DesignTokens.primaryAccent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                size: Size.infinite,
                painter: _WaveGraphPainter(
                  color: DesignTokens.primaryAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: DesignTokens.h3.copyWith(
              color: DesignTokens.primaryAccent,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          // GitHub-style activity grid
          _buildActivityGrid(),
        ],
      ),
    );
  }

  Widget _buildActivityGrid() {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignTokens.primaryAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // 6 columns for monthly view (GitHub-style)
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 30, // 5 rows x 6 columns = 30 days (monthly view)
        itemBuilder: (context, index) {
          // Simulate activity intensity (0-4)
          final intensity = (index % 5);
          final isActive = index > 9; // Last 3 weeks active
          
          return Container(
            decoration: BoxDecoration(
              color: isActive 
                  ? DesignTokens.primaryAccent.withOpacity(0.3 + (intensity * 0.15))
                  : DesignTokens.cardSurface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              icon: Icons.folder_outlined,
              label: 'History',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: DesignTokens.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DesignTokens.glassBorder,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: DesignTokens.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === COMPONENTS ===

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
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
            style: DesignTokens.h1.copyWith(
              fontSize: 40,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Wave Graph Painter
class _WaveGraphPainter extends CustomPainter {
  final Color color;

  _WaveGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Simple wave pattern
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final xMid = (points[i].dx + points[i + 1].dx) / 2;
      final yMid = (points[i].dy + points[i + 1].dy) / 2;
      
      path.quadraticBezierTo(
        points[i].dx,
        points[i].dy,
        xMid,
        yMid,
      );
    }
    
    path.lineTo(points.last.dx, points.last.dy);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
