
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upsc_blog_app/core/routes/app_router.dart'; // Add this import
import 'package:upsc_blog_app/init_dependencies.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load .env from assets
    await dotenv.load(fileName: 'assets/.env');

    print('Loading environment variables...');
    if (dotenv.env['SUPABASE_URL'] == null ||
        dotenv.env['SUPABASE_ANON_KEY'] == null) {
      throw Exception('Environment variables not found');
    }
    await initDependencies();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<AuthBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
