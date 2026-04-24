import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/core/utils/no_params.dart';
import 'package:flashmind_proyecto/features/home/domain/usecases/get_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockHomeRepository mockRepository;
  late GetCategories useCase;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetCategories(mockRepository);
  });

  test('devuelve Right con lista de categorías cuando tiene éxito', () async {
    when(() => mockRepository.getCategories()).thenAnswer(
      (_) async => Right([tCategory]),
    );

    final result = await useCase(const NoParams());

    expect(result.isRight, true);
    expect(result.right, [tCategory]);
  });

  test('devuelve Right con lista vacía si no hay categorías', () async {
    when(() => mockRepository.getCategories()).thenAnswer(
      (_) async => Right([]),
    );

    final result = await useCase(const NoParams());

    expect(result.right, isEmpty);
  });

  test('devuelve Left(Failure) cuando falla', () async {
    when(() => mockRepository.getCategories()).thenAnswer(
      (_) async => const Left(CacheFailure('Sin conexión')),
    );

    final result = await useCase(const NoParams());

    expect(result.isLeft, true);
    expect(result.left.message, 'Sin conexión');
  });

  test('llama repository.getCategories exactamente una vez', () async {
    when(() => mockRepository.getCategories()).thenAnswer(
      (_) async => Right([tCategory]),
    );

    await useCase(const NoParams());

    verify(() => mockRepository.getCategories()).called(1);
  });
}
