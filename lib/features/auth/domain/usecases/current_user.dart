
import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/core/usecase/usecase.dart';
import 'package:civilshots/core/entities/user.dart';
import 'package:civilshots/features/auth/domain/repository/auth_repository.dart';

class CurrentUser implements UseCase<NoParams, User> {
  AuthRepository authRepository;
  CurrentUser(this.authRepository);
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}
