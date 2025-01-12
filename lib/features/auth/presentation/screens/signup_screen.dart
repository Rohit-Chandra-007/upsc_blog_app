import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:civilshots/core/common/widgets/loader.dart';
import 'package:civilshots/core/routes/route_name.dart';
import 'package:civilshots/core/themes/app_color_pallete.dart';
import 'package:civilshots/core/utils/show_snackbar.dart';
import 'package:civilshots/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:civilshots/features/auth/presentation/widgets/auth_field.dart';
import 'package:civilshots/features/auth/presentation/widgets/auth_gradient_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // global key used for form

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            context.goNamed(RouteNames.signin);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                showSnackbar(context, state.message);
              } else if (state is AuthSuccess) {
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
                      'Sign Up. ',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AuthField(hintText: 'Name', controller: _nameController),
                    const SizedBox(height: 15),
                    AuthField(hintText: 'Email', controller: _emailController),
                    const SizedBox(height: 15),
                    AuthField(
                        hintText: 'Password',
                        controller: _passwordController,
                        obsecureText: true),
                    const SizedBox(height: 15),
                    AuthGradientButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                AuthSignUpEvent(
                                  name: _nameController.text.trim(),
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
                        context.goNamed(RouteNames.signin);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: '''Already have an account? ''',
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
      ),
    );
  }
}
