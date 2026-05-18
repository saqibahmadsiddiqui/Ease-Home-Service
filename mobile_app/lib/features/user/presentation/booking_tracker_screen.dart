import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_project_name/core/constants/app_colors.dart';
import 'package:your_project_name/core/constants/app_routes.dart';

class BookingTrackerScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingTrackerScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingTrackerScreen> createState() => _BookingTrackerScreenState();
}

class _BookingTrackerScreenState extends ConsumerState<BookingTrackerScreen> {
  final List<String> _stages = [
    'Pending Approval',
    'Matched',
    'Provider En Route',
    'Arrived',
    'In Progress',
    'Reviewing Quote',
    'Completed',
    'Closed'
  ];
  
  final int _currentStageIndex = 2; // "Provider En Route"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking #${widget.bookingId}', style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Map Area (Half screen)
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFFE0E0E0),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.map, size: 100, color: Colors.white)),
                  
                  // ETA Chip
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: const Text('Arriving in 15 mins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  // Provider Pin Placeholder
                  const Positioned(
                    top: 100,
                    left: 150,
                    child: Icon(Icons.directions_car, color: AppColors.primary, size: 40),
                  ),
                ],
              ),
            ),
          ),

          // Tracker Bottom Sheet
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Info & Actions
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.surface,
                        child: const Icon(Icons.person, color: AppColors.inactive),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ali Khan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const Text(' 4.9', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary),
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chat, color: AppColors.primary),
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1)),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.userChat.replaceAll(':id', widget.bookingId));
                        },
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),

                  // 8-Stage Stepper
                  const Text('Booking Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _stages.length,
                      itemBuilder: (context, index) {
                        final isCompleted = index < _currentStageIndex;
                        final isCurrent = index == _currentStageIndex;
                        
                        Color dotColor = AppColors.border;
                        Color textColor = AppColors.inactive;
                        if (isCompleted) {
                          dotColor = AppColors.primary;
                          textColor = AppColors.textPrimary;
                        } else if (isCurrent) {
                          dotColor = AppColors.primary;
                          textColor = AppColors.primary;
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isCompleted || isCurrent ? dotColor : Colors.white,
                                    border: Border.all(color: dotColor, width: 2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (index < _stages.length - 1)
                                  Container(
                                    width: 2,
                                    height: 30,
                                    color: isCompleted ? AppColors.primary : AppColors.border,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _stages[index],
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
