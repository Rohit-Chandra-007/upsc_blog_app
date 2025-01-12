import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/core/usecase/usecase.dart';
import 'package:civilshots/core/entities/user.dart';
import 'package:civilshots/features/auth/domain/repository/auth_repository.dart';

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
