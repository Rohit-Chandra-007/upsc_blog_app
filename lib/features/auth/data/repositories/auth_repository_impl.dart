import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
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
    return _getUser(() async => await authSupabaseDataSource
        .signUpWithEmailPassword(name: name, email: email, password: password));
  }

  @override
  Future<Either<Failure, User>> signInWithEmailPassword(
      {required String email, required String password}) async {
    return _getUser(() async => await authSupabaseDataSource
        .signInWithEmailPassword(email: email, password: password));
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      final user = await fn();
      return Right(user);
    } on supabase.AuthException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
