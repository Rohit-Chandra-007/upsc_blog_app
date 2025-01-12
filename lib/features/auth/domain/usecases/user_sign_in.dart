import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/core/usecase/usecase.dart';
import 'package:civilshots/core/entities/user.dart';
import 'package:civilshots/features/auth/domain/repository/auth_repository.dart';

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
