import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/core/utils/no_params.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/logout_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUser useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUser(mockRepository);
  });

  test('devuelve Right cuando el logout es exitoso', () async {
    when(() => mockRepository.logout()).thenAnswer(
      (_) async => Right<Failure, void>(null),
    );

    final result = await useCase(const NoParams());

    expect(result.isRight, true);
  });

  test('llama repository.logout exactamente una vez', () async {
    when(() => mockRepository.logout()).thenAnswer(
      (_) async => Right<Failure, void>(null),
    );

    await useCase(const NoParams());

    verify(() => mockRepository.logout()).called(1);
  });

  test('devuelve Left(Failure) cuando el logout falla', () async {
    when(() => mockRepository.logout()).thenAnswer(
      (_) async => const Left(CacheFailure('Error al cerrar sesión')),
    );

    final result = await useCase(const NoParams());

    expect(result.isLeft, true);
    expect(result.left.message, 'Error al cerrar sesión');
  });
}
