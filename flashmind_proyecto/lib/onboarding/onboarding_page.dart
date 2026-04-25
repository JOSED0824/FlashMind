import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/router/route_names.dart';

// ── Slide data ────────────────────────────────────────────────────────────────

class _Slide {
  final List<Color> gradientColors;
  final IconData icon;
  final String tag;
  final String headline;
  final String description;

  const _Slide({
    required this.gradientColors,
    required this.icon,
    required this.tag,
    required this.headline,
    required this.description,
  });
}

const _slides = [
  _Slide(
    gradientColors: [Color(0xFF00B8D9), Color(0xFF3AE6C1)],
    icon: Icons.bolt_rounded,
    tag: '¡Bienvenido!',
    headline: 'Aprende en solo\n7 minutos al día',
    description:
        'FlashMind transforma el conocimiento en sesiones cortas y poderosas. Tu cerebro retiene más cuando aprendes en dosis pequeñas.',
  ),
  _Slide(
    gradientColors: [Color(0xFFF97316), Color(0xFFFCD34D)],
    icon: Icons.auto_stories_rounded,
    tag: 'Explora',
    headline: '9 categorías,\ninfinitas ideas',
    description:
        'Historia, Ciencia, Tecnología, Filosofía y más. Elige lo que te apasiona y avanza a tu propio ritmo.',
  ),
  _Slide(
    gradientColors: [Color(0xFFFF6B35), Color(0xFFFF4B8B)],
    icon: Icons.local_fire_department_rounded,
    tag: '¡Tú puedes!',
    headline: 'Construye tu\nracha diaria',
    description:
        'Cada sesión suma puntos y extiende tu racha. La constancia es el verdadero superpoder del aprendizaje.',
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    if (mounted) context.go(RouteNames.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF07131F),
                  slide.gradientColors[0].withValues(alpha: 0.25),
                  const Color(0xFF07131F),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),

          // Decorative blurred circles
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.gradientColors[0].withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.gradientColors[1].withValues(alpha: 0.09),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar: skip button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page counter
                      Text(
                        '${_page + 1} / ${_slides.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // Skip
                      if (!isLast)
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Saltar',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Slides
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, index) =>
                        _SlideContent(slide: _slides[index], active: index == _page),
                  ),
                ),

                // Bottom: dots + button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                  child: Column(
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: i == _page
                                  ? slide.gradientColors[0]
                                  : AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: slide.gradientColors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: slide.gradientColors[0]
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLast ? '¡Empezar ahora!' : 'Siguiente',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLast
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide content widget ──────────────────────────────────────────────────────

class _SlideContent extends StatelessWidget {
  final _Slide slide;
  final bool active;

  const _SlideContent({required this.slide, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tag chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: slide.gradientColors[0].withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: slide.gradientColors[0].withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              slide.tag,
              style: AppTextStyles.caption.copyWith(
                color: slide.gradientColors[0],
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 36),

          // Icon with glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.gradientColors[0].withValues(alpha: 0.45),
                  blurRadius: 48,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              color: Colors.white,
              size: 64,
            ),
          )
              .animate(target: active ? 1 : 0)
              .scaleXY(
                begin: 0.6,
                end: 1.0,
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // Headline
          Text(
            slide.headline,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 20),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(duration: 500.ms, delay: 350.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 350.ms),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
