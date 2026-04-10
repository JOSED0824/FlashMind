import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final int streak;

  const HomeHeader({super.key, required this.username, required this.streak});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos dias,';
    if (hour < 18) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  @override
  Widget build(BuildContext context) {
    final initial = username.trim().isNotEmpty
        ? username.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surface2.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentStart.withValues(alpha: 0.95),
                      AppColors.accentEnd.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting, style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(username, style: AppTextStyles.headline),
                    const SizedBox(height: 2),
                    Text(
                      'Perfil activo',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: streak > 0
                        ? AppColors.warning.withValues(alpha: 0.18)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: streak > 0
                          ? AppColors.warning.withValues(alpha: 0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        streak > 0
                            ? Icons.local_fire_department_rounded
                            : Icons.bolt_rounded,
                        color: streak > 0
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        streak > 0
                            ? '$streak dias de racha'
                            : 'Empieza hoy tu racha',
                        style: AppTextStyles.label.copyWith(
                          color: streak > 0
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
