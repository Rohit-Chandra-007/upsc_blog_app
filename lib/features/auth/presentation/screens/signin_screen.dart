import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsc_blog_app/core/common/widgets/loader.dart';
import 'package:upsc_blog_app/core/routes/route_name.dart';
import 'package:upsc_blog_app/core/themes/app_color_pallete.dart';
import 'package:upsc_blog_app/core/utils/show_snackbar.dart';
import 'package:upsc_blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:upsc_blog_app/features/auth/presentation/widgets/auth_field.dart';

import '../widgets/auth_gradient_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // global key used for form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackbar(context, state.message);
            }
            else if (state is AuthSuccess) {
              context.goNamed(RouteNames.home);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }
            return Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign In. ',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthField(hintText: 'Email', controller: _emailController),
                  const SizedBox(height: 15),
                  AuthField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obsecureText: true),
                  const SizedBox(height: 15),
                  AuthGradientButton(
                    isSignIn: true,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              AuthSignInEvent(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      context.goNamed(RouteNames.signup);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: '''Don't have an account? ''',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppPallete.gradient2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
