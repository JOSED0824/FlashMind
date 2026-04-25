import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/widgets/fire_streak_widget.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final int streak;
  final String? photoUrl;

  const HomeHeader({
    super.key,
    required this.username,
    required this.streak,
    this.photoUrl,
  });

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
            context.acSurface.withValues(alpha: 0.96),
            context.acSurface2.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.acBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    AppColors.accentStart.withValues(alpha: 0.95),
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? Text(
                        initial,
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
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
                        color: context.acTextSub,
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
                  color: context.acSurface2,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.acBorder),
                ),
                child: Icon(
                  Icons.account_circle_rounded,
                  color: context.acText,
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
                    gradient: streak > 0
                        ? LinearGradient(
                            colors: streak >= 7
                                ? [
                                    const Color(0xFFFF4500)
                                        .withValues(alpha: 0.25),
                                    const Color(0xFFFF6B00)
                                        .withValues(alpha: 0.10),
                                  ]
                                : streak >= 3
                                    ? [
                                        const Color(0xFFFF8C00)
                                            .withValues(alpha: 0.22),
                                        AppColors.warning
                                            .withValues(alpha: 0.08),
                                      ]
                                    : [
                                        AppColors.warning
                                            .withValues(alpha: 0.18),
                                        AppColors.warning
                                            .withValues(alpha: 0.06),
                                      ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color: streak > 0 ? null : context.acSurface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: streak >= 7
                          ? const Color(0xFFFF4500).withValues(alpha: 0.50)
                          : streak >= 3
                              ? const Color(0xFFFF8C00).withValues(alpha: 0.45)
                              : streak > 0
                                  ? AppColors.warning.withValues(alpha: 0.4)
                                  : context.acBorder,
                    ),
                    boxShadow: streak > 0
                        ? [
                            BoxShadow(
                              color: (streak >= 7
                                      ? const Color(0xFFFF4500)
                                      : streak >= 3
                                          ? const Color(0xFFFF8C00)
                                          : AppColors.warning)
                                  .withValues(alpha: 0.30),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FireStreakWidget(streak: streak, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        streak > 0
                            ? '$streak ${streak == 1 ? 'día' : 'días'} de racha'
                            : 'Empieza hoy tu racha',
                        style: AppTextStyles.label.copyWith(
                          color: streak > 0
                              ? AppColors.warning
                              : context.acTextSub,
                          fontWeight: streak > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
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
