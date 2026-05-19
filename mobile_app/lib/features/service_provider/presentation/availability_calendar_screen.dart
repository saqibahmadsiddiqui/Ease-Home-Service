import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/shared/widgets/provider_bottom_nav_bar.dart';


class AvailabilityCalendarScreen extends ConsumerStatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  ConsumerState<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends ConsumerState<AvailabilityCalendarScreen> {
  bool _acceptingRequests = true;

  void _showDayDetailSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('May 18, 2026',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.work, color: AppColors.success),
                  title: const Text('Set Working Hours'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.bedtime, color: AppColors.error),
                  title: const Text('Mark as Day Off'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Availability',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instant Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accepting Requests',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Toggle to instantly go offline',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: _acceptingRequests,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _acceptingRequests = val),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Calendar View
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('May 2026',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.chevron_left), onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {}),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(AppColors.success, 'Working'),
                const SizedBox(width: 16),
                _buildLegend(AppColors.primary, 'Booked'),
                const SizedBox(width: 16),
                _buildLegend(AppColors.error, 'Day Off'),
              ],
            ),
            const SizedBox(height: 16),

            // Grid Placeholder
            GestureDetector(
              onTap: _showDayDetailSheet,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                    child: Text(
                        'Calendar Grid UI Placeholder\n(Tap to simulate day select)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary))),
              ),
            ),
            const SizedBox(height: 32),

            // Bulk Setter
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_month),
                label: const Text('Set Standard Weekly Schedule'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
