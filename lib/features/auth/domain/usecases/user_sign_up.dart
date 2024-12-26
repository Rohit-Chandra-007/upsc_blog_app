import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/core/usecase/usecase.dart';
import 'package:upsc_blog_app/features/auth/domain/entities/user.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';

class UserSignUp implements UseCase<UserSignUpParams, User> {
 final AuthRepository authRepository;
 const  UserSignUp(this.authRepository);
  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async{
    return await authRepository.signUpWithEmailPassword(
        name: params.name, email: params.email, password: params.password);
  }
}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;

  UserSignUpParams(
      {required this.name, required this.email, required this.password});
}
