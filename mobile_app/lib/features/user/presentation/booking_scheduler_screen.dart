import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class BookingSchedulerScreen extends ConsumerStatefulWidget {
  const BookingSchedulerScreen({super.key});

  @override
  ConsumerState<BookingSchedulerScreen> createState() =>
      _BookingSchedulerScreenState();
}

class _BookingSchedulerScreenState
    extends ConsumerState<BookingSchedulerScreen> {
  int _selectedDay = 0;
  int _selectedSlot = -1;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _dates = ['15', '16', '17', '18', '19', '20', '21'];

  final List<Map<String, dynamic>> _slots = [
    {'time': '09:00 AM', 'available': true},
    {'time': '10:00 AM', 'available': false},
    {'time': '11:00 AM', 'available': true},
    {'time': '12:00 PM', 'available': true},
    {'time': '01:00 PM', 'available': false},
    {'time': '02:00 PM', 'available': true},
    {'time': '03:00 PM', 'available': true},
    {'time': '04:00 PM', 'available': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Schedule Booking',
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
            // AI Suggestion Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Suggested Slot',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                            'Provider is in your area today at 2:00 PM. Book this slot for a waived distance fee.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDay = 0;
                        _selectedSlot = 5; // index of 2:00 PM
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Select'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Week View Calendar Strip
            const Text('Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final isSelected = _selectedDay == index;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDay = index;
                      _selectedSlot = -1; // reset slot on day change
                    }),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_days[index],
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(_dates[index],
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Time Slots Grid
            const Text('Available Slots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final isAvailable = slot['available'] as bool;
                final isSelected = _selectedSlot == index;

                Color bgColor;
                Color textColor;
                Color borderColor;

                if (!isAvailable) {
                  bgColor = AppColors.surface;
                  textColor = AppColors.inactive;
                  borderColor = AppColors.surface;
                } else if (isSelected) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                  borderColor = AppColors.primary;
                } else {
                  bgColor = Colors.white;
                  textColor = AppColors.success;
                  borderColor = AppColors.success.withValues(alpha: 0.5);
                }

                return GestureDetector(
                  onTap: isAvailable
                      ? () => setState(() => _selectedSlot = index)
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      slot['time'] as String,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        decoration: !isAvailable
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 100), // spacing for CTA
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedSlot != -1
                  ? () {
                      Navigator.pushNamed(context, AppRoutes.userQuote);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm Schedule',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
