import 'package:equatable/equatable.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/session_result_entity.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionInProgress extends SessionState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final int? selectedOptionIndex;
  final bool isAnswerRevealed;
  final int secondsRemaining;
  final List<UserAnswer> answers;
  final int currentPoints;

  const SessionInProgress({
    required this.questions,
    required this.currentIndex,
    this.selectedOptionIndex,
    required this.isAnswerRevealed,
    required this.secondsRemaining,
    required this.answers,
    required this.currentPoints,
  });

  QuestionEntity get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex == questions.length - 1;

  SessionInProgress copyWith({
    int? currentIndex,
    int? selectedOptionIndex,
    bool? isAnswerRevealed,
    int? secondsRemaining,
    List<UserAnswer>? answers,
    int? currentPoints,
    bool clearSelected = false,
  }) {
    return SessionInProgress(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionIndex: clearSelected ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      answers: answers ?? this.answers,
      currentPoints: currentPoints ?? this.currentPoints,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        selectedOptionIndex,
        isAnswerRevealed,
        secondsRemaining,
        answers,
        currentPoints,
      ];
}

class SessionComplete extends SessionState {
  final SessionResultEntity result;
  const SessionComplete(this.result);

  @override
  List<Object?> get props => [result];
}

class SessionError extends SessionState {
  final String message;
  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
