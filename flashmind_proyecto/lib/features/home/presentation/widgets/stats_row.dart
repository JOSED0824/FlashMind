import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/stat_card.dart';
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
          StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '${progress.currentStreak}d',
            label: 'Racha',
            valueColor: AppColors.correct,
          ),
        ],
      ),
    );
  }
}
