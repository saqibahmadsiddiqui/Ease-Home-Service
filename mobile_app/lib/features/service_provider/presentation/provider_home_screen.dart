import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';
import 'package:ease_home_service/shared/widgets/provider_bottom_nav_bar.dart';


class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello,',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16)),
                      Text('Ali Khan',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.person, color: AppColors.inactive),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Online Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _isOnline ? AppColors.primary : AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isOnline
                                ? AppColors.primary
                                : AppColors.inactive,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isOnline ? 'You are Online' : 'You are Offline',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isOnline
                                  ? AppColors.primary
                                  : AppColors.inactive),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOnline,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isOnline = val),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Earnings Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C00), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Earnings",
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        SizedBox(height: 8),
                        Text('Rs 4,500',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Jobs Completed',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        SizedBox(height: 8),
                        Text('3',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Incoming Requests
              const Text('Incoming Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildJobRequestCard(context),
              const SizedBox(height: 32),

              // Today's Schedule Timeline
              const Text("Today's Schedule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildTimelineItem('10:00 AM', 'AC Repair - Complete',
                  isPast: true),
              _buildTimelineItem('12:30 PM', 'Plumbing - Complete',
                  isPast: true),
              _buildTimelineItem('03:00 PM', 'Electrical Fix - Upcoming',
                  isPast: false, isNext: true),
              _buildTimelineItem('05:00 PM', 'Available Slot',
                  isPast: false, isAvailable: true),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildJobRequestCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, AppRoutes.providerJob.replaceAll(':id', 'req-123')),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: const Border(
              left: BorderSide(color: AppColors.primary, width: 6)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plumbing Leak Repair',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.timer, color: AppColors.error, size: 14),
                      SizedBox(width: 4),
                      Text('02:45',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.inactive, size: 16),
                SizedBox(width: 8),
                Text('2.5 km away',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                SizedBox(width: 16),
                Icon(Icons.access_time, color: AppColors.inactive, size: 16),
                SizedBox(width: 8),
                Text('ASAP',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String time, String title,
      {bool isPast = false, bool isNext = false, bool isAvailable = false}) {
    Color dotColor = isPast
        ? AppColors.inactive
        : (isNext ? AppColors.primary : AppColors.success);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPast ? AppColors.inactive : AppColors.textPrimary)),
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.white : dotColor,
                border: Border.all(color: dotColor, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: AppColors.border,
            )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isPast ? AppColors.inactive : AppColors.textPrimary,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
