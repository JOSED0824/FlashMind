import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../theme/app_gradients.dart';
import 'app_loading_indicator.dart';

enum _AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final _AppButtonVariant _variant;
  final double height;

  const AppButton.primary(
    this.label, {
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary(
    this.label, {
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.text(
    this.label, {
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 48,
  }) : _variant = _AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _AppButtonVariant.primary => _buildPrimary(),
      _AppButtonVariant.secondary => _buildSecondary(),
      _AppButtonVariant.text => _buildText(),
    };
  }

  Widget _buildPrimary() {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled ? null : AppGradients.accent,
          color: isDisabled ? AppColors.surface2 : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDisabled
                ? AppColors.border
                : Colors.white.withValues(alpha: 0.20),
          ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.accentStart.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.white.withValues(alpha: 0.14),
            child: Center(child: _buildContent(Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondary() {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface2.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accentStart.withValues(alpha: 0.5),
            width: 1.4,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: AppColors.accentStart.withValues(alpha: 0.16),
            child: Center(child: _buildContent(AppColors.accentStart)),
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildContent(AppColors.accentStart),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return AppLoadingIndicator(size: 20, color: textColor);
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.label.copyWith(color: textColor)),
        ],
      );
    }
    return Text(label, style: AppTextStyles.label.copyWith(color: textColor));
  }
}
