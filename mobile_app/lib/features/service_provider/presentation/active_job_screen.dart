import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class ActiveJobScreen extends ConsumerStatefulWidget {
  final String jobId;
  const ActiveJobScreen({super.key, required this.jobId});

  @override
  ConsumerState<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends ConsumerState<ActiveJobScreen> {
  int _currentStep = 0; // 0: En Route, 1: Arrived, 2: In Progress, 3: Completed

  final List<String> _steps = [
    'En Route',
    'Arrived',
    'In Progress',
    'Completed'
  ];

  void _advanceStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      Navigator.pushReplacementNamed(
          context, AppRoutes.providerComplete.replaceAll(':id', widget.jobId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Job',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map Background (simulate navigation polyline)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            color: const Color(0xFFE0E0E0),
            child: const Center(
                child: Icon(Icons.map, size: 100, color: Colors.white)),
          ),

          // Top Progress Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: index <= _currentStep
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_steps[_currentStep],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 16),

                  // Customer Card
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.surface,
                        child: Icon(Icons.person, color: AppColors.inactive),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Doe',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('House 45, Street 2',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary),
                        style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chat, color: AppColors.primary),
                        style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1)),
                        onPressed: () {}, // Navigate to chat
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),

                  // Checklist Preview (if In Progress)
                  if (_currentStep == 2) ...[
                    const Text('Job Checklist',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCheckItem('Inspect leak'),
                    _buildCheckItem('Replace pipe'),
                    _buildCheckItem('Test pressure'),
                    const SizedBox(height: 16),
                  ],

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _advanceStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentStep == 0
                            ? 'Mark Arrived'
                            : _currentStep == 1
                                ? 'Start Job'
                                : _currentStep == 2
                                    ? 'Review & Complete'
                                    : 'Finish',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle_outlined,
              color: AppColors.inactive, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
