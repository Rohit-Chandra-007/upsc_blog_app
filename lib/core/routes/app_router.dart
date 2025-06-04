import 'package:civilshots/features/blog/presentation/screens/blog_editor_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:civilshots/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:civilshots/features/auth/presentation/screens/signin_screen.dart';
import 'package:civilshots/features/auth/presentation/screens/signup_screen.dart';
import 'package:civilshots/features/blog/domain/entities/blog.dart';
import 'package:civilshots/features/blog/presentation/screens/add_new_blog_screen.dart';
import 'package:civilshots/features/blog/presentation/screens/blog_reader_screen.dart';
import 'package:civilshots/features/blog/presentation/screens/blog_screen.dart';
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
        builder: (context, state) =>
            BlocSelector<AppUserCubit, AppUserState, bool>(
          selector: (state) => state is AppUserSignedIn,
          builder: (context, isSignedIn) {
            return isSignedIn ? const BlogScreen() : const SigninScreen();
          },
        ),
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
      // Blog routes
      GoRoute(
        path: RoutePaths.blog,
        name: RouteNames.blog,
        builder: (context, state) => const BlogScreen(),
      ),
      GoRoute(
        path: RoutePaths.addNewBlog,
        name: RouteNames.addNewBlog,
        builder: (context, state) => const BlogEditorScreen(),
      ),
      GoRoute(
          path: RoutePaths.blogReader,
          name: RouteNames.blogReader,
          builder: (context, state) {
            // Extract the blog id from the state
            // Retrieve the data from `state.extra` and cast it to the correct type
            final Blog blog = state.extra as Blog;

            return BlogReaderScreen(
              blog: blog,
            );
          }),
    ],
  );
}
