import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';

class UserRegistrationScreen extends ConsumerStatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  ConsumerState<UserRegistrationScreen> createState() =>
      _UserRegistrationScreenState();
}

class _UserRegistrationScreenState
    extends ConsumerState<UserRegistrationScreen> {
  int _selectedLanguageIndex = 0; // 0 for English, 1 for Urdu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.person,
                        size: 50, color: AppColors.textSecondary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const CustomInput(
                hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
            const SizedBox(height: 16),
            const CustomInput(
                hintText: 'Phone (+92)',
                prefixIcon: Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const CustomInput(
                hintText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const CustomInput(
                hintText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                obscureText: true),
            const SizedBox(height: 16),
            const CustomInput(
                hintText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
                obscureText: true),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Language Preference:', style: AppTextStyles.body1),
                const SizedBox(width: 16),
                ToggleButtons(
                  isSelected: [
                    _selectedLanguageIndex == 0,
                    _selectedLanguageIndex == 1
                  ],
                  onPressed: (index) {
                    setState(() {
                      _selectedLanguageIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: AppColors.primary,
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('EN')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('UR')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.verifyOtp);
              },
            ),
          ],
        ),
      ),
    );
  }
}
