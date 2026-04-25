import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/session_result_entity.dart';
import '../../domain/usecases/get_questions_for_topic.dart';
import '../../domain/usecases/save_session_result.dart';
import '../../../../features/home/data/datasources/home_local_data_source.dart';
import '../../../../services/supabase_service.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetQuestionsForTopic _getQuestionsForTopic;
  final SaveSessionResult _saveSessionResult;
  final HomeLocalDataSource _homeDataSource;
  final SupabaseService _supabaseService;

  Timer? _timer;
  late String _topicId;
  late String _categoryId;
  late String _userId;
  late int _totalSeconds;

  SessionCubit({
    required GetQuestionsForTopic getQuestionsForTopic,
    required SaveSessionResult saveSessionResult,
    required HomeLocalDataSource homeDataSource,
    required SupabaseService supabaseService,
  })  : _getQuestionsForTopic = getQuestionsForTopic,
        _saveSessionResult = saveSessionResult,
        _homeDataSource = homeDataSource,
        _supabaseService = supabaseService,
        super(const SessionInitial());

  Future<void> startSession(String topicId, String categoryId, String userId) async {
    _topicId = topicId;
    _categoryId = categoryId;
    _userId = userId;
    _totalSeconds = AppDurations.sessionDuration.inSeconds;

    emit(const SessionLoading());

    final result = await _getQuestionsForTopic(topicId);

    result.fold(
      (failure) => emit(SessionError(failure.message)),
      (questions) {
        emit(SessionInProgress(
          questions: questions,
          currentIndex: 0,
          isAnswerRevealed: false,
          secondsRemaining: _totalSeconds,
          answers: const [],
          currentPoints: 0,
        ));
        _startTimer();
      },
    );
  }

  void selectOption(int index) {
    final current = state;
    if (current is! SessionInProgress) return;
    if (current.isAnswerRevealed) return;

    final question = current.currentQuestion;
    final isCorrect = index == question.correctOptionIndex;
    final points = isCorrect ? question.pointValue : 0;

    emit(current.copyWith(
      selectedOptionIndex: index,
      isAnswerRevealed: true,
      currentPoints: current.currentPoints + points,
    ));
  }

  void nextQuestion() {
    final current = state;
    if (current is! SessionInProgress) return;

    if (current.isLastQuestion) {
      _finishSession(current);
      return;
    }

    final newAnswers = List<UserAnswer>.from(current.answers);
    if (current.selectedOptionIndex != null) {
      newAnswers.add(UserAnswer(
        questionId: current.currentQuestion.id,
        selectedIndex: current.selectedOptionIndex!,
        isCorrect: current.selectedOptionIndex == current.currentQuestion.correctOptionIndex,
      ));
    }

    emit(current.copyWith(
      currentIndex: current.currentIndex + 1,
      isAnswerRevealed: false,
      answers: newAnswers,
      clearSelected: true,
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTimerTick());
  }

  void _onTimerTick() {
    final current = state;
    if (current is! SessionInProgress) return;

    if (current.secondsRemaining <= 1) {
      _finishSession(current);
      return;
    }

    emit(current.copyWith(secondsRemaining: current.secondsRemaining - 1));
  }

  void _finishSession(SessionInProgress current) {
    _timer?.cancel();

    final allAnswers = List<UserAnswer>.from(current.answers);
    if (current.selectedOptionIndex != null) {
      allAnswers.add(UserAnswer(
        questionId: current.currentQuestion.id,
        selectedIndex: current.selectedOptionIndex!,
        isCorrect: current.selectedOptionIndex == current.currentQuestion.correctOptionIndex,
      ));
    }

    final correctCount = allAnswers.where((a) => a.isCorrect).length;
    final timeTaken = _totalSeconds - current.secondsRemaining;

    final result = SessionResultEntity(
      userId: _userId,
      topicId: _topicId,
      categoryId: _categoryId,
      totalQuestions: current.totalQuestions,
      correctAnswers: correctCount,
      pointsEarned: current.currentPoints,
      timeTakenSeconds: timeTaken,
      completedAt: DateTime.now(),
      answers: allAnswers,
    );

    _saveSessionResult(result);
    _updateProgress(result);
    emit(SessionComplete(result));
  }

  Future<void> _updateProgress(SessionResultEntity result) async {
    try {
      final progress = await _homeDataSource.getUserProgress(_userId);

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final lastDate = progress.lastSessionDate != null
          ? DateTime(
              progress.lastSessionDate!.year,
              progress.lastSessionDate!.month,
              progress.lastSessionDate!.day,
            )
          : null;

      int newStreak;
      if (lastDate == null) {
        newStreak = 1;
      } else if (lastDate == todayDate) {
        newStreak = progress.currentStreak;
      } else if (todayDate.difference(lastDate).inDays == 1) {
        newStreak = progress.currentStreak + 1;
      } else {
        newStreak = 1;
      }

      final updatedTopics = List<String>.from(progress.completedTopicIds);
      if (!updatedTopics.contains(result.topicId)) {
        updatedTopics.add(result.topicId);
      }

      progress.totalPoints += result.pointsEarned;
      progress.totalSessions += 1;
      progress.currentStreak = newStreak;
      progress.longestStreak =
          newStreak > progress.longestStreak ? newStreak : progress.longestStreak;
      progress.lastSessionDate = today;
      progress.completedTopicIds = updatedTopics;

      await _homeDataSource.saveUserProgress(progress);
      await _supabaseService.pushProgress(_userId);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
