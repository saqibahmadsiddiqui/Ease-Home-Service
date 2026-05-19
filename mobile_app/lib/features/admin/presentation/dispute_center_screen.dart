import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class DisputeCenterScreen extends ConsumerStatefulWidget {
  const DisputeCenterScreen({super.key});

  @override
  ConsumerState<DisputeCenterScreen> createState() => _DisputeCenterScreenState();
}

class _DisputeCenterScreenState extends ConsumerState<DisputeCenterScreen> {
  int _selectedTab = 0; // 0: Escalated, 1: AI-Resolved
  final List<String> _tabs = ['Escalated', 'AI-Resolved'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dispute Center', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
              padding: const EdgeInsets.all(16),
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildDisputeCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking #B-9812', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('High Priority', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Text('Quality Issue vs. Master Plumber', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // AI Analysis embed
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text('Antigravity Analysis', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                  ],
                ),
                SizedBox(height: 8),
                Text('Provider history shows 3 similar disputes in past month. Customer evidence clearly shows incomplete seal. Recommended Action: 50% Refund to customer.', style: TextStyle(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Evidence viewer placeholder
          const Align(alignment: Alignment.centerLeft, child: Text('Evidence (4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(height: 50, width: 50, color: AppColors.surface, child: const Icon(Icons.image, size: 20)),
              const SizedBox(width: 8),
              Container(height: 50, width: 50, color: AppColors.surface, child: const Icon(Icons.image, size: 20)),
            ],
          ),
          const SizedBox(height: 16),

          // Admin Notes
          TextField(
            decoration: InputDecoration(
              hintText: 'Admin notes...',
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Refund 50%', style: TextStyle(color: Colors.white, fontSize: 12))),
              OutlinedButton(onPressed: () {}, child: const Text('Full Refund', style: TextStyle(fontSize: 12))),
              OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Warn Provider', style: TextStyle(fontSize: 12))),
              OutlinedButton(onPressed: () {}, child: const Text('Reject Claim', style: TextStyle(fontSize: 12))),
            ],
          )
        ],
      ),
    );
  }
}
