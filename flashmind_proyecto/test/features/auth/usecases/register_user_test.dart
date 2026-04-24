import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUser useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUser(mockRepository);
  });

  test('devuelve Right(UserEntity) cuando el registro es exitoso', () async {
    when(() => mockRepository.register(any(), any(), any())).thenAnswer(
      (_) async => Right(tUser),
    );

    final result = await useCase(
      const RegisterParams(
        username: 'TestUser',
        email: 'test@test.com',
        password: 'pass123',
      ),
    );

    expect(result.isRight, true);
    expect(result.right, tUser);
  });

  test('devuelve Left(Failure) cuando el registro falla', () async {
    when(() => mockRepository.register(any(), any(), any())).thenAnswer(
      (_) async => const Left(CacheFailure('Email ya registrado')),
    );

    final result = await useCase(
      const RegisterParams(
        username: 'User',
        email: 'existing@email.com',
        password: 'pass',
      ),
    );

    expect(result.isLeft, true);
    expect(result.left.message, 'Email ya registrado');
  });

  test('llama repository.register con username, email y password correctos',
      () async {
    when(() => mockRepository.register(any(), any(), any())).thenAnswer(
      (_) async => Right(tUser),
    );

    await useCase(
      const RegisterParams(
        username: 'TestUser',
        email: 'test@test.com',
        password: 'pass123',
      ),
    );

    verify(
      () => mockRepository.register('TestUser', 'test@test.com', 'pass123'),
    ).called(1);
  });
}
