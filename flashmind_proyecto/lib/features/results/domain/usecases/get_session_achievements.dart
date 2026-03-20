import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/achievement_entity.dart';
import '../repositories/results_repository.dart';
import '../../../session/domain/entities/session_result_entity.dart';

class GetSessionAchievements implements UseCase<List<AchievementEntity>, SessionResultEntity> {
  final ResultsRepository repository;
  const GetSessionAchievements(this.repository);

  @override
  Future<Either<Failure, List<AchievementEntity>>> call(SessionResultEntity result) {
    return repository.getAchievements(result.topicId);
  }
}
