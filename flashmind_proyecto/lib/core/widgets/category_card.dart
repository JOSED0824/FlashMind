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
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$totalTopics temas',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      color: Colors.white.withValues(alpha: 0.92),
                      size: 28,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  name,
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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
