import 'package:go_router/go_router.dart';

import 'package:upsc_blog_app/features/auth/presentation/screens/signin_screen.dart';
import 'package:upsc_blog_app/features/auth/presentation/screens/signup_screen.dart';

import 'route_name.dart';

class AppRouterConfig {
  // Create the router configuration
  // Helpful for debugging
  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const SigninScreen(),
      ),
      // Auth routes
      GoRoute(
        path: RoutePaths.signin,
        name: RouteNames.signin,
        builder: (context, state) => const SigninScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),


    ],
  );
}
