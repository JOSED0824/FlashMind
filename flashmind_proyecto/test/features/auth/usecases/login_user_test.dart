import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/login_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUser useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUser(mockRepository);
  });

  test('devuelve Right(UserEntity) cuando el login es exitoso', () async {
    when(() => mockRepository.login(any(), any())).thenAnswer(
      (_) async => Right(tUser),
    );

    final result = await useCase(
      const LoginParams(email: 'test@test.com', password: 'pass123'),
    );

    expect(result.isRight, true);
    expect(result.right, tUser);
  });

  test('devuelve Left(Failure) cuando el login falla', () async {
    when(() => mockRepository.login(any(), any())).thenAnswer(
      (_) async => const Left(CacheFailure('Credenciales incorrectas')),
    );

    final result = await useCase(
      const LoginParams(email: 'bad@email.com', password: 'wrong'),
    );

    expect(result.isLeft, true);
    expect(result.left.message, 'Credenciales incorrectas');
  });

  test('llama repository.login con el email y password correctos', () async {
    when(() => mockRepository.login(any(), any())).thenAnswer(
      (_) async => Right(tUser),
    );

    await useCase(
      const LoginParams(email: 'user@app.com', password: 'mypass'),
    );

    verify(() => mockRepository.login('user@app.com', 'mypass')).called(1);
  });
}
