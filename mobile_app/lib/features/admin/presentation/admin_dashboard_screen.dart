import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          '3 high-priority disputes require manual review.',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // KPI Grid
            Row(
              children: [
                Expanded(
                    child: _buildKpiCard('Total Bookings', '1,245',
                        Icons.calendar_today, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildKpiCard('Revenue (Net)', 'Rs 85k',
                        Icons.attach_money, AppColors.success)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildKpiCard(
                        'Disputes', '12', Icons.gavel, AppColors.error)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildKpiCard('KYC Pending', '28',
                        Icons.verified_user, Colors.orange)),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildActionIcon(Icons.verified, 'KYC Queue',
                      () => Navigator.pushNamed(context, AppRoutes.adminKyc)),
                  _buildActionIcon(
                      Icons.gavel,
                      'Disputes',
                      () => Navigator.pushNamed(
                          context, AppRoutes.adminDisputes)),
                  _buildActionIcon(Icons.people, 'Users',
                      () => Navigator.pushNamed(context, AppRoutes.adminUsers)),
                  _buildActionIcon(
                      Icons.engineering,
                      'Providers',
                      () => Navigator.pushNamed(
                          context, AppRoutes.adminProviders)),
                  _buildActionIcon(Icons.analytics, 'Logs',
                      () => Navigator.pushNamed(context, AppRoutes.adminLogs)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent Activity
            const Text('Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActivityRow('AI auto-resolved dispute #1042', '2 mins ago',
                Icons.auto_awesome, AppColors.primary),
            _buildActivityRow('New provider application received',
                '15 mins ago', Icons.person_add, Colors.orange),
            _buildActivityRow('Surge pricing triggered in DHA Phase 6',
                '1 hour ago', Icons.trending_up, AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const Icon(Icons.show_chart, color: AppColors.success, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
      String text, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(time,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
