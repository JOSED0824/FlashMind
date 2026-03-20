import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              return _buildContent(state);
            }
            return const AppLoadingIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildContent(HomeLoaded state) {
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
            child: Text('Categorías', style: AppTextStyles.headline),
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

  void _onCategoryTap(CategoryEntity category) {
    context.push(RouteNames.topicSelection, extra: {
      'categoryId': category.id,
      'categoryName': category.name,
      'gradientType': category.gradientType,
    });
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
            children: List.generate(4, (_) => const ShimmerLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 20,
            )),
          ),
        ],
      ),
    );
  }
}
