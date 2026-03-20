import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_progress_entity.dart';
import '../repositories/home_repository.dart';

class GetUserProgress implements UseCase<UserProgressEntity, String> {
  final HomeRepository repository;
  const GetUserProgress(this.repository);

  @override
  Future<Either<Failure, UserProgressEntity>> call(String userId) {
    return repository.getUserProgress(userId);
  }
}
