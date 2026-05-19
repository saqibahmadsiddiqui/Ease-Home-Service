import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../providers/auth_provider.dart';

class ProviderRegStep1Screen extends ConsumerStatefulWidget {
  const ProviderRegStep1Screen({super.key});

  @override
  ConsumerState<ProviderRegStep1Screen> createState() =>
      _ProviderRegStep1ScreenState();
}

class _ProviderRegStep1ScreenState extends ConsumerState<ProviderRegStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+923001234567');
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController(text: 'Password123');
  String? _selectedCity;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    ref.read(providerRegStateProvider.notifier).update((state) => {
          ...state,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'cnic': _cnicController.text.trim(),
          'city': _selectedCity,
          'password': _passwordController.text,
        });

    context.push(AppRoutes.registerProvider2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 4, color: AppColors.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, color: AppColors.border)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Personal Details', style: AppTextStyles.h2),
              const SizedBox(height: 24),
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
                controller: _cnicController,
                hintText: 'CNIC Number',
                prefixIcon: const Icon(Icons.badge_outlined),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your CNIC';
                  }
                  if (val.trim().length < 13) {
                    return 'CNIC must be at least 13 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'City',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: ['Lahore', 'Karachi', 'Islamabad'].map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                validator: (val) => val == null ? 'Please select a city' : null,
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
              const SizedBox(height: 32),
              CustomButton(
                text: 'Next',
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
