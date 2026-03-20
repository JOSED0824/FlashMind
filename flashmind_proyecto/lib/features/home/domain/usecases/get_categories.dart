import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/no_params.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

class GetCategories implements UseCase<List<CategoryEntity>, NoParams> {
  final HomeRepository repository;
  const GetCategories(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) {
    return repository.getCategories();
  }
}
