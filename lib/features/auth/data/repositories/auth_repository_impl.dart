
import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/exception.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/features/auth/data/datasources/auth_supabase_data_source.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseDataSource authSupabaseDataSource;
  const AuthRepositoryImpl(this.authSupabaseDataSource);
  @override
  Future<Either<Failure, String>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final userId = await authSupabaseDataSource.signUpWithEmailPassword(
          name: name, email: email, password: password);
      return Right(userId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> signInWithEmailPassword(
      {required String email, required String password}) {
    // TODO: implement signInWithEmailPassword
    throw UnimplementedError();
  }
}
