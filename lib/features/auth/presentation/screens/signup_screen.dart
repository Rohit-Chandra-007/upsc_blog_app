import 'package:flutter/material.dart';
import 'package:upsc_blog_app/core/themes/app_color_pallete.dart';
import 'package:upsc_blog_app/features/auth/presentation/widgets/auth_field.dart';
import 'package:upsc_blog_app/features/auth/presentation/widgets/auth_gradient_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign Up. ',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const AuthField(hintText: 'Name'),
            const SizedBox(height: 15),
            const AuthField(hintText: 'Email'),
            const SizedBox(height: 15),
            const AuthField(hintText: 'Password'),
            const SizedBox(height: 15),
            const AuthGradientButton(),
            const SizedBox(height: 15),
            RichText(
              text: TextSpan(
                text: '''Don't have an account? ''',
                style: Theme.of(context).textTheme.titleMedium,
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppPallete.gradient2,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
