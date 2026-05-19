import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/shared/widgets/user_bottom_nav_bar.dart';


class SavedProvidersScreen extends ConsumerStatefulWidget {
  const SavedProvidersScreen({super.key});

  @override
  ConsumerState<SavedProvidersScreen> createState() =>
      _SavedProvidersScreenState();
}

class _SavedProvidersScreenState extends ConsumerState<SavedProvidersScreen> {
  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Ali Khan',
      'role': 'Master Plumber',
      'rating': 4.9,
      'isAvailable': true,
      'distance': '2.5 km',
      'lastBooked': 'May 10, 2026',
      'skills': ['Plumbing', 'Heating']
    },
    {
      'name': 'Usman Ali',
      'role': 'Electrician',
      'rating': 4.8,
      'isAvailable': false,
      'distance': '5.1 km',
      'lastBooked': 'Jan 15, 2026',
      'skills': ['Electrical', 'Wiring']
    }
  ];

  void _showUnsaveConfirmation(int index) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Remove from Saved?',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Are you sure you want to remove this provider from your saved list?',
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _providers.removeAt(index);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Remove',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
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
        title: const Text('Saved Providers',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading:
            false, // assuming it might be accessed differently or is a root tab
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _providers.length,
        itemBuilder: (context, index) {
          final provider = _providers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.surface,
                            child:
                                Icon(Icons.person, color: AppColors.inactive),
                          ),
                          if (provider['isAvailable'] == true)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider['name'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(provider['role'] as String,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                    '${provider['rating']} • ${provider['distance']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite,
                            color: AppColors.primary),
                        onPressed: () => _showUnsaveConfirmation(index),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: (provider['skills'] as List<String>)
                        .map((skill) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(skill,
                                  style: const TextStyle(fontSize: 11)),
                            ))
                        .toList(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last Booked: ${provider['lastBooked']}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Book Now',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 3),
    );
  }
}
