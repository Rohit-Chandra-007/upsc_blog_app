
import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/core/usecase/usecase.dart';
import 'package:upsc_blog_app/core/entities/user.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';

class CurrentUser implements UseCase<NoParams, User> {
  AuthRepository authRepository;
  CurrentUser(this.authRepository);
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}
