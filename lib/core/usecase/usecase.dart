import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/failures.dart';

abstract class UseCase<Params, Result> {
  Future<Either<Failure, Result>> call(Params params);
}
