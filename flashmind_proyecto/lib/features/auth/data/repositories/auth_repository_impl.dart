import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
// import '../datasources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  // final FirebaseAuthDataSource dataSource;

  // const AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      // final entity = await dataSource.login(email, password);
      // return Right(entity);
      await Future.delayed(const Duration(seconds: 1)); // Simular espera de red
      return Right(UserEntity(
        id: "1",
        email: "test@test.com",
        username: "Usuario de Prueba",
        createdAt: DateTime.now(),
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
      String username, String email, String password) async {
    try {
      // final entity = await dataSource.register(username, email, password);
      // return Right(entity);
      await Future.delayed(const Duration(seconds: 1));
      return Right(UserEntity(
        id: "1",
        email: email,
        username: username,
        createdAt: DateTime.now(),
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // await dataSource.logout();
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // final entity = await dataSource.getCurrentUser();
      // return Right(entity);
      return const Right(null); // Siempre pedir login al inicio
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
