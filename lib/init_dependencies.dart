import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:upsc_blog_app/core/network/connection_checker.dart';
import 'package:upsc_blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:upsc_blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:upsc_blog_app/features/blog/data/datasources/supabase_blog_remote_datasource.dart';
import 'package:upsc_blog_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:upsc_blog_app/features/blog/domain/usecases/fetch_all_blog.dart';
import 'package:upsc_blog_app/features/blog/domain/usecases/upload_blog.dart';

import 'features/auth/data/datasources/auth_supabase_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/user_sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/blog/domain/repository/blog_repository.dart';
import 'features/blog/presentation/bloc/blog_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize Supabase
  await _initSupabase();

  // Register dependencies
  _initAuth();

  // Initialize Blog
  _initBlog();
}

Future<void> _initSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  final supabase = await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
  );

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  // registoring the internet connection checker
  serviceLocator
    ..registerFactory(() => InternetConnection())

    // Hive
    ..registerLazySingleton<Box>(() => Hive.box(name: 'blogs'))

    // add the ConnectionCheckerImpl to the serviceLocator
    ..registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(
        serviceLocator<InternetConnection>(),
      ),
    )
    ..registerLazySingleton(() => supabase.client)
    ..registerLazySingleton(() => AppUserCubit());
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
        serviceLocator<ConnectionChecker>(),
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

void _initBlog() {
  // registerFactory is used to register a factory function that returns a new instance of the BlogRepositoryImpl
  serviceLocator
    ..registerFactory<SupabaseBlogRemoteDatasource>(
      () => SupabaseBlogRemoteDatasourceImpl(
          client: serviceLocator<SupabaseClient>()),
    )
    ..registerFactory<BlogLocalDataSource>(() => BlogLocalDataSourceImpl(
          serviceLocator<Box>(),
        ))
    // registerFactory is used to register a factory function that returns a new instance of the UploadBlog
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        supabaseBlogRemoteDatasource:
            serviceLocator<SupabaseBlogRemoteDatasource>(),
        blogLocalDataSource: serviceLocator<BlogLocalDataSource>(),
        connectionChecker: serviceLocator<ConnectionChecker>(),
      ),
    )
    ..registerFactory(
      () => UploadBlog(
        serviceLocator<BlogRepository>(),
      ),
    )
    ..registerFactory(
      () => FetchAllBlog(
        serviceLocator<BlogRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator<UploadBlog>(),
        fetchAllBlog: serviceLocator<FetchAllBlog>(),
      ),
    );
}
