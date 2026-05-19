import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';

class ProviderRegStep1Screen extends ConsumerWidget {
  const ProviderRegStep1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
            const CustomInput(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
            const SizedBox(height: 16),
            const CustomInput(hintText: 'Phone (+92)', prefixIcon: Icon(Icons.phone_outlined), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const CustomInput(hintText: 'CNIC Number', prefixIcon: Icon(Icons.badge_outlined), keyboardType: TextInputType.number),
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
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const CustomInput(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline), obscureText: true),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Next',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registerProvider2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
