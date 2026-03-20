import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/topic_entity.dart';
import '../repositories/session_repository.dart';

class GetTopicsByCategory implements UseCase<List<TopicEntity>, String> {
  final SessionRepository repository;
  const GetTopicsByCategory(this.repository);

  @override
  Future<Either<Failure, List<TopicEntity>>> call(String categoryId) {
    return repository.getTopicsByCategory(categoryId);
  }
}
