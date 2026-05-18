import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text('Choose your role', style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('How would you like to use the app?', style: AppTextStyles.body1, textAlign: TextAlign.center),
              const SizedBox(height: 48),
              _buildRoleCard(
                context: context,
                title: 'User',
                description: 'I want to book home services',
                icon: Icons.person,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.signIn, arguments: 'user');
                },
              ),
              const SizedBox(height: 24),
              _buildRoleCard(
                context: context,
                title: 'Service Provider',
                description: 'I want to offer my services',
                icon: Icons.work,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.signIn, arguments: 'provider');
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.adminSignIn);
                },
                child: Text('Sign In as Admin', style: AppTextStyles.body1.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.body2),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
