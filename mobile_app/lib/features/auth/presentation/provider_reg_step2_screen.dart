import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class ProviderRegStep2Screen extends ConsumerStatefulWidget {
  const ProviderRegStep2Screen({super.key});

  @override
  ConsumerState<ProviderRegStep2Screen> createState() =>
      _ProviderRegStep2ScreenState();
}

class _ProviderRegStep2ScreenState
    extends ConsumerState<ProviderRegStep2Screen> {
  final List<String> _skills = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Carpentry',
    'Painting'
  ];
  final List<String> _selectedSkills = [];
  final Map<String, TextEditingController> _rateControllers = {};
  double _radius = 10;
  int _experience = 2;

  @override
  void dispose() {
    for (var controller in _rateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleNext() {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }

    final Map<String, double> rates = {};
    for (var skill in _selectedSkills) {
      final text = _rateControllers[skill]?.text.trim() ?? '';
      final rateVal = double.tryParse(text) ?? 500.0; // default rate
      rates[skill] = rateVal;
    }

    ref.read(providerRegStateProvider.notifier).update((state) => {
          ...state,
          'skills': _selectedSkills,
          'rates': rates,
          'experience': _experience,
          'radius': _radius.toInt(),
        });

    context.push(AppRoutes.registerProvider3);
  }

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
                        _rateControllers[skill] =
                            TextEditingController(text: '800');
                      } else {
                        _selectedSkills.remove(skill);
                        _rateControllers[skill]?.dispose();
                        _rateControllers.remove(skill);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.body2.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_selectedSkills.isNotEmpty) ...[
              const Text('Set Rates (Rs. / hr)', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              ..._selectedSkills
                  .map((skill) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(skill, style: AppTextStyles.body1)),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _rateControllers[skill],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Rate',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
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
            Text('Coverage Radius: ${_radius.toInt()} km',
                style: AppTextStyles.h3),
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
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}
