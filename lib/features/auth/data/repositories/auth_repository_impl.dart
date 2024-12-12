
import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/exception.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/features/auth/data/datasources/auth_supabase_data_source.dart';
import 'package:upsc_blog_app/features/auth/domain/entities/user.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseDataSource authSupabaseDataSource;
  const AuthRepositoryImpl(this.authSupabaseDataSource);
  @override
  Future<Either<Failure, User>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final user = await authSupabaseDataSource.signUpWithEmailPassword(
          name: name, email: email, password: password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailPassword(
      {required String email, required String password}) {
    // TODO: implement signInWithEmailPassword
    throw UnimplementedError();
  }
}
