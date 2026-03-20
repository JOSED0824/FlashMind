import 'package:equatable/equatable.dart';

enum DifficultyLevel { easy, medium, hard }

class TopicEntity extends Equatable {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final int questionCount;
  final DifficultyLevel difficulty;

  const TopicEntity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.difficulty,
  });

  @override
  List<Object?> get props => [id, categoryId, title, description, questionCount, difficulty];
}
