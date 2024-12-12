import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/core/error/exception.dart';
import 'package:upsc_blog_app/features/auth/data/models/user_model.dart';

abstract interface class AuthSupabaseDataSource {
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  SupabaseClient supabaseClient;
  AuthSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signInWithEmailPassword(
      {required String email, required String password}) {
    // TODO: implement signUpWithEmailPassword
    throw UnimplementedError();
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
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
