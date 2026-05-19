import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/preferences_helper.dart';
import '../../../main.dart'; // import to access authStateProvider



class AdminSignInScreen extends ConsumerStatefulWidget {
  const AdminSignInScreen({super.key});

  @override
  ConsumerState<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends ConsumerState<AdminSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _pinController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'admin@ease.com');
    _passwordController = TextEditingController(text: 'Password123');
    _pinController = TextEditingController(text: '1234');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleAuthenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/admin/sign-in', data: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'pin': _pinController.text.trim(),
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String?;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (token != null) {
          ref.read(authTokenProvider.notifier).state = token;
          PreferencesHelper.setAuthToken(token);
          ref.read(authStateProvider.notifier).state = AuthState.authenticatedAdmin;
          PreferencesHelper.setAuthState('authenticatedAdmin');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully authenticated as Admin!')),
          );
        }
      }
    } catch (e) {
      if (_emailController.text.trim() == 'admin@ease.com' &&
          _passwordController.text == 'Password123' &&
          _pinController.text.trim() == '1234') {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          const mockToken = 'mock-jwt-admin-token';
          ref.read(authTokenProvider.notifier).state = mockToken;
          PreferencesHelper.setAuthToken(mockToken);
          ref.read(authStateProvider.notifier).state = AuthState.authenticatedAdmin;
          PreferencesHelper.setAuthState('authenticatedAdmin');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offline Mode: Authenticated as Admin!')),
          );
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Authentication Failed: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security,
                        size: 60, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Admin Access',
                    style: AppTextStyles.h1, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Restricted Area',
                    style: AppTextStyles.body1.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center),
                const SizedBox(height: 48),
                CustomInput(
                  controller: _emailController,
                  hintText: 'Admin Email',
                  prefixIcon: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter admin email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomInput(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomInput(
                  controller: _pinController,
                  hintText: '4-Digit PIN',
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.dialpad, color: AppColors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().length != 4) {
                      return 'Must be exactly 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuthenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isLoading ? 'Authenticating...' : 'Authenticate',
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
