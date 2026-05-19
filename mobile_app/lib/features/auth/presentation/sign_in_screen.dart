import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+923001234567');
    _passwordController = TextEditingController(text: 'Password123');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn(String role) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate standard network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      final phoneEncoded = Uri.encodeComponent(_phoneController.text.trim());
      context.push('${AppRoutes.verifyOtp}?role=$role&phone=$phoneEncoded');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String role = (GoRouterState.of(context).extra as String?) ??
        GoRouterState.of(context).uri.queryParameters['role'] ??
        (args is String ? args : null) ??
        'user';

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role == 'user' ? 'User Login' : 'Provider Login',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Welcome Back', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                const Text('Sign in to continue', style: AppTextStyles.body1),
                const SizedBox(height: 32),
                CustomInput(
                  controller: _phoneController,
                  hintText: 'Phone (+92...)',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.textSecondary),
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
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?',
                        style: AppTextStyles.body1
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: _isLoading ? 'Connecting...' : 'Sign In',
                  isLoading: _isLoading,
                  onPressed: () => _handleSignIn(role),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?',
                        style: AppTextStyles.body1),
                    TextButton(
                      onPressed: () {
                        if (role == 'user') {
                          context.push(AppRoutes.registerUser);
                        } else {
                          context.push(AppRoutes.registerProvider1);
                        }
                      },
                      child: Text('Register',
                          style: AppTextStyles.body1.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
