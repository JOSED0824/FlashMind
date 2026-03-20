import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/session_result_entity.dart';
import '../repositories/session_repository.dart';

class SaveSessionResult implements UseCase<void, SessionResultEntity> {
  final SessionRepository repository;
  const SaveSessionResult(this.repository);

  @override
  Future<Either<Failure, void>> call(SessionResultEntity result) {
    return repository.saveSessionResult(result);
  }
}
