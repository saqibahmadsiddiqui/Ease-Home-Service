import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class JobCompletionScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobCompletionScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobCompletionScreen> createState() => _JobCompletionScreenState();
}

class _JobCompletionScreenState extends ConsumerState<JobCompletionScreen> {
  final List<Map<String, dynamic>> _checklist = [
    {'text': 'Area cleaned up', 'done': false},
    {'text': 'System tested and working', 'done': false},
    {'text': 'Customer briefed', 'done': false},
  ];
  
  bool _photoUploaded = false;
  final _amountController = TextEditingController(text: '900'); // Estimated amount

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Job', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checklist
            const Text('Completion Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._checklist.map((item) {
              return CheckboxListTile(
                title: Text(item['text'] as String),
                value: item['done'] as bool,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
                  setState(() => item['done'] = val);
                },
              );
            }),
            const SizedBox(height: 24),

            // Mandatory Photo
            Row(
              children: [
                const Text('Proof of Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Required', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() => _photoUploaded = true);
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: _photoUploaded 
                  ? const Center(child: Icon(Icons.check_circle, color: AppColors.success, size: 40))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.inactive, size: 40),
                        SizedBox(height: 8),
                        Text('Tap to take photo', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Final Amount
            const Text('Final Net Amount (Rs)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: 'Rs ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // CTA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _photoUploaded ? () {
                  // Complete logic
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Mark Job Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
