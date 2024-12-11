import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/core/secretes/app_secretes.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';

import 'features/auth/data/datasources/auth_supabase_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/user_sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: AppSecretes.supabaseUrl,
    anonKey: AppSecretes.supabaseKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
}

void _initAuth() {
  serviceLocator.registerFactory<AuthSupabaseDataSource>(
    () => AuthSupabaseDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserSignUp(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignup: serviceLocator(),
    ),
  );
}
