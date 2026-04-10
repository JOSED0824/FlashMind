import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../../../../../core/widgets/shimmer_loader.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/categories_grid.dart';
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
            colors: [
              const Color(0xFF07131F),
              const Color(0xFF0B2032),
              const Color(0xFF102C42).withValues(alpha: 0.96),
            ],
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
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
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
          onDestinationSelected: (index) {
            setState(() => _selectedTab = index);
          },
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categorias', style: AppTextStyles.headline),
                const SizedBox(height: 4),
                Text(
                  'Elige un tema y completa una sesion de 7 minutos.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoriesGrid(
            categories: state.categories,
            onCategoryTap: (category) => _onCategoryTap(category),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(HomeLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perfil', style: AppTextStyles.headline),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface.withValues(alpha: 0.95),
                  AppColors.surface2.withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.accentStart.withValues(alpha: 0.2),
                  child: Text(
                    widget.username.isNotEmpty
                        ? widget.username[0].toUpperCase()
                        : 'U',
                    style: AppTextStyles.headline,
                  ),
                ),
                const SizedBox(height: 10),
                Text(widget.username, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text('ID: ${widget.userId}', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.star_rounded,
            title: 'Puntos totales',
            value: '${state.progress.totalPoints}',
          ),
          _InfoTile(
            icon: Icons.check_circle_rounded,
            title: 'Sesiones completadas',
            value: '${state.progress.totalSessions}',
          ),
          _InfoTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Racha actual',
            value: '${state.progress.currentStreak} dias',
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
          Text('Ajustes', style: AppTextStyles.headline),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.palette_rounded,
            title: 'Tema visual',
            value: 'Modo oscuro personalizado',
          ),
          _InfoTile(
            icon: Icons.notifications_rounded,
            title: 'Recordatorios',
            value: 'Activados',
          ),
          _InfoTile(
            icon: Icons.language_rounded,
            title: 'Idioma',
            value: 'Espanol',
          ),
          _InfoTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacidad',
            value: 'Gestionar permisos',
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
    return Padding(
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
              Expanded(
                child: ShimmerLoader(
                  width: double.infinity,
                  height: 80,
                  borderRadius: 14,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ShimmerLoader(
                  width: double.infinity,
                  height: 80,
                  borderRadius: 14,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ShimmerLoader(
                  width: double.infinity,
                  height: 80,
                  borderRadius: 14,
                ),
              ),
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
                borderRadius: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
