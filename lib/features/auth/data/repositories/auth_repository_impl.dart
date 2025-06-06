import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/exception.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/core/network/connection_checker.dart';
import 'package:civilshots/features/auth/data/datasources/auth_supabase_data_source.dart';
import 'package:civilshots/core/entities/user.dart';
import 'package:civilshots/features/auth/data/models/user_model.dart';
import 'package:civilshots/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseDataSource authSupabaseDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(this.authSupabaseDataSource, this.connectionChecker);

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

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = authSupabaseDataSource.currentUserSession;
        if (session == null) {
          return Left(NetworkFailure('User is not logged in'));
        }

        return Right(UserModel(
            id: session.user.id, email: session.user.email!, name: ''));
      }
      final user = await authSupabaseDataSource.getUserCurrentData();
      if (user == null) {
        return Left(NetworkFailure('User is not logged in'));
      }
      return Right(user);
    }  on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return Left(NetworkFailure('No internet connection'));
      }
      final user = await fn();
      return Right(user);
    }  on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
