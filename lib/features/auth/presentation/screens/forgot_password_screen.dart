import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/constants/route_constants.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:movies_app/features/auth/presentation/cubit/password_reset_state.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_app_bar.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:movies_app/shared/widgets/movies_primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();
    return BlocProvider<PasswordResetCubit>(
      create: (context) => dependencies.createPasswordResetCubit(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({super.key});

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onVerifyEmailPressed() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    context.read<PasswordResetCubit>().submit(email);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listener: (context, state) {
        if (state.status == PasswordResetStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent. Please check your inbox.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(RouteConstants.login);
        } else if (state.status == PasswordResetStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to send reset email'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AuthAppBar(
            title: 'Forget Password',
            onBack: state.status == PasswordResetStatus.submitting
                ? () {}
                : () => context.go(RouteConstants.login),
          ),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final illustrationHeight =
                    (constraints.maxWidth * (430 / 430)).clamp(220.0, 430.0);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: illustrationHeight * 0.85,
                          child: Image.asset(
                            'assets/images/auth/forgot_password_illustration.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          enabled: state.status != PasswordResetStatus.submitting,
                        ),
                        const SizedBox(height: 24),
                        MoviesPrimaryButton(
                          label: state.status == PasswordResetStatus.submitting
                              ? 'Sending...'
                              : 'Verify Email',
                          onPressed: state.status == PasswordResetStatus.submitting
                              ? null
                              : _onVerifyEmailPressed,
                        ),
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
