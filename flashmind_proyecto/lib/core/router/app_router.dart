import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../onboarding/onboarding_page.dart';
import '../../features/results/presentation/cubit/results_cubit.dart';
import '../../features/results/presentation/pages/results_page.dart';
import '../../features/session/domain/entities/session_result_entity.dart';
import '../../features/session/presentation/cubit/session_cubit.dart';
import '../../features/session/presentation/cubit/topic_selection_cubit.dart';
import '../../features/session/presentation/pages/session_page.dart';
import '../../features/session/presentation/pages/topic_selection_page.dart';
import '../../injection.dart';
import '../../splash/splash_page.dart';
import '../theme/app_gradients.dart';
import 'route_names.dart';

// Stored after login so pages can access it
String _currentUserId = '';
String _currentUsername = '';

void setCurrentUser(String id, String username) {
  _currentUserId = id;
  _currentUsername = username;
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (_, state) => BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const AuthPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (_, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider(create: (_) => sl<HomeCubit>()),
              BlocProvider(create: (_) => sl<ProfileCubit>()),
            ],
            child: HomePage(
              userId: _currentUserId,
              username: _currentUsername,
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'topics',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>;
              final categoryId = extra['categoryId'] as String;
              final categoryName = extra['categoryName'] as String;
              final gradientType = extra['gradientType'] as CategoryGradientType;
              return BlocProvider(
                create: (_) => sl<TopicSelectionCubit>(),
                child: TopicSelectionPage(
                  categoryId: categoryId,
                  categoryName: categoryName,
                  gradientType: gradientType,
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'session',
                builder: (_, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return BlocProvider(
                    create: (_) => sl<SessionCubit>(),
                    child: SessionPage(
                      topicId: extra['topicId'] as String,
                      categoryId: extra['categoryId'] as String,
                      userId: _currentUserId,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'results',
                    builder: (_, state) {
                      final result = state.extra as SessionResultEntity;
                      return BlocProvider(
                        create: (_) => sl<ResultsCubit>(),
                        child: ResultsPage(result: result),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
}
