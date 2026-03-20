import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/question_entity.dart';
import '../repositories/session_repository.dart';

class GetQuestionsForTopic implements UseCase<List<QuestionEntity>, String> {
  final SessionRepository repository;
  const GetQuestionsForTopic(this.repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(String topicId) {
    return repository.getQuestionsForTopic(topicId);
  }
}
