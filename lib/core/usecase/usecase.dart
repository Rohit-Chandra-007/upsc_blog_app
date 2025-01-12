import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/failures.dart';

abstract class UseCase<Params, Result> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {}
