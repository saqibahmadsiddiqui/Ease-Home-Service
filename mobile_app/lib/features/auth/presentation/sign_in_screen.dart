import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String role = ModalRoute.of(context)?.settings.arguments as String? ?? 'user';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role == 'user' ? 'User Login' : 'Provider Login',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Welcome Back', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              const Text('Sign in to continue', style: AppTextStyles.body1),
              const SizedBox(height: 32),
              const CustomInput(
                hintText: 'Email or Phone Number',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const CustomInput(
                hintText: 'Password',
                obscureText: true,
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password?', style: AppTextStyles.body1.copyWith(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign In',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.verifyOtp);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?', style: AppTextStyles.body1),
                  TextButton(
                    onPressed: () {
                      if (role == 'user') {
                        Navigator.pushNamed(context, AppRoutes.registerUser);
                      } else {
                        Navigator.pushNamed(context, AppRoutes.registerProvider1);
                      }
                    },
                    child: Text('Register', style: AppTextStyles.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
