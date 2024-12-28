import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/core/usecase/usecase.dart';
import 'package:upsc_blog_app/core/entities/user.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';

class UserSignIn extends UseCase<UserSignInParams, User> {
  AuthRepository authRepository;
  UserSignIn(this.authRepository);
  @override
  Future<Either<Failure, User>> call(UserSignInParams params) async {
    return await authRepository.signInWithEmailPassword(
        email: params.email, password: params.password);
  }
}

class UserSignInParams {
  final String email;
  final String password;

  UserSignInParams({required this.email, required this.password});
}
