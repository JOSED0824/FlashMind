import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../../../session/domain/entities/session_result_entity.dart';
import '../cubit/results_cubit.dart';
import '../cubit/results_state.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/score_ring.dart';

class ResultsPage extends StatefulWidget {
  final SessionResultEntity result;

  const ResultsPage({super.key, required this.result});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ResultsCubit>().loadResults(widget.result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07121D), Color(0xFF0C2538), Color(0xFF12384E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ResultsCubit, ResultsState>(
            builder: (context, state) {
              if (state is ResultsLoading || state is ResultsInitial) {
                return const AppLoadingIndicator();
              }
              if (state is ResultsLoaded) {
                return _buildContent(context, state);
              }
              return const AppLoadingIndicator();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ResultsLoaded state) {
    final result = state.result;
    final motivationalText = _getMotivationalText(result.accuracy);
    final motivationalIcon = _getMotivationalIcon(result.accuracy);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            motivationalIcon,
            size: 44,
            color: AppColors.warning,
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(
            motivationalText,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 4),
          Text(
            'Tiempo: ${result.formattedTime}',
            style: AppTextStyles.caption,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ScoreRing(percent: result.accuracy, pointsEarned: result.pointsEarned)
              .animate()
              .scaleXY(begin: 0.5, duration: 600.ms, curve: Curves.easeOut)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 32),
          _buildStatsGrid(result),
          if (state.achievements.isNotEmpty) ...[
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Nuevos logros', style: AppTextStyles.title),
            ),
            const SizedBox(height: 12),
            ...state.achievements.map((a) => AchievementBadge(achievement: a)),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  'Inicio',
                  onPressed: () => context.go(RouteNames.home),
                  icon: Icons.home_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.primary(
                  'Repetir',
                  onPressed: () => context.pop(),
                  icon: Icons.replay_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(SessionResultEntity result) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.star_rounded,
          value: '+${result.pointsEarned}',
          label: 'Puntos',
          color: AppColors.warning,
        ),
        _StatCard(
          icon: Icons.check_circle_rounded,
          value: '${result.correctAnswers}/${result.totalQuestions}',
          label: 'Correctas',
          color: AppColors.correct,
        ),
        _StatCard(
          icon: Icons.timer_rounded,
          value: result.formattedTime,
          label: 'Tiempo',
          color: AppColors.textPrimary,
        ),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          value: '${(result.accuracy * 100).round()}%',
          label: 'Precisión',
          color: AppColors.accentStart,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  String _getMotivationalText(double accuracy) {
    if (accuracy >= 0.9) return '¡Increíble trabajo!';
    if (accuracy >= 0.7) return '¡Muy bien hecho!';
    if (accuracy >= 0.5) return 'Buen esfuerzo';
    return '¡Sigue practicando!';
  }

  IconData _getMotivationalIcon(double accuracy) {
    if (accuracy >= 0.9) return Icons.celebration_rounded;
    if (accuracy >= 0.7) return Icons.emoji_events_rounded;
    if (accuracy >= 0.5) return Icons.thumb_up_rounded;
    return Icons.fitness_center_rounded;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.surface2.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.title.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
