import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_input.dart';

class AdminSignInScreen extends ConsumerWidget {
  const AdminSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security, size: 60, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 32),
              Text('Admin Access', style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Restricted Area', style: AppTextStyles.body1.copyWith(color: AppColors.error), textAlign: TextAlign.center),
              const SizedBox(height: 48),
              const CustomInput(
                hintText: 'Admin Email',
                prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const CustomInput(
                hintText: 'Password',
                obscureText: true,
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const CustomInput(
                hintText: '4-Digit PIN',
                obscureText: true,
                keyboardType: TextInputType.number,
                prefixIcon: Icon(Icons.dialpad, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminDashboard, (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Authenticate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
