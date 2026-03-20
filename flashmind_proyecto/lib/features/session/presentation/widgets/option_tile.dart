import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

enum OptionState { neutral, correct, incorrect }

class OptionTile extends StatelessWidget {
  final String text;
  final int index;
  final OptionState optionState;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.text,
    required this.index,
    required this.optionState,
    this.onTap,
  });

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, letterBg, contentColor) = switch (optionState) {
      OptionState.neutral => (
          AppColors.surface2,
          AppColors.border,
          AppColors.surface,
          AppColors.textPrimary,
        ),
      OptionState.correct => (
          AppColors.correct.withValues(alpha: 0.10),
          AppColors.correct,
          AppColors.correct,
          AppColors.correct,
        ),
      OptionState.incorrect => (
          AppColors.incorrect.withValues(alpha: 0.10),
          AppColors.incorrect,
          AppColors.incorrect,
          AppColors.incorrect,
        ),
    };

    final trailingIcon = switch (optionState) {
      OptionState.correct => Icons.check_rounded,
      OptionState.incorrect => Icons.close_rounded,
      OptionState.neutral => null,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: optionState == OptionState.neutral
                        ? AppColors.surface2
                        : letterBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _letters[index],
                      style: AppTextStyles.label.copyWith(
                        color: optionState == OptionState.neutral
                            ? AppColors.textSecondary
                            : Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(color: contentColor),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: contentColor, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
