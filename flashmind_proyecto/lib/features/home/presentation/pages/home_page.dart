import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../core/utils/no_params.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../../../../../core/widgets/shimmer_loader.dart';
import '../../../../../injection.dart';
import '../../../../../features/auth/domain/usecases/logout_user.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/categories_grid.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/stats_row.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String username;

  const HomePage({super.key, required this.userId, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  String _selectedFilter = 'Todas';

  static const _filters = [
    'Todas',
    'Historia',
    'Ciencia',
    'Idiomas',
    'Tecnología',
    'Matemáticas',
    'Arte y Cultura',
    'Geografía',
    'Filosofía',
    'Economía',
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.acBg, context.acBgMid, context.acBgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return _buildShimmer();
              }
              if (state is HomeError) {
                return Center(
                  child: Text(state.message, style: AppTextStyles.body),
                );
              }
              if (state is HomeLoaded) {
                return _buildTabContent(state);
              }
              return const AppLoadingIndicator();
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: context.acNavBar.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.acBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedTab,
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 62,
          indicatorColor: AppColors.accentStart.withValues(alpha: 0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _selectedTab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(HomeLoaded state) {
    return IndexedStack(
      index: _selectedTab,
      children: [
        _buildHomeContent(state),
        _buildProfileContent(state),
        _buildSettingsContent(),
      ],
    );
  }

  Widget _buildHomeContent(HomeLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: HomeHeader(
            username: widget.username,
            streak: state.progress.currentStreak,
          ),
        ),
        SliverToBoxAdapter(child: StatsRow(progress: state.progress)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categorías',
                    style: AppTextStyles.headline
                        .copyWith(color: context.acText)),
                const SizedBox(height: 4),
                Text(
                  'Elige un tema y completa una sesión de aprendizaje.',
                  style:
                      AppTextStyles.caption.copyWith(color: context.acTextSub),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryFilterBar(
            selectedFilter: _selectedFilter,
            filters: _filters,
            onFilterSelected: (f) => setState(() => _selectedFilter = f),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoriesGrid(
            categories: _selectedFilter == 'Todas'
                ? state.categories
                : state.categories
                    .where((c) => c.name == _selectedFilter)
                    .toList(),
            onCategoryTap: _onCategoryTap,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(HomeLoaded state) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final photoUrl = firebaseUser?.photoURL;
    final email = firebaseUser?.email ?? '';
    final completedTopics = state.progress.completedTopicIds.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perfil',
              style: AppTextStyles.headline.copyWith(color: context.acText)),
          const SizedBox(height: 16),
          // Avatar card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.acSurface,
                  context.acSurface2,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.acBorder),
            ),
            child: Column(
              children: [
                // Avatar con foto de Google o inicial
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      AppColors.accentStart.withValues(alpha: 0.2),
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(
                          widget.username.isNotEmpty
                              ? widget.username[0].toUpperCase()
                              : 'U',
                          style: AppTextStyles.display
                              .copyWith(color: AppColors.accentStart),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(widget.username,
                    style: AppTextStyles.title
                        .copyWith(color: context.acText)),
                const SizedBox(height: 4),
                Text(email,
                    style: AppTextStyles.caption
                        .copyWith(color: context.acTextSub)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Estadísticas en grid 2x2
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.0,
            children: [
              _StatCard(
                icon: Icons.star_rounded,
                label: 'Puntos',
                value: '${state.progress.totalPoints}',
                color: AppColors.warning,
              ),
              _StatCard(
                icon: Icons.check_circle_rounded,
                label: 'Sesiones',
                value: '${state.progress.totalSessions}',
                color: AppColors.correct,
              ),
              _StatCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Racha',
                value: '${state.progress.currentStreak} días',
                color: const Color(0xFFFF6B35),
              ),
              _StatCard(
                icon: Icons.school_rounded,
                label: 'Temas vistos',
                value: '$completedTopics',
                color: AppColors.accentStart,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajustes',
              style:
                  AppTextStyles.headline.copyWith(color: context.acText)),
          const SizedBox(height: 20),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return _SettingsTile(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: 'Tema visual',
                subtitle: isDark ? 'Modo oscuro' : 'Modo claro',
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) =>
                      context.read<ThemeCubit>().toggleTheme(),
                  activeThumbColor: AppColors.accentStart,
                  activeTrackColor:
                      AppColors.accentStart.withValues(alpha: 0.35),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.incorrect),
              label: Text(
                'Cerrar sesión',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.incorrect),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.incorrect),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                await sl<LogoutUser>()(const NoParams());
                if (context.mounted) context.go(RouteNames.auth);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(CategoryEntity category) {
    context.push(
      RouteNames.topicSelection,
      extra: {
        'categoryId': category.id,
        'categoryName': category.name,
        'gradientType': category.gradientType,
      },
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(width: 160, height: 28, borderRadius: 8),
          const SizedBox(height: 8),
          const ShimmerLoader(width: 120, height: 18, borderRadius: 6),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: ShimmerLoader(width: double.infinity, height: 80, borderRadius: 14)),
              SizedBox(width: 10),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 80, borderRadius: 14)),
              SizedBox(width: 10),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 80, borderRadius: 14)),
            ],
          ),
          const SizedBox(height: 28),
          const ShimmerLoader(width: 120, height: 24, borderRadius: 6),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: List.generate(
              4,
              (_) => const ShimmerLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card para el perfil ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.acSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.acBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: AppTextStyles.label
                        .copyWith(color: context.acText, fontSize: 15)),
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: context.acTextSub, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.acSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.acBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentStart.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentStart, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.label
                        .copyWith(color: context.acText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: context.acTextSub)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
