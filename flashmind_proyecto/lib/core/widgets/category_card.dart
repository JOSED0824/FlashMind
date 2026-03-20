import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../theme/app_gradients.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final int totalTopics;
  final CategoryGradientType gradientType;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.totalTopics,
    required this.gradientType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppGradients.forCategory(gradientType);
    final shadowColor = AppGradients.shadowColorForCategory(gradientType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 28),
              ),
              const Spacer(),
              Text(
                name,
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalTopics temas',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.95, duration: 400.ms);
  }
}

extension CategoryCardColors on CategoryGradientType {
  Color get startColor {
    switch (this) {
      case CategoryGradientType.history:
        return AppColors.historyStart;
      case CategoryGradientType.science:
        return AppColors.scienceStart;
      case CategoryGradientType.languages:
        return AppColors.languagesStart;
      case CategoryGradientType.technology:
        return AppColors.techStart;
    }
  }
}
