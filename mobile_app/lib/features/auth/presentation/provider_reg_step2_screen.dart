import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderRegStep2Screen extends ConsumerStatefulWidget {
  const ProviderRegStep2Screen({super.key});

  @override
  ConsumerState<ProviderRegStep2Screen> createState() => _ProviderRegStep2ScreenState();
}

class _ProviderRegStep2ScreenState extends ConsumerState<ProviderRegStep2Screen> {
  final List<String> _skills = ['Plumbing', 'Electrical', 'Cleaning', 'Carpentry', 'Painting'];
  final List<String> _selectedSkills = [];
  double _radius = 10;
  int _experience = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skills & Experience'),
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
                Expanded(child: Container(height: 4, color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Select your skills', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.body2.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_selectedSkills.isNotEmpty) ...[
              const Text('Set Rates (Rs. / hr)', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              ..._selectedSkills.map((skill) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text(skill, style: AppTextStyles.body1)),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Rate',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 24),
            ],
            Text('Years of Experience: $_experience', style: AppTextStyles.h3),
            Slider(
              value: _experience.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              activeColor: AppColors.primary,
              label: _experience.toString(),
              onChanged: (val) {
                setState(() {
                  _experience = val.toInt();
                });
              },
            ),
            const SizedBox(height: 24),
            Text('Coverage Radius: ${_radius.toInt()} km', style: AppTextStyles.h3),
            Slider(
              value: _radius,
              min: 1,
              max: 50,
              divisions: 49,
              activeColor: AppColors.primary,
              label: '${_radius.toInt()} km',
              onChanged: (val) {
                setState(() {
                  _radius = val;
                });
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Next',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registerProvider3);
              },
            ),
          ],
        ),
      ),
    );
  }
}
