import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/session_result_entity.dart';
import '../../domain/entities/topic_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/questions_local_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final QuestionsLocalDataSource dataSource;
  final Box _sessionsBox;

  const SessionRepositoryImpl(this.dataSource, this._sessionsBox);

  @override
  Future<Either<Failure, List<TopicEntity>>> getTopicsByCategory(String categoryId) async {
    try {
      final topics = await dataSource.getTopicsByCategory(categoryId);
      return Right(topics);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsForTopic(String topicId) async {
    try {
      final questions = await dataSource.getQuestionsForTopic(topicId);
      return Right(questions);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveSessionResult(SessionResultEntity result) async {
    try {
      final key = '${result.topicId}_${result.completedAt.millisecondsSinceEpoch}';
      await _sessionsBox.put(key, {
        'topicId': result.topicId,
        'categoryId': result.categoryId,
        'totalQuestions': result.totalQuestions,
        'correctAnswers': result.correctAnswers,
        'pointsEarned': result.pointsEarned,
        'timeTakenSeconds': result.timeTakenSeconds,
        'completedAt': result.completedAt.toIso8601String(),
      });
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
