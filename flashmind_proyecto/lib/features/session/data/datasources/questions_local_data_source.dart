import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/topic_entity.dart';
import 'mock_questions_data.dart';

abstract interface class QuestionsLocalDataSource {
  Future<List<TopicEntity>> getTopicsByCategory(String categoryId);
  Future<List<QuestionEntity>> getQuestionsForTopic(String topicId);
}

class QuestionsLocalDataSourceImpl implements QuestionsLocalDataSource {
  @override
  Future<List<TopicEntity>> getTopicsByCategory(String categoryId) async {
    final topicsData = MockQuestionsData.topics[categoryId];
    if (topicsData == null) {
      throw NotFoundException('Categoría no encontrada: $categoryId');
    }
    return topicsData.map(_mapToTopicEntity).toList();
  }

  @override
  Future<List<QuestionEntity>> getQuestionsForTopic(String topicId) async {
    final allQuestions = MockQuestionsData.questions.values
        .expand((list) => list)
        .where((q) => q['topicId'] == topicId)
        .toList();
    if (allQuestions.isEmpty) {
      throw NotFoundException('No hay preguntas para el tema: $topicId');
    }
    allQuestions.shuffle();
    return allQuestions.map(_mapToQuestionEntity).toList();
  }

  TopicEntity _mapToTopicEntity(Map<String, dynamic> data) {
    final difficultyStr = data['difficulty'] as String;
    final difficulty = switch (difficultyStr) {
      'easy' => DifficultyLevel.easy,
      'medium' => DifficultyLevel.medium,
      'hard' => DifficultyLevel.hard,
      _ => DifficultyLevel.easy,
    };
    return TopicEntity(
      id: data['id'] as String,
      categoryId: data['categoryId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      questionCount: data['questionCount'] as int,
      difficulty: difficulty,
    );
  }

  QuestionEntity _mapToQuestionEntity(Map<String, dynamic> data) {
    return QuestionEntity(
      id: data['id'] as String,
      topicId: data['topicId'] as String,
      questionText: data['questionText'] as String,
      options: List<String>.from(data['options'] as List),
      correctOptionIndex: data['correctOptionIndex'] as int,
      explanation: data['explanation'] as String,
      pointValue: data['pointValue'] as int,
    );
  }
}
