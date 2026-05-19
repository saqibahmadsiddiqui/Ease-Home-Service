import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class ServiceCompletionScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const ServiceCompletionScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ServiceCompletionScreen> createState() => _ServiceCompletionScreenState();
}

class _ServiceCompletionScreenState extends ConsumerState<ServiceCompletionScreen> {
  int _rating = 0;
  final List<String> _chips = ['Professional', 'On Time', 'Clean Work', 'Good Value', 'Friendly'];
  final Set<String> _selectedChips = {};
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Completed', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.success.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 60),
                  const SizedBox(height: 16),
                  const Text('Service Completed Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success)),
                  const SizedBox(height: 8),
                  Text('Plumbing Repair by Ali Khan', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Work Photos
            const Align(alignment: Alignment.centerLeft, child: Text('Work Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3, // mock 3 photos
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image, color: AppColors.inactive),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Checklist
            const Align(alignment: Alignment.centerLeft, child: Text('Completion Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            _buildChecklistItem('Area cleaned up'),
            _buildChecklistItem('System tested and working'),
            _buildChecklistItem('Payment received'),
            const Divider(height: 32),

            // Rating
            const Text('Rate your experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Quick Feedback Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _chips.map((chip) {
                final isSelected = _selectedChips.contains(chip);
                return FilterChip(
                  label: Text(chip),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedChips.add(chip) : _selectedChips.remove(chip);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Review Input
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a review (optional)...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.userReceipt.replaceAll(':id', widget.bookingId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.userDispute.replaceAll(':id', widget.bookingId));
              },
              child: const Text('Report an Issue', style: TextStyle(color: AppColors.error)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
