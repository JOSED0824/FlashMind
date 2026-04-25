import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserPhotoParams {
  final String photoUrl;
  const UpdateUserPhotoParams({required this.photoUrl});
}

class UpdateUserPhoto {
  final AuthRepository repository;
  const UpdateUserPhoto(this.repository);

  Future<Either<Failure, UserEntity>> call(UpdateUserPhotoParams params) {
    return repository.updatePhotoUrl(params.photoUrl);
  }
}
