import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class NoProviderScreen extends ConsumerWidget {
  const NoProviderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration Placeholder
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 80, color: AppColors.inactive),
            ),
            const SizedBox(height: 24),
            
            const Text('No Providers Available', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'All our plumbing specialists in your area are currently busy.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Wait Time Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimated Wait Time', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('~45 minutes', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Join Waitlist Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Join Waitlist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            // Expand Search Option
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar, size: 18),
                    SizedBox(width: 8),
                    Text('Expand Search to +5 km'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 24),

            // Schedule for Later
            const Align(alignment: Alignment.centerLeft, child: Text('Schedule for Later', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('AI suggests these optimal slots:', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildSlotOption('Today', '4:00 PM')),
                const SizedBox(width: 12),
                Expanded(child: _buildSlotOption('Tomorrow', '9:00 AM')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlotOption(String day, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
