import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/category_entity.dart';
import '../entities/user_progress_entity.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, UserProgressEntity>> getUserProgress(String userId);
  Future<Either<Failure, void>> saveUserProgress(UserProgressEntity progress);
}
