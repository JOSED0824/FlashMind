import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/either.dart';
import '../core/constants/app_durations.dart';
import '../core/constants/app_text_styles.dart';
import '../core/router/app_router.dart';
import '../core/router/route_names.dart';
import '../core/theme/app_gradients.dart';
import '../core/widgets/app_loading_indicator.dart';
import '../core/widgets/app_gradient_text.dart';
import '../features/auth/domain/repositories/auth_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(AppDurations.splashDelay);
    if (!mounted) return;

    final authRepo = GetIt.instance<AuthRepository>();
    final result = await authRepo.getCurrentUser();

    if (!mounted) return;

    result.fold((_) => context.go(RouteNames.auth), (user) {
      if (user != null) {
        setCurrentUser(user.id, user.username);
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.auth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.splashBackground,
            ),
          ),
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentStart.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: 0.10),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface.withValues(alpha: 0.85),
                    AppColors.surface2.withValues(alpha: 0.70),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: AppGradients.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentStart.withValues(alpha: 0.5),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ).animate().scaleXY(
                    begin: 0.5,
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 20),
                  GradientText(
                        'FlashMind',
                        style: AppTextStyles.display,
                        gradient: AppGradients.accent,
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.2, delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Aprende en 7 minutos al dia',
                    style: AppTextStyles.caption,
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  const SizedBox(height: 30),
                  const AppLoadingIndicator().animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
