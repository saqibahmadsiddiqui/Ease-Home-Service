import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<String> _tabs = ['All', 'System', 'Booking', 'Promo'];
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Booking Confirmed!',
      'body': 'Your plumbing repair is scheduled for today at 2:00 PM.',
      'type': 'Booking',
      'isRead': false,
      'time': '2m ago',
      'icon': Icons.calendar_today,
    },
    {
      'id': '2',
      'title': 'Provider Arrived',
      'body': 'Ali Khan has arrived at your location.',
      'type': 'System',
      'isRead': false,
      'time': '1h ago',
      'icon': Icons.directions_car,
    },
    {
      'id': '3',
      'title': '20% Off Weekend Special',
      'body': 'Use code WEEKEND20 for 20% off all AC repairs this weekend.',
      'type': 'Promo',
      'isRead': true,
      'time': '1d ago',
      'icon': Icons.local_offer,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isRead'] = true;
                }
              });
            },
            child: const Text('Mark All Read', style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTab == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_tabs[index]),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTab = index);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Notifications List
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                
                // Simple filter logic
                if (_selectedTab != 0 && notif['type'] != _tabs[_selectedTab]) {
                  return const SizedBox.shrink();
                }

                return Dismissible(
                  key: Key(notif['id'] as String),
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  child: Container(
                    color: notif['isRead'] == true ? Colors.white : const Color(0xFFFFF5EE), // Orange tint
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notif['icon'] as IconData, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(notif['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(notif['time'] as String, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notif['body'] as String, style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
