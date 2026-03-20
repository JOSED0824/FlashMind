import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../models/progress_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource dataSource;

  const HomeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await dataSource.getCategories();
      return Right(categories);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserProgressEntity>> getUserProgress(String userId) async {
    try {
      final model = await dataSource.getUserProgress(userId);
      return Right(model.toEntity());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveUserProgress(UserProgressEntity progress) async {
    try {
      final model = ProgressModel(
        userId: progress.userId,
        totalPoints: progress.totalPoints,
        totalSessions: progress.totalSessions,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        lastSessionDate: progress.lastSessionDate,
        completedTopicIds: progress.completedTopicIds,
      );
      await dataSource.saveUserProgress(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
