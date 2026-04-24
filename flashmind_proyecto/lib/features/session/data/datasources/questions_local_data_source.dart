import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/topic_entity.dart';

abstract interface class QuestionsLocalDataSource {
  Future<List<TopicEntity>> getTopicsByCategory(String categoryId);
  Future<List<QuestionEntity>> getQuestionsForTopic(String topicId);
}

class QuestionsLocalDataSourceImpl implements QuestionsLocalDataSource {
  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _loadData() async {
    _cache ??= jsonDecode(
      await rootBundle.loadString('assets/data/questions.json'),
    ) as Map<String, dynamic>;
    return _cache!;
  }

  @override
  Future<List<TopicEntity>> getTopicsByCategory(String categoryId) async {
    final data = await _loadData();
    final topicsData =
        (data['topics'] as Map<String, dynamic>)[categoryId] as List?;
    if (topicsData == null) {
      throw NotFoundException('Categoría no encontrada: $categoryId');
    }
    return topicsData
        .cast<Map<String, dynamic>>()
        .map(_mapToTopicEntity)
        .toList();
  }

  @override
  Future<List<QuestionEntity>> getQuestionsForTopic(String topicId) async {
    final data = await _loadData();
    final allQuestions =
        (data['questions'] as Map<String, dynamic>)
            .values
            .expand((list) => (list as List).cast<Map<String, dynamic>>())
            .where((q) => q['topicId'] == topicId)
            .toList();
    if (allQuestions.isEmpty) {
      throw NotFoundException('No hay preguntas para el tema: $topicId');
    }
    allQuestions.shuffle();
    return allQuestions.map(_mapToQuestionEntity).toList();
  }

  TopicEntity _mapToTopicEntity(Map<String, dynamic> data) {
    final difficulty = switch (data['difficulty'] as String) {
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
