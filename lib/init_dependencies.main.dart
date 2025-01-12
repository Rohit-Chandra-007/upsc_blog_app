part of 'init_dependencies.dart';

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
