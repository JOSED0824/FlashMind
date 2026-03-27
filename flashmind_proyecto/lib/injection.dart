import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/home/data/datasources/home_local_data_source.dart';
import 'features/home/data/models/progress_model.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_categories.dart';
import 'features/home/domain/usecases/get_user_progress.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

import 'features/session/data/datasources/questions_local_data_source.dart';
import 'features/session/data/repositories/session_repository_impl.dart';
import 'features/session/domain/repositories/session_repository.dart';
import 'features/session/domain/usecases/get_questions_for_topic.dart';
import 'features/session/domain/usecases/get_topics_by_category.dart';
import 'features/session/domain/usecases/save_session_result.dart';
import 'features/session/presentation/cubit/session_cubit.dart';
import 'features/session/presentation/cubit/topic_selection_cubit.dart';

import 'features/results/data/datasources/results_local_data_source.dart';
import 'features/results/data/repositories/results_repository_impl.dart';
import 'features/results/domain/repositories/results_repository.dart';
import 'features/results/presentation/cubit/results_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await Hive.initFlutter();

  // Register Hive adapters BEFORE opening boxes
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProgressModelAdapter());

  // Open boxes
  final progressBox = await Hive.openBox<ProgressModel>('progress');
  final sessionsBox = await Hive.openBox('sessions');

  // Register boxes
  sl.registerSingleton<Box<ProgressModel>>(progressBox);
  sl.registerSingleton<Box>(sessionsBox, instanceName: 'sessions');

  // ── Auth (Firebase) ───────────────────────────────────────────────────
  // sl.registerLazySingleton<FirebaseAuthDataSource>(
  //   () => FirebaseAuthDataSourceImpl(FirebaseAuth.instance),
  // );
  // sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerFactory(
    () => AuthCubit(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      authRepository: sl(),
    ),
  );

  // ── Home ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sl<Box<ProgressModel>>()),
  );
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetUserProgress(sl()));
  sl.registerFactory(
    () => HomeCubit(getCategories: sl(), getUserProgress: sl()),
  );

  // ── Session ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<QuestionsLocalDataSource>(
    () => QuestionsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl(), sl<Box>(instanceName: 'sessions')),
  );
  sl.registerLazySingleton(() => GetTopicsByCategory(sl()));
  sl.registerLazySingleton(() => GetQuestionsForTopic(sl()));
  sl.registerLazySingleton(() => SaveSessionResult(sl()));
  sl.registerFactory(() => TopicSelectionCubit(getTopicsByCategory: sl()));
  sl.registerFactory(
    () => SessionCubit(getQuestionsForTopic: sl(), saveSessionResult: sl()),
  );

  // ── Results ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<ResultsLocalDataSource>(
    () => ResultsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ResultsRepository>(
    () => ResultsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ResultsCubit(dataSource: sl()));
}
