import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// A reusable animated fire widget that renders a realistic flame when [streak] > 0.
/// The flame intensity scales with the streak count.
class FireStreakWidget extends StatelessWidget {
  final int streak;
  final double size;

  const FireStreakWidget({super.key, required this.streak, this.size = 36});

  // Intensity tier: 0 = no streak, 1 = small, 2 = medium, 3 = big fire
  int get _tier {
    if (streak <= 0) return 0;
    if (streak < 3) return 1;
    if (streak < 7) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) {
      return Icon(
        Icons.local_fire_department_rounded,
        color: context.acTextSub,
        size: size,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          _buildGlow(),
          // Back flame (slightly shifted)
          _buildFlameLayer(
            iconSize: size * 0.78,
            color: _tier >= 3
                ? const Color(0xFFFF4500)
                : const Color(0xFFFF6B00),
            scaleDuration: 900,
            scaleMin: 0.80,
            scaleMax: 1.10,
            rotateDegrees: -8,
            delay: 80,
          ),
          // Mid flame
          _buildFlameLayer(
            iconSize: size * 0.88,
            color: _tier >= 2
                ? const Color(0xFFFF8C00)
                : AppColors.warning,
            scaleDuration: 700,
            scaleMin: 0.88,
            scaleMax: 1.15,
            rotateDegrees: 5,
            delay: 0,
          ),
          // Core bright flame
          _buildFlameLayer(
            iconSize: size,
            color: _tier >= 3
                ? const Color(0xFFFFD700)
                : (_tier == 2
                    ? const Color(0xFFFFA500)
                    : AppColors.warning),
            scaleDuration: 600,
            scaleMin: 0.92,
            scaleMax: 1.18,
            rotateDegrees: 0,
            delay: 150,
          ),
          // Shimmer highlight on top
          Icon(
            Icons.local_fire_department_rounded,
            size: size * 0.55,
            color: Colors.white.withValues(alpha: 0.85),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(
                duration: 1200.ms,
                delay: 300.ms,
                color: Colors.white.withValues(alpha: 0.6),
              )
              .fade(
                begin: 0.5,
                end: 0.9,
                duration: 800.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  Widget _buildGlow() {
    final glowColor = _tier >= 3
        ? const Color(0xFFFF4500)
        : (_tier == 2 ? const Color(0xFFFF8C00) : AppColors.warning);

    return Animate(
      onPlay: (c) => c.repeat(reverse: true),
      child: Container(
        width: size * 1.1,
        height: size * 1.1,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.40),
              blurRadius: size * 0.6,
              spreadRadius: size * 0.1,
            ),
          ],
        ),
      ),
    ).scaleXY(
      begin: 0.85,
      end: 1.15,
      duration: 800.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildFlameLayer({
    required double iconSize,
    required Color color,
    required int scaleDuration,
    required double scaleMin,
    required double scaleMax,
    required double rotateDegrees,
    required int delay,
  }) {
    return Transform.rotate(
      angle: rotateDegrees * math.pi / 180,
      child: Icon(
        Icons.local_fire_department_rounded,
        size: iconSize,
        color: color,
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: Offset(scaleMin, scaleMin),
            end: Offset(scaleMax, scaleMax),
            duration: Duration(milliseconds: scaleDuration),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeInOut,
          )
          .then()
          .shimmer(
            duration: Duration(milliseconds: scaleDuration + 200),
            color: color.withValues(alpha: 0.4),
          ),
    );
  }
}
