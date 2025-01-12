import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:civilshots/core/error/exception.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/features/auth/data/models/user_model.dart';

abstract interface class AuthSupabaseDataSource {
  Session? get currentUserSession;
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel?> getUserCurrentData();
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  SupabaseClient supabaseClient;
  AuthSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signInWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw ServerException(message: 'User is Null!');
      }

      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw NetworkFailure(e.message);
    } on StorageException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'name': name},
      );
      if (response.user == null) {
        throw ServerException(message: 'User is Null!');
      }

      return UserModel.fromJson(response.user!.toJson());
    }on AuthException catch (e) {
      throw NetworkFailure(e.message);
    } on StorageException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getUserCurrentData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id);
        return UserModel.fromJson(userData.first).copyWith(
          email: currentUserSession!.user.email,
        );
      }
      return null;
    } on AuthException catch (e) {
      throw NetworkFailure(e.message);
    } on StorageException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
