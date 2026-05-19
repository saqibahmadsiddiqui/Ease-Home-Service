import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  int _selectedTab = 0; // 0: Active, 1: Suspended, etc.
  final List<String> _tabs = ['Active', 'Suspended', 'Banned', 'New'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),

          // Filter Tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_tabs[index]),
                    selected: _selectedTab == index,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: _selectedTab == index ? Colors.white : AppColors.textPrimary),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTab = index);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildUserCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.inactive),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saqib Ali', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('+92 300 1234567', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text('Active', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10)),
            )
          ],
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Bookings: 14 • Joined: Jan 2026', style: TextStyle(fontSize: 12)),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.warning, size: 16),
                label: const Text('Warn'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pause, size: 16),
                label: const Text('Suspend'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.block, size: 16),
                label: const Text('Ban'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
