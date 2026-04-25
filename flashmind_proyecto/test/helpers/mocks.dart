import 'package:flashmind_proyecto/features/auth/domain/repositories/auth_repository.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/login_user.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/logout_user.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/register_user.dart';
import 'package:flashmind_proyecto/features/home/data/datasources/home_local_data_source.dart';
import 'package:flashmind_proyecto/features/home/domain/repositories/home_repository.dart';
import 'package:flashmind_proyecto/features/home/domain/usecases/get_categories.dart';
import 'package:flashmind_proyecto/features/home/domain/usecases/get_user_progress.dart';
import 'package:flashmind_proyecto/features/results/data/datasources/results_local_data_source.dart';
import 'package:flashmind_proyecto/features/session/domain/repositories/session_repository.dart';
import 'package:flashmind_proyecto/features/session/domain/usecases/get_questions_for_topic.dart';
import 'package:flashmind_proyecto/features/session/domain/usecases/get_topics_by_category.dart';
import 'package:flashmind_proyecto/features/session/domain/usecases/save_session_result.dart';
import 'package:flashmind_proyecto/services/supabase_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUser extends Mock implements LoginUser {}

class MockRegisterUser extends Mock implements RegisterUser {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockHomeRepository extends Mock implements HomeRepository {}

class MockGetCategories extends Mock implements GetCategories {}

class MockGetUserProgress extends Mock implements GetUserProgress {}

class MockHomeLocalDataSource extends Mock implements HomeLocalDataSource {}

class MockSupabaseService extends Mock implements SupabaseService {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockGetQuestionsForTopic extends Mock implements GetQuestionsForTopic {}

class MockGetTopicsByCategory extends Mock implements GetTopicsByCategory {}

class MockSaveSessionResult extends Mock implements SaveSessionResult {}

class MockResultsLocalDataSource extends Mock
    implements ResultsLocalDataSource {}
