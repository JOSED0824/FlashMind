import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/results_repository.dart';
import '../datasources/results_local_data_source.dart';
import '../../../session/domain/entities/session_result_entity.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  final ResultsLocalDataSource dataSource;

  const ResultsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<AchievementEntity>>> getAchievements(String topicId) async {
    // Achievement logic is evaluated with the full result in the use case layer
    return const Right([]);
  }

  Future<Either<Failure, List<AchievementEntity>>> getAchievementsForResult(
      SessionResultEntity result) async {
    try {
      final achievements = await dataSource.getAchievementsForResult(result);
      return Right(achievements);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateStreak(String userId, DateTime sessionDate) async {
    // Streak is managed by the HomeCubit via HomeRepository
    return const Right(null);
  }
}
