import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/session_result_entity.dart';
import '../../domain/usecases/get_questions_for_topic.dart';
import '../../domain/usecases/save_session_result.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetQuestionsForTopic _getQuestionsForTopic;
  final SaveSessionResult _saveSessionResult;

  Timer? _timer;
  late String _topicId;
  late String _categoryId;
  late int _totalSeconds;

  SessionCubit({
    required GetQuestionsForTopic getQuestionsForTopic,
    required SaveSessionResult saveSessionResult,
  })  : _getQuestionsForTopic = getQuestionsForTopic,
        _saveSessionResult = saveSessionResult,
        super(const SessionInitial());

  Future<void> startSession(String topicId, String categoryId) async {
    _topicId = topicId;
    _categoryId = categoryId;
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
    emit(SessionComplete(result));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
