import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/constants/route_constants.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movies_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_language_switch.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:movies_app/shared/widgets/movies_primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    context.read<AuthCubit>().signInWithEmail(
          email: email,
          password: password,
        );
  }

  void _onGoogleLoginPressed() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(RouteConstants.home);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Authentication failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(19, 24, 19, 24 + bottomInset),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 48),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/splash/app_logo.png',
                          width: 121,
                          height: 118,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 48),
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !state.isSubmitting,
                        ),
                        const SizedBox(height: 22),
                        AuthPasswordField(
                          controller: _passwordController,
                          hintText: 'Password',
                          textInputAction: TextInputAction.done,
                          enabled: !state.isSubmitting,
                        ),
                        const SizedBox(height: 17),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: state.isSubmitting
                                ? null
                                : () => context.go(RouteConstants.forgotPassword),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forget Password ?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        MoviesPrimaryButton(
                          label: state.isSubmitting ? 'Logging in...' : 'Login',
                          onPressed: state.isSubmitting ? null : _onLoginPressed,
                        ),
                        const SizedBox(height: 23),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: AppColors.onBackground,
                            ),
                            children: [
                              const TextSpan(text: 'Don’t Have Account ? '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: state.isSubmitting
                                      ? null
                                      : () => context.go(RouteConstants.register),
                                  child: const Text(
                                    'Create One',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        const _OrDivider(),
                        const SizedBox(height: 28),
                        AuthSocialButton(
                          label: 'Login With Google',
                          iconAssetPath: 'assets/images/auth/google_icon.png',
                          onPressed: state.isSubmitting
                              ? null
                              : _onGoogleLoginPressed,
                        ),
                        const SizedBox(height: 32),
                        const AuthLanguageSwitch(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.primary, thickness: 1.12)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.primary, thickness: 1.12)),
      ],
    );
  }
}
