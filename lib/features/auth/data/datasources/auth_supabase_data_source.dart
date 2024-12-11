import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/core/error/exception.dart';

abstract interface class AuthSupabaseDataSource {
  Future<String> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<String> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  SupabaseClient supabaseClient;
  AuthSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<String> signInWithEmailPassword(
      {required String email, required String password}) {
    // TODO: implement signUpWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<String> signUpWithEmailPassword(
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
      return response.user!.id;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
