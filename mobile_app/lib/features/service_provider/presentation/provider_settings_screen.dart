import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_project_name/core/constants/app_colors.dart';
import 'package:your_project_name/core/constants/app_routes.dart';

class ProviderSettingsScreen extends ConsumerWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile Settings', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // likely bottom nav tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.surface,
                      child: const Icon(Icons.person, size: 35, color: AppColors.inactive),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ali Khan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Master Plumber', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Verified', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 32),

            // Metrics Links
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(context, Icons.bar_chart, 'Performance', '87 / 100', AppRoutes.providerPerformance),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(context, Icons.attach_money, 'Earnings', 'Rs 45k', AppRoutes.providerEarnings),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Edit Sections
            _buildSectionHeader('Professional Profile'),
            _buildListTile(Icons.person_outline, 'Personal Information'),
            _buildListTile(Icons.build_outlined, 'Skills & Services'),
            _buildListTile(Icons.price_change_outlined, 'Rates & Pricing'),
            _buildListTile(Icons.map_outlined, 'Service Area'),
            _buildListTile(Icons.calendar_month_outlined, 'Availability Calendar', onTap: () => Navigator.pushNamed(context, AppRoutes.providerCalendar)),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Account & Legal'),
            _buildListTile(Icons.file_copy_outlined, 'Documents & Verification'),
            _buildListTile(Icons.help_outline, 'Help & Support'),
            _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy'),
            
            const SizedBox(height: 48),

            // Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, IconData icon, String title, String value, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inactive),
      onTap: onTap ?? () {},
    );
  }
}
