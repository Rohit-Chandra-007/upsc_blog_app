import 'package:flutter/material.dart';
import 'package:upsc_blog_app/features/auth/presentation/screens/signup_screen.dart';

import 'core/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
      home: const SignupScreen(),
    );
  }
}
