import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/home/domain/usecases/get_user_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockHomeRepository mockRepository;
  late GetUserProgress useCase;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetUserProgress(mockRepository);
  });

  test('devuelve Right(UserProgressEntity) cuando tiene éxito', () async {
    when(() => mockRepository.getUserProgress(any())).thenAnswer(
      (_) async => Right(tProgress),
    );

    final result = await useCase('user1');

    expect(result.isRight, true);
    expect(result.right, tProgress);
  });

  test('devuelve Left(Failure) cuando falla', () async {
    when(() => mockRepository.getUserProgress(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Progreso no encontrado')),
    );

    final result = await useCase('user1');

    expect(result.isLeft, true);
    expect(result.left.message, 'Progreso no encontrado');
  });

  test('llama repository.getUserProgress con el userId correcto', () async {
    when(() => mockRepository.getUserProgress(any())).thenAnswer(
      (_) async => Right(tProgress),
    );

    await useCase('user42');

    verify(() => mockRepository.getUserProgress('user42')).called(1);
  });
}
