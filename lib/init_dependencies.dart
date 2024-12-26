import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/user_sign_in.dart';

import 'features/auth/data/datasources/auth_supabase_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/user_sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize Supabase
  await _initSupabase();

  // Register dependencies
  _initAuth();
}

Future<void> _initSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  final supabase = await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
  );

  serviceLocator.registerLazySingleton(() => supabase
      .client); // registerLazySingleton is used to register a singleton instance of the client
}

void _initAuth() {
  // registerFactory is used to register a factory function that returns a new instance of the AuthSupabaseDataSourceImpl
  serviceLocator.registerFactory<AuthSupabaseDataSource>(
    () => AuthSupabaseDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator<AuthSupabaseDataSource>(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserSignUp(
      serviceLocator<AuthRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignup: serviceLocator<UserSignUp>(),
      userSignIn: serviceLocator<UserSignIn>(),
    ),
  );
}
