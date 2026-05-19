import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+923001234567');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'Password123');
  final _confirmPasswordController = TextEditingController(text: 'Password123');
  
  int _selectedLanguageIndex = 0; // 0 for English, 1 for Urdu
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Store details locally so we can proceed with actual registration in verify OTP
    // Using a delayed simulation or mock backend signup.
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Save user details temporarily for registration in ref / provider if needed, or pass via arguments
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();
      final phoneEncoded = Uri.encodeComponent(phone);
      final nameEncoded = Uri.encodeComponent(name);

      context.push('${AppRoutes.verifyOtp}?role=user&phone=$phoneEncoded&name=$nameEncoded');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
              CustomInput(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _phoneController,
                hintText: 'Phone (+92...)',
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\+92[0-9]{10}$').hasMatch(val.trim())) {
                    return 'Must be format: +92XXXXXXXXX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _emailController,
                hintText: 'Email Address (Optional)',
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (val != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
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
                text: _isLoading ? 'Registering...' : 'Register',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
