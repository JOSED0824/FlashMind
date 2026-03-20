import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/achievement_entity.dart';

abstract interface class ResultsRepository {
  Future<Either<Failure, List<AchievementEntity>>> getAchievements(String userId);
  Future<Either<Failure, void>> updateStreak(String userId, DateTime sessionDate);
}
