import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Settings',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // likely bottom nav tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Admin Identity
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.admin_panel_settings,
                        color: Colors.amber, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Super Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Last login: Today at 09:45 AM',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sections
            _buildSectionHeader('Platform Management'),
            _buildListTile(context, Icons.category, 'Category Configuration',
                AppRoutes.adminCategories),
            _buildListTile(context, Icons.monetization_on,
                'Global Pricing Rules', AppRoutes.adminPricing),

            const SizedBox(height: 24),
            _buildSectionHeader('User Management'),
            _buildListTile(context, Icons.block, 'Blacklist Management',
                AppRoutes.adminBlacklist),

            const SizedBox(height: 24),
            _buildSectionHeader('Monitoring'),
            _buildListTile(context, Icons.memory, 'Antigravity AI Logs',
                AppRoutes.adminLogs),
            _buildListTile(
                context, Icons.security, 'Security & Access Logs', null),

            const SizedBox(height: 48),

            // Sign Out
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Logout logic
                  Navigator.pushReplacementNamed(context, AppRoutes.splash);
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A), // Dark sign out
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, IconData icon, String title, String? route) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.inactive),
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
