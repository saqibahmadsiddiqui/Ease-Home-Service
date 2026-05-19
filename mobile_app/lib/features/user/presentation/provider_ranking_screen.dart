import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class ProviderRankingScreen extends ConsumerStatefulWidget {
  const ProviderRankingScreen({super.key});

  @override
  ConsumerState<ProviderRankingScreen> createState() => _ProviderRankingScreenState();
}

class _ProviderRankingScreenState extends ConsumerState<ProviderRankingScreen> {
  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Ali Khan',
      'role': 'Master Plumber',
      'score': 95,
      'reviews': 120,
      'rating': 4.9,
      'expanded': false,
      'factors': {
        'Distance': 'High Match (2.5 km)',
        'Skills': 'Perfect Match',
        'Experience': '5+ Years',
        'On-Time Rate': '98%',
      }
    },
    {
      'name': 'Hassan Raza',
      'role': 'Plumbing Specialist',
      'score': 88,
      'reviews': 85,
      'rating': 4.7,
      'expanded': false,
      'factors': {
        'Distance': 'Medium Match (5.1 km)',
        'Skills': 'Good Match',
        'Experience': '3 Years',
        'On-Time Rate': '90%',
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Top Matches', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // AI Explanation Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We found 5 providers based on your requirement for quick plumbing repair. Ali Khan is highly recommended due to proximity and a 98% on-time record.',
                    style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // Provider List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Header info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.surface,
                              child: const Icon(Icons.person, color: AppColors.inactive),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(provider['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${provider['score']}% Match',
                                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(provider['role'], style: TextStyle(color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${provider['rating']} (${provider['reviews']} reviews)', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Match Score Bar
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: provider['score'] / 100,
                            backgroundColor: AppColors.surface,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),

                        // Expandable Breakdown
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              provider['expanded'] = !(provider['expanded'] as bool);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Factor Breakdown', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                Icon(
                                  provider['expanded'] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (provider['expanded']) ...[
                          const Divider(),
                          ...(provider['factors'] as Map<String, String>).entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                ],
                              ),
                            );
                          }),
                        ],

                        // Actions
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.userProvider.replaceAll(':id', '123'));
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('View Profile'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.userSchedule);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        )
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
