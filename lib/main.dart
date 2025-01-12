import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:civilshots/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:civilshots/core/routes/app_router.dart';
import 'package:civilshots/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:civilshots/init_dependencies.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/services/logger_service.dart';

void main() async {
  try {
    logger.info('Application starting...');
    WidgetsFlutterBinding.ensureInitialized();

    // Load .env from assets
    await dotenv.load(fileName: 'assets/.env');

    if (dotenv.env['SUPABASE_URL'] == null ||
        dotenv.env['SUPABASE_ANON_KEY'] == null) {
      throw Exception('Environment variables not found');
    }
    await initDependencies();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<AppUserCubit>(),
          ),
          BlocProvider(
            create: (context) => serviceLocator<AuthBloc>(),
          ),
          BlocProvider(
            create: (context) => serviceLocator<BlogBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.error('Error during app initialization', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthIsUserSignedInEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Initialize AppRouter
    return MaterialApp.router(
      title: 'Blog App',
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouterConfig.router, // Update this line
    );
  }
}
