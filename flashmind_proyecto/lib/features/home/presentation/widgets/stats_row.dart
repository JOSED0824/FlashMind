import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/widgets/stat_card.dart';
import '../../../../../core/widgets/fire_streak_widget.dart';
import '../../domain/entities/user_progress_entity.dart';

class StatsRow extends StatelessWidget {
  final UserProgressEntity progress;

  const StatsRow({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          StatCard(
            icon: Icons.star_rounded,
            value: progress.totalPoints.toString(),
            label: 'Puntos',
            valueColor: AppColors.warning,
          ),
          const SizedBox(width: 10),
          StatCard(
            icon: Icons.check_circle_rounded,
            value: progress.totalSessions.toString(),
            label: 'Sesiones',
            valueColor: AppColors.scienceStart,
          ),
          const SizedBox(width: 10),
          _StreakCard(streak: progress.currentStreak),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;

    // Border/glow color scales with streak intensity
    final Color borderColor = streak >= 7
        ? const Color(0xFFFF4500).withValues(alpha: 0.55)
        : streak >= 3
            ? const Color(0xFFFF8C00).withValues(alpha: 0.45)
            : hasStreak
                ? AppColors.warning.withValues(alpha: 0.4)
                : context.acBorder;

    final List<Color> gradientColors = streak >= 7
        ? [
            const Color(0xFFFF4500).withValues(alpha: 0.28),
            const Color(0xFFFF6B00).withValues(alpha: 0.12),
          ]
        : streak >= 3
            ? [
                const Color(0xFFFF8C00).withValues(alpha: 0.25),
                AppColors.warning.withValues(alpha: 0.10),
              ]
            : hasStreak
                ? [
                    AppColors.warning.withValues(alpha: 0.22),
                    AppColors.warning.withValues(alpha: 0.08),
                  ]
                : [
                    context.acSurface.withValues(alpha: 0.94),
                    context.acSurface2.withValues(alpha: 0.82),
                  ];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: hasStreak
                  ? borderColor.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.18),
              blurRadius: hasStreak ? 18 : 14,
              spreadRadius: hasStreak ? 1 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FireStreakWidget(streak: streak, size: 26),
            const SizedBox(height: 4),
            Text(
              hasStreak ? '${streak}d' : '0d',
              style: AppTextStyles.title.copyWith(
                color: hasStreak ? AppColors.warning : context.acText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Racha',
              style: AppTextStyles.labelSmall.copyWith(
                color: context.acTextSub,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
