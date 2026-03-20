import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
            _usernameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: AppStrings.username,
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.usernameEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: AppStrings.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.isEmpty || !val.contains('@')) {
                    return AppStrings.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: AppStrings.password,
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return AppStrings.passwordTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: AppStrings.confirmPassword,
                controller: _confirmController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (val) {
                  if (val != _passwordController.text) {
                    return AppStrings.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                AppStrings.registerButton,
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              if (state is AuthFailure) ...[
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: AppTextStyles.caption.copyWith(color: AppColors.incorrect),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
