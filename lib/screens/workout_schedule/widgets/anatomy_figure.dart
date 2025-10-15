import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/muscle_group.dart';
import '../../../theme/tokens.dart';

class AnatomyFigure extends StatelessWidget {
  final List<MuscleGroup> highlighted;
  final bool isFrontView;
  final Function(MuscleGroup)? onTapGroup;
  final Function(bool)? onToggleSide;

  const AnatomyFigure({
    super.key,
    required this.highlighted,
    required this.isFrontView,
    this.onTapGroup,
    this.onToggleSide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Front/Back
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: T.cardElevated,
                borderRadius: const BorderRadius.all(T.r10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton('Front', true),
                  _buildToggleButton('Back', false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Anatomy Figure
        SizedBox(
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base silhouette
              Container(
                width: 120,
                height: 280,
                decoration: BoxDecoration(
                  color: T.cardElevated,
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
              
              // Head
              Positioned(
                top: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: T.card,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              if (isFrontView) ..._buildFrontMuscles() else ..._buildBackMuscles(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isFront) {
    final isSelected = isFrontView == isFront;
    
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        HapticFeedback.lightImpact();
        onToggleSide?.call(isFront);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? T.accentMuted : Colors.transparent,
          borderRadius: const BorderRadius.all(T.r10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? T.text : T.textSec,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFrontMuscles() {
    return [
      // Chest
      _buildMuscleZone(
        MuscleGroup.chest,
        top: 60,
        width: 70,
        height: 40,
        borderRadius: 20,
      ),
      
      // Arms
      _buildMuscleZone(
        MuscleGroup.arms,
        top: 70,
        left: 10,
        width: 25,
        height: 60,
        borderRadius: 12,
      ),
      _buildMuscleZone(
        MuscleGroup.arms,
        top: 70,
        right: 10,
        width: 25,
        height: 60,
        borderRadius: 12,
      ),
      
      // Shoulders
      _buildMuscleZone(
        MuscleGroup.shoulders,
        top: 55,
        left: 5,
        width: 30,
        height: 25,
        borderRadius: 15,
      ),
      _buildMuscleZone(
        MuscleGroup.shoulders,
        top: 55,
        right: 5,
        width: 30,
        height: 25,
        borderRadius: 15,
      ),
      
      // Core
      _buildMuscleZone(
        MuscleGroup.core,
        top: 110,
        width: 50,
        height: 45,
        borderRadius: 15,
      ),
      
      // Legs
      _buildMuscleZone(
        MuscleGroup.legs,
        top: 170,
        left: 15,
        width: 25,
        height: 90,
        borderRadius: 12,
      ),
      _buildMuscleZone(
        MuscleGroup.legs,
        top: 170,
        right: 15,
        width: 25,
        height: 90,
        borderRadius: 12,
      ),
    ];
  }

  List<Widget> _buildBackMuscles() {
    return [
      // Back (upper)
      _buildMuscleZone(
        MuscleGroup.back,
        top: 60,
        width: 70,
        height: 60,
        borderRadius: 20,
      ),
      
      // Arms (back)
      _buildMuscleZone(
        MuscleGroup.arms,
        top: 70,
        left: 10,
        width: 25,
        height: 60,
        borderRadius: 12,
      ),
      _buildMuscleZone(
        MuscleGroup.arms,
        top: 70,
        right: 10,
        width: 25,
        height: 60,
        borderRadius: 12,
      ),
      
      // Shoulders (back)
      _buildMuscleZone(
        MuscleGroup.shoulders,
        top: 55,
        left: 5,
        width: 30,
        height: 25,
        borderRadius: 15,
      ),
      _buildMuscleZone(
        MuscleGroup.shoulders,
        top: 55,
        right: 5,
        width: 30,
        height: 25,
        borderRadius: 15,
      ),
      
      // Lower back
      _buildMuscleZone(
        MuscleGroup.back,
        top: 130,
        width: 50,
        height: 35,
        borderRadius: 15,
      ),
      
      // Legs (back)
      _buildMuscleZone(
        MuscleGroup.legs,
        top: 170,
        left: 15,
        width: 25,
        height: 90,
        borderRadius: 12,
      ),
      _buildMuscleZone(
        MuscleGroup.legs,
        top: 170,
        right: 15,
        width: 25,
        height: 90,
        borderRadius: 12,
      ),
    ];
  }

  Widget _buildMuscleZone(
    MuscleGroup group, {
    double? top,
    double? left,
    double? right,
    required double width,
    required double height,
    required double borderRadius,
  }) {
    final isHighlighted = highlighted.contains(group);
    
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTapGroup?.call(group);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isHighlighted 
              ? T.muscle.withOpacity(0.6)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: isHighlighted
              ? Border.all(color: T.muscle, width: 1)
              : null,
          ),
        ),
      ),
    );
  }
}