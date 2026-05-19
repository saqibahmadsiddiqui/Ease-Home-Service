import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class ProviderRegStep3Screen extends ConsumerStatefulWidget {
  const ProviderRegStep3Screen({super.key});

  @override
  ConsumerState<ProviderRegStep3Screen> createState() =>
      _ProviderRegStep3ScreenState();
}

class _ProviderRegStep3ScreenState
    extends ConsumerState<ProviderRegStep3Screen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one availability day')),
      );
      return;
    }

    final startString = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endString = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    ref.read(providerRegStateProvider.notifier).update((state) => {
          ...state,
          'schedule': _selectedDays,
          'startTime': startString,
          'endTime': endString,
        });

    final providerData = ref.read(providerRegStateProvider);
    final phone = providerData['phone'] as String? ?? '+923001234567';
    final name = providerData['name'] as String? ?? 'Provider';

    final phoneEncoded = Uri.encodeComponent(phone);
    final nameEncoded = Uri.encodeComponent(name);

    context.push('${AppRoutes.verifyOtp}?role=provider&phone=$phoneEncoded&name=$nameEncoded');
  }

  @override
  Widget build(BuildContext context) {
    final startTimeStr = _startTime.format(context);
    final endTimeStr = _endTime.format(context);

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
              runSpacing: 8,
              children: _days.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    'Start Time',
                    startTimeStr,
                    () => _selectTime(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(
                    'End Time',
                    endTimeStr,
                    () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Submit Application',
              onPressed: _handleSubmit,
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
      child: const Column(
        children: [
          Icon(Icons.cloud_upload_outlined,
              color: AppColors.primary, size: 32),
          SizedBox(height: 8),
          Text('Upload Done (Simulated)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String timeStr, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timeStr, style: AppTextStyles.body1),
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
