import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/results_repository.dart';

class UpdateStreakParams {
  final String userId;
  final DateTime sessionDate;
  const UpdateStreakParams({required this.userId, required this.sessionDate});
}

class UpdateUserStreak implements UseCase<void, UpdateStreakParams> {
  final ResultsRepository repository;
  const UpdateUserStreak(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStreakParams params) {
    return repository.updateStreak(params.userId, params.sessionDate);
  }
}
