import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [
      {'icon': Icons.cleaning_services, 'name': 'Cleaning'},
      {'icon': Icons.plumbing, 'name': 'Plumbing'},
      {'icon': Icons.electric_bolt, 'name': 'Electrical'},
      {'icon': Icons.ac_unit, 'name': 'AC Repair'},
      {'icon': Icons.carpenter, 'name': 'Carpentry'},
      {'icon': Icons.format_paint, 'name': 'Painting'},
      {'icon': Icons.kitchen, 'name': 'Appliances'},
      {'icon': Icons.bug_report, 'name': 'Pest Control'},
      {'icon': Icons.handyman, 'name': 'Handyman'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning,',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16)),
                      Text('Saqib!',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        size: 28, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.userNotifications),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // AI Search Bar
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.userAiRequest),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.inactive),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'What do you need help with?',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, color: AppColors.primary),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Active Booking Card
              const Text('Active Booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.plumbing, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plumbing Repair',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Provider is on the way',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 16),
                      onPressed: () => Navigator.pushNamed(context,
                          AppRoutes.userTracker.replaceAll(':id', '123')),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Categories Grid
              const Text('Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(categories[index]['icon'] as IconData,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categories[index]['name'] as String,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      )
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Recent Bookings
              const Text('Recent Bookings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.border),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.ac_unit,
                          color: AppColors.textPrimary),
                    ),
                    title: const Text('AC Service',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Completed • May 15, 2026'),
                    trailing: const Text('Rs 1500',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
