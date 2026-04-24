import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ScoreRing extends StatelessWidget {
  final double percent;
  final int pointsEarned;

  const ScoreRing({super.key, required this.percent, required this.pointsEarned});

  Color get _ringColor {
    if (percent >= 0.7) return AppColors.correct;
    if (percent >= 0.4) return AppColors.warning;
    return AppColors.incorrect;
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 12,
      percent: percent.clamp(0.0, 1.0),
      animation: true,
      animationDuration: 1200,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: context.acSurface2,
      progressColor: _ringColor,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(percent * 100).round()}%',
            style: AppTextStyles.headline.copyWith(color: _ringColor),
          ),
          Text('precisión', style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
