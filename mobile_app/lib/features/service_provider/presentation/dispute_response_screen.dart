import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class DisputeResponseScreen extends ConsumerStatefulWidget {
  final String disputeId;
  const DisputeResponseScreen({super.key, required this.disputeId});

  @override
  ConsumerState<DisputeResponseScreen> createState() => _DisputeResponseScreenState();
}

class _DisputeResponseScreenState extends ConsumerState<DisputeResponseScreen> {
  int _selectedOption = -1; // 0: Accept, 1: Dispute, 2: Partial
  String _resolution = 'Refund 50%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Respond to Dispute', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Assessment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                      const SizedBox(width: 8),
                      const Text('Dispute Summary', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Customer claims the pipe started leaking again 2 hours after completion. They are requesting a full refund of Rs 900.', style: TextStyle(fontSize: 13, height: 1.4)),
                  const SizedBox(height: 12),
                  const Text('AI Assessment:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Images provided by customer show a minor leak at the joint.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Evidence
            const Text('Customer Evidence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEvidenceThumbnail(),
                const SizedBox(width: 8),
                _buildEvidenceThumbnail(),
              ],
            ),
            const SizedBox(height: 32),

            // Response Options
            const Text('Your Response', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildOptionCard(0, 'Accept Responsibility', 'I agree with the claim and will provide the requested resolution.'),
            const SizedBox(height: 8),
            _buildOptionCard(1, 'Dispute Claim', 'I disagree. The issue was not caused by my work.'),
            const SizedBox(height: 8),
            _buildOptionCard(2, 'Propose Partial Resolution', 'I accept partial responsibility and propose an alternative.'),
            const SizedBox(height: 32),

            // Upload Evidence (if disputing)
            if (_selectedOption == 1 || _selectedOption == 2) ...[
              const Text('Your Evidence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildUploadBox(),
                  const SizedBox(width: 8),
                  _buildUploadBox(),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Statement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Explain your side of the situation...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Proposed Resolution Dropdown
            if (_selectedOption == 2) ...[
              const Text('Proposed Resolution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _resolution,
                    isExpanded: true,
                    items: ['Refund 50%', 'Free Rework', 'Refund 25%'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _resolution = val!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOption != -1 ? () {
                  // Submit logic
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Response', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceThumbnail() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: AppColors.inactive),
    );
  }

  Widget _buildOptionCard(int index, String title, String desc) {
    bool isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : AppColors.inactive),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: const Center(child: Icon(Icons.add_a_photo, color: AppColors.inactive)),
    );
  }
}
