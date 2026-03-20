import '../errors/failures.dart';
import 'either.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
