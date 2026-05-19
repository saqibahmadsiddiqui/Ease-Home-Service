import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderRegStep3Screen extends ConsumerWidget {
  const ProviderRegStep3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification'),
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
                Expanded(child: Container(height: 4, color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Document Upload', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            _buildUploadBox('CNIC Front'),
            const SizedBox(height: 16),
            _buildUploadBox('CNIC Back'),
            const SizedBox(height: 16),
            _buildUploadBox('Certificates (Optional)'),
            const SizedBox(height: 24),
            const Text('Availability Schedule', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                return Chip(label: Text(day), backgroundColor: AppColors.surface);
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTimePicker('Start Time', '09:00 AM')),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker('End Time', '05:00 PM')),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Submit Application',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.verifyOtp);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text('Upload $title', style: AppTextStyles.body1),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: AppTextStyles.body1),
              const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}
