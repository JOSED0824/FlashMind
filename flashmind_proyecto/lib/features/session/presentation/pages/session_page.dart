import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_durations.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';
import '../widgets/circular_timer.dart';
import '../widgets/option_tile.dart';

class SessionPage extends StatefulWidget {
  final String topicId;
  final String categoryId;

  const SessionPage({
    super.key,
    required this.topicId,
    required this.categoryId,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().startSession(
      widget.topicId,
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is SessionComplete) {
          context.pushReplacement(RouteNames.results, extra: state.result);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.acBg, context.acBgMid, context.acBgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
                if (state is SessionLoading || state is SessionInitial) {
                  return const AppLoadingIndicator();
                }
                if (state is SessionError) {
                  return Center(
                    child: Text(state.message, style: AppTextStyles.body),
                  );
                }
                if (state is SessionInProgress) {
                  return _buildSession(context, state);
                }
                return const AppLoadingIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSession(BuildContext context, SessionInProgress state) {
    final cubit = context.read<SessionCubit>();
    final question = state.currentQuestion;

    return Column(
      children: [
        _buildHeader(context, state),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  decoration: BoxDecoration(
                    color: context.acSurface.withValues(alpha: 0.74),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.acBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREGUNTA ${state.currentIndex + 1} DE ${state.totalQuestions}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accentStart,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value:
                              (state.currentIndex + 1) / state.totalQuestions,
                          backgroundColor: context.acBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentStart,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.acSurface.withValues(alpha: 0.95),
                        context.acSurface2.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: context.acBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    question.questionText,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                ...question.options.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final opt = entry.value;
                  final optionState = _getOptionState(idx, state);

                  return OptionTile(
                    text: opt,
                    index: idx,
                    optionState: optionState,
                    onTap: state.isAnswerRevealed
                        ? null
                        : () => cubit.selectOption(idx),
                  );
                }),
                if (state.isAnswerRevealed) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.correct.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.correct.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.correct,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPLICACIÓN',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.correct,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                question.explanation,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: AppDurations.animNormal),
                  const SizedBox(height: 16),
                  AppButton.primary(
                    state.isLastQuestion
                        ? 'Ver resultados'
                        : 'Siguiente pregunta',
                    onPressed: cubit.nextQuestion,
                    icon: state.isLastQuestion
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                  ).animate().fadeIn(duration: AppDurations.animNormal),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  OptionState _getOptionState(int index, SessionInProgress state) {
    if (!state.isAnswerRevealed) return OptionState.neutral;
    if (index == state.currentQuestion.correctOptionIndex)
      return OptionState.correct;
    if (index == state.selectedOptionIndex) return OptionState.incorrect;
    return OptionState.neutral;
  }

  Widget _buildHeader(BuildContext context, SessionInProgress state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.acSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.acBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _confirmExit(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.acSurface2,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: context.acTextSub,
              ),
            ),
          ),
          SizedBox(
            width: 84,
            height: 84,
            child: CircularTimer(
              secondsRemaining: state.secondsRemaining,
              totalSeconds: AppDurations.sessionDuration.inSeconds,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: context.acSurface2,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.accentStart,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.currentPoints}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accentStart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.acSurface2,
        title: Text('¿Salir de la sesión?', style: AppTextStyles.title),
        content: Text(
          'Tu progreso se perderá.',
          style: AppTextStyles.body.copyWith(color: context.acTextSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Salir', style: TextStyle(color: AppColors.incorrect)),
          ),
        ],
      ),
    );
  }
}
