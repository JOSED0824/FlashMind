import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_gradients.dart';
import '../cubit/topic_selection_cubit.dart';
import '../cubit/topic_selection_state.dart';
import '../widgets/topic_card.dart';

class TopicSelectionPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final CategoryGradientType gradientType;

  const TopicSelectionPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.gradientType,
  });

  @override
  State<TopicSelectionPage> createState() => _TopicSelectionPageState();
}

class _TopicSelectionPageState extends State<TopicSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<TopicSelectionCubit>().loadTopics(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppGradients.forCategory(widget.gradientType);
    final accentColor = gradient.colors.first;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF06121D), Color(0xFF0D2537), Color(0xFF143A4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 188,
              pinned: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 70, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Categoria',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.categoryName,
                            style: AppTextStyles.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          BlocBuilder<TopicSelectionCubit, TopicSelectionState>(
                            builder: (context, state) {
                              final count = state is TopicSelectionLoaded
                                  ? state.topics.length
                                  : 0;
                              return Text(
                                '$count temas disponibles',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              backgroundColor: Colors.transparent,
            ),
            BlocBuilder<TopicSelectionCubit, TopicSelectionState>(
              builder: (context, state) {
                if (state is TopicSelectionLoading ||
                    state is TopicSelectionInitial) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is TopicSelectionError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(state.message, style: AppTextStyles.body),
                    ),
                  );
                }
                if (state is TopicSelectionLoaded) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TopicCard(
                          topic: state.topics[index],
                          accentColor: accentColor,
                          onTap: () => context.push(
                            RouteNames.session,
                            extra: {
                              'topicId': state.topics[index].id,
                              'categoryId': widget.categoryId,
                            },
                          ),
                        ),
                        childCount: state.topics.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter();
              },
            ),
          ],
        ),
      ),
    );
  }
}
