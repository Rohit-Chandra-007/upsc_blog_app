import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/current_user.dart';
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

  // core dependency
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
}

void _initAuth() {
  // registerFactory is used to register a factory function that returns a new instance of the AuthSupabaseDataSourceImpl
  serviceLocator
    ..registerFactory<AuthSupabaseDataSource>(
      () => AuthSupabaseDataSourceImpl(
        serviceLocator<SupabaseClient>(),
      ),
    )
    // registerFactory is used to register a factory function that returns a new instance of the AuthRepositoryImpl
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator<AuthSupabaseDataSource>(),
      ),
    )
    // registerFactory is used to register a factory function that returns a new instance of the UserSignUp
    ..registerFactory(
      () => UserSignUp(
        serviceLocator<AuthRepository>(),
      ),
    )
    // registerFactory is used to register a factory function that returns a new instance of the UserSignIn
    ..registerFactory(
      () => UserSignIn(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator<AuthRepository>(),
      ),
    )
    // registerLazySingleton is used to register a singleton instance of the AuthBloc
    ..registerLazySingleton(
      () => AuthBloc(
          userSignup: serviceLocator<UserSignUp>(),
          userSignIn: serviceLocator<UserSignIn>(),
          currentUser: serviceLocator<CurrentUser>(),
          appUserCubit: serviceLocator<AppUserCubit>()),
    );
}
