import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/no_params.dart';
import '../../../../services/supabase_service.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_user_progress.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategories _getCategories;
  final GetUserProgress _getUserProgress;
  final SupabaseService _supabaseService;

  HomeCubit({
    required GetCategories getCategories,
    required GetUserProgress getUserProgress,
    required SupabaseService supabaseService,
  })  : _getCategories = getCategories,
        _getUserProgress = getUserProgress,
        _supabaseService = supabaseService,
        super(const HomeInitial());

  Future<void> loadHome(String userId) async {
    emit(const HomeLoading());

    final categoriesResult = await _getCategories(const NoParams());

    if (categoriesResult.isLeft) {
      emit(HomeError(categoriesResult.left.message));
      return;
    }

    // Sync with Supabase (merge cloud + local, save both) — silent on failure
    await _supabaseService.syncProgress(userId);

    final progressResult = await _getUserProgress(userId);

    if (progressResult.isLeft) {
      emit(HomeError(progressResult.left.message));
      return;
    }

    emit(HomeLoaded(
      categories: categoriesResult.right,
      progress: progressResult.right,
    ));
  }
}
