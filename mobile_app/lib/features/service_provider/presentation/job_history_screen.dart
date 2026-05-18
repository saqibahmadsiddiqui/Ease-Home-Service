import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_project_name/core/constants/app_colors.dart';

class JobHistoryScreen extends ConsumerStatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  ConsumerState<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends ConsumerState<JobHistoryScreen> {
  int _selectedTab = 0; // 0: All, 1: Completed, 2: Cancelled
  final List<String> _tabs = ['All', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job History', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // likely bottom nav tab
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {}, // Date range picker
          )
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Total', '142'),
                _buildStat('Completed', '135'),
                _buildStat('Cancelled', '7'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedTab == index;
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
          const SizedBox(height: 16),

          // Job List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildJobCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildJobCard(int index) {
    bool isCancelled = index == 3; // mock cancelled job
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCancelled ? 'Cancelled' : 'Completed', style: TextStyle(fontWeight: FontWeight.bold, color: isCancelled ? AppColors.error : AppColors.success)),
                Text('May 15, 2026', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(),
            ),
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.surface, child: const Icon(Icons.person, color: AppColors.inactive)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sarah Khan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Plumbing Repair', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(isCancelled ? 'Rs 0' : 'Rs 900', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    if (!isCancelled)
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text('5.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
