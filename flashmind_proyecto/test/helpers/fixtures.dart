import 'package:flashmind_proyecto/core/theme/app_gradients.dart';
import 'package:flashmind_proyecto/features/auth/domain/entities/user_entity.dart';
import 'package:flashmind_proyecto/features/home/domain/entities/category_entity.dart';
import 'package:flashmind_proyecto/features/home/domain/entities/user_progress_entity.dart';
import 'package:flashmind_proyecto/features/results/domain/entities/achievement_entity.dart';
import 'package:flashmind_proyecto/features/session/domain/entities/question_entity.dart';
import 'package:flashmind_proyecto/features/session/domain/entities/session_result_entity.dart';
import 'package:flashmind_proyecto/features/session/domain/entities/topic_entity.dart';

final tUser = UserEntity(
  id: 'user1',
  username: 'TestUser',
  email: 'test@test.com',
  createdAt: DateTime(2024, 1, 1),
);

const tCategory = CategoryEntity(
  id: 'cat1',
  name: 'Historia',
  description: 'Historia universal',
  iconCodePoint: 0xe001,
  totalTopics: 3,
  estimatedMinutes: 7,
  difficultyLevel: 'Fácil',
  gradientType: CategoryGradientType.history,
);

final tProgress = UserProgressEntity(
  userId: 'user1',
  totalPoints: 100,
  totalSessions: 5,
  currentStreak: 3,
  longestStreak: 7,
  completedTopicIds: const [],
);

const tTopic = TopicEntity(
  id: 'topic1',
  categoryId: 'cat1',
  title: 'La Revolución Francesa',
  description: 'Causas y consecuencias',
  questionCount: 5,
  difficulty: DifficultyLevel.easy,
);

const tQuestion = QuestionEntity(
  id: 'q1',
  topicId: 'topic1',
  questionText: '¿En qué año inició la Revolución Francesa?',
  options: ['1789', '1804', '1776', '1815'],
  correctOptionIndex: 0,
  explanation: 'La Revolución Francesa comenzó en 1789.',
  pointValue: 10,
);

const tQuestion2 = QuestionEntity(
  id: 'q2',
  topicId: 'topic1',
  questionText: '¿Quién fue guillotinado durante el Terror?',
  options: ['Napoleón', 'Luis XVI', 'Robespierre', 'Marqués de Lafayette'],
  correctOptionIndex: 1,
  explanation: 'Luis XVI fue guillotinado en 1793.',
  pointValue: 10,
);

final tResult = SessionResultEntity(
  topicId: 'topic1',
  categoryId: 'cat1',
  totalQuestions: 5,
  correctAnswers: 4,
  pointsEarned: 40,
  timeTakenSeconds: 180,
  completedAt: DateTime(2024, 1, 1),
  answers: const [],
);

const tAchievement = AchievementEntity(
  id: 'expert',
  title: 'Experto',
  description: 'Más del 80% de respuestas correctas',
  iconCodePoint: 0xe8af,
  isUnlocked: true,
);
