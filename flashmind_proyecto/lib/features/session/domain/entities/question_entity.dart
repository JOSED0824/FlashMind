import 'package:equatable/equatable.dart';

class QuestionEntity extends Equatable {
  final String id;
  final String topicId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final int pointValue;

  const QuestionEntity({
    required this.id,
    required this.topicId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.pointValue,
  });

  @override
  List<Object?> get props => [id, topicId, questionText, options, correctOptionIndex, explanation, pointValue];
}
