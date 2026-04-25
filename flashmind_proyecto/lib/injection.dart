import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/theme_cubit.dart';
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/update_user_photo.dart';
import 'features/auth/domain/usecases/update_username.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/profile_cubit.dart';
import 'services/cloudinary_service.dart';
import 'services/supabase_service.dart';
import 'services/tts_service.dart';

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
  final settingsBox = await Hive.openBox('settings');

  // Register boxes
  sl.registerSingleton<Box<ProgressModel>>(progressBox);
  sl.registerSingleton<Box>(sessionsBox, instanceName: 'sessions');
  sl.registerSingleton<Box>(settingsBox, instanceName: 'settings');

  // ── Theme ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // ── Auth (Firebase) ───────────────────────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(
        clientId: kIsWeb
            ? '259868031727-u4q43o984t4snu1hbda5cgnjnft77l6b.apps.googleusercontent.com'
            : null,
      ));
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(FirebaseAuth.instance, sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => UpdateUserPhoto(sl()));
  sl.registerLazySingleton(() => UpdateUsername(sl()));
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      authRepository: sl(),
    ),
  );

  // ── Cloudinary & Profile ──────────────────────────────────────────────
  sl.registerLazySingleton<CloudinaryService>(
    () => const CloudinaryService(uploadPreset: 'flashmind_profile'),
  );
  sl.registerFactory(
    () => ProfileCubit(
      cloudinaryService: sl(),
      updateUserPhoto: sl(),
      updateUsername: sl(),
    ),
  );

  // ── Supabase ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<SupabaseService>(
    () => SupabaseService(Supabase.instance.client, sl<Box<ProgressModel>>()),
  );
  // ── TTS ──────────────────────────────────────────────────
  sl.registerLazySingleton<TtsService>(() => TtsService());
  // ── Home ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sl<Box<ProgressModel>>()),
  );
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetUserProgress(sl()));
  sl.registerFactory(
    () => HomeCubit(
      getCategories: sl(),
      getUserProgress: sl(),
      supabaseService: sl(),
    ),
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
    () => SessionCubit(
      getQuestionsForTopic: sl(),
      saveSessionResult: sl(),
      homeDataSource: sl(),
      supabaseService: sl(),
    ),
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
