import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String username;
  final String email;
  final String password;
  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
  });
}

class RegisterUser implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  const RegisterUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return repository.register(params.username, params.email, params.password);
  }
}
