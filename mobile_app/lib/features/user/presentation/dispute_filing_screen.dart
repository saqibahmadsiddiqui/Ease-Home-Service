import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class DisputeFilingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const DisputeFilingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<DisputeFilingScreen> createState() => _DisputeFilingScreenState();
}

class _DisputeFilingScreenState extends ConsumerState<DisputeFilingScreen> {
  String? _selectedDisputeType;
  final _descController = TextEditingController();
  bool _isUrgent = false;

  final List<Map<String, dynamic>> _disputeTypes = [
    {'id': 'NO_SHOW', 'label': 'No Show', 'icon': Icons.person_off},
    {'id': 'QUALITY_ISSUE', 'label': 'Quality Issue', 'icon': Icons.thumb_down},
    {'id': 'PRICE_DISPUTE', 'label': 'Price Dispute', 'icon': Icons.attach_money},
    {'id': 'DAMAGE_CLAIM', 'label': 'Damage Claim', 'icon': Icons.broken_image},
    {'id': 'OVERRUN', 'label': 'Time Overrun', 'icon': Icons.timer_off},
    {'id': 'CANCELLATION', 'label': 'Cancellation', 'icon': Icons.cancel},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report an Issue', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What went wrong?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _disputeTypes.length,
              itemBuilder: (context, index) {
                final type = _disputeTypes[index];
                final isSelected = _selectedDisputeType == type['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDisputeType = type['id'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.error.withOpacity(0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.error : AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type['icon'] as IconData, color: isSelected ? AppColors.error : AppColors.inactive, size: 20),
                        const SizedBox(width: 8),
                        Text(type['label'] as String, style: TextStyle(color: isSelected ? AppColors.error : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Please provide details about the issue...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Evidence Photos (Up to 3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: const Icon(Icons.add_a_photo, color: AppColors.inactive),
                );
              }),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Urgent Assistance Required?', style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _isUrgent,
                  activeColor: AppColors.error,
                  onChanged: (val) => setState(() => _isUrgent = val),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedDisputeType != null ? () {
                  // Submit logic
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Dispute', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
