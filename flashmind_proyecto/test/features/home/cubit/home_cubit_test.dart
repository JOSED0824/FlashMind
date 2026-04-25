import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/core/utils/no_params.dart';
import 'package:flashmind_proyecto/features/home/presentation/cubit/home_cubit.dart';
import 'package:flashmind_proyecto/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockGetCategories mockGetCategories;
  late MockGetUserProgress mockGetUserProgress;
  late MockSupabaseService mockSupabaseService;
  late HomeCubit cubit;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockGetUserProgress = MockGetUserProgress();
    mockSupabaseService = MockSupabaseService();
    when(() => mockSupabaseService.syncProgress(any()))
        .thenAnswer((_) async {});
    cubit = HomeCubit(
      getCategories: mockGetCategories,
      getUserProgress: mockGetUserProgress,
      supabaseService: mockSupabaseService,
    );
  });

  tearDown(() => cubit.close());

  test('estado inicial es HomeInitial', () {
    expect(cubit.state, const HomeInitial());
  });

  // ── loadHome exitoso ────────────────────────────────────────────────────────

  test('loadHome exitoso emite [HomeLoading, HomeLoaded]', () async {
    when(() => mockGetCategories(any())).thenAnswer(
      (_) async => Right([tCategory]),
    );
    when(() => mockGetUserProgress(any())).thenAnswer(
      (_) async => Right(tProgress),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadHome('user1');

    expect(await future, [
      const HomeLoading(),
      HomeLoaded(categories: [tCategory], progress: tProgress),
    ]);
  });

  test('loadHome pasa el userId correcto a GetUserProgress', () async {
    when(() => mockGetCategories(any())).thenAnswer(
      (_) async => Right([tCategory]),
    );
    when(() => mockGetUserProgress(any())).thenAnswer(
      (_) async => Right(tProgress),
    );

    await cubit.loadHome('user42');

    verify(() => mockGetUserProgress('user42')).called(1);
  });

  // ── loadHome con fallo de categorías ───────────────────────────────────────

  test('loadHome con fallo en categorías emite [HomeLoading, HomeError]',
      () async {
    when(() => mockGetCategories(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Sin datos')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadHome('user1');

    expect(await future, [const HomeLoading(), const HomeError('Sin datos')]);
    verifyNever(() => mockGetUserProgress(any()));
  });

  // ── loadHome con fallo de progreso ─────────────────────────────────────────

  test('loadHome con fallo en progreso emite [HomeLoading, HomeError]',
      () async {
    when(() => mockGetCategories(any())).thenAnswer(
      (_) async => Right([tCategory]),
    );
    when(() => mockGetUserProgress(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Progreso no encontrado')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadHome('user1');

    expect(await future, [
      const HomeLoading(),
      const HomeError('Progreso no encontrado'),
    ]);
  });

  // ── HomeLoaded contiene los datos correctos ─────────────────────────────────

  test('HomeLoaded contiene las categorías y progreso recibidos', () async {
    when(() => mockGetCategories(any())).thenAnswer(
      (_) async => Right([tCategory]),
    );
    when(() => mockGetUserProgress(any())).thenAnswer(
      (_) async => Right(tProgress),
    );

    await cubit.loadHome('user1');
    await Future.delayed(Duration.zero);

    final loaded = cubit.state as HomeLoaded;
    expect(loaded.categories, [tCategory]);
    expect(loaded.progress, tProgress);
  });
}
