import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_gradients.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final LinearGradient? borderGradient;

  const GradientCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = borderGradient ?? AppGradients.accent;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5), // border width
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius - 1.5),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
