import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../domain/entities/topic_entity.dart';

class TopicCard extends StatelessWidget {
  final TopicEntity topic;
  final VoidCallback onTap;
  final Color accentColor;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(topic.title, style: AppTextStyles.label.copyWith(fontSize: 14)),
                        ),
                        _DifficultyChip(difficulty: topic.difficulty),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.quiz_rounded, size: 12, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.questionCount} ${AppStrings.questions}',
                          style: AppTextStyles.labelSmall,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.timer_rounded, size: 12, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text('7 ${AppStrings.minutes}', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final DifficultyLevel difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      DifficultyLevel.easy => (AppStrings.easy, AppColors.correct),
      DifficultyLevel.medium => (AppStrings.medium, AppColors.warning),
      DifficultyLevel.hard => (AppStrings.hard, AppColors.incorrect),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
