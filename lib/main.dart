import 'package:flutter/material.dart';
import 'package:upsc_blog_app/core/routes/app_router.dart'; // Add this import

import 'core/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
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
