import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/question_entity.dart';
import '../entities/session_result_entity.dart';
import '../entities/topic_entity.dart';

abstract interface class SessionRepository {
  Future<Either<Failure, List<TopicEntity>>> getTopicsByCategory(String categoryId);
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsForTopic(String topicId);
  Future<Either<Failure, void>> saveSessionResult(SessionResultEntity result);
}
