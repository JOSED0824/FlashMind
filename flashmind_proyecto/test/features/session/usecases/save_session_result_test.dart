import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/session/domain/usecases/save_session_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockSessionRepository mockRepository;
  late SaveSessionResult useCase;

  setUpAll(() {
    registerFallbackValue(tResult);
  });

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = SaveSessionResult(mockRepository);
  });

  test('devuelve Right cuando guarda el resultado exitosamente', () async {
    when(() => mockRepository.saveSessionResult(any())).thenAnswer(
      (_) async => const Right(null),
    );

    final result = await useCase(tResult);

    expect(result.isRight, true);
  });

  test('devuelve Left(Failure) cuando falla al guardar', () async {
    when(() => mockRepository.saveSessionResult(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Error al guardar')),
    );

    final result = await useCase(tResult);

    expect(result.isLeft, true);
    expect(result.left.message, 'Error al guardar');
  });

  test('llama repository.saveSessionResult con el resultado correcto',
      () async {
    when(() => mockRepository.saveSessionResult(any())).thenAnswer(
      (_) async => const Right(null),
    );

    await useCase(tResult);

    verify(() => mockRepository.saveSessionResult(tResult)).called(1);
  });
}
