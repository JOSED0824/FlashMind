import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUsernameParams {
  final String username;
  const UpdateUsernameParams({required this.username});
}

class UpdateUsername {
  final AuthRepository repository;
  const UpdateUsername(this.repository);

  Future<Either<Failure, UserEntity>> call(UpdateUsernameParams params) {
    return repository.updateUsername(params.username);
  }
}
