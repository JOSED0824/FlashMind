import 'package:equatable/equatable.dart';

class UserAnswer extends Equatable {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;

  const UserAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [questionId, selectedIndex, isCorrect];
}

class SessionResultEntity extends Equatable {
  final String userId;
  final String topicId;
  final String categoryId;
  final int totalQuestions;
  final int correctAnswers;
  final int pointsEarned;
  final int timeTakenSeconds;
  final DateTime completedAt;
  final List<UserAnswer> answers;

  const SessionResultEntity({
    required this.userId,
    required this.topicId,
    required this.categoryId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.pointsEarned,
    required this.timeTakenSeconds,
    required this.completedAt,
    required this.answers,
  });

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;

  String get formattedTime {
    final minutes = timeTakenSeconds ~/ 60;
    final seconds = timeTakenSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        topicId,
        categoryId,
        totalQuestions,
        correctAnswers,
        pointsEarned,
        timeTakenSeconds,
        completedAt,
        answers,
      ];
}
