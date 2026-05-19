import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class KycQueueScreen extends ConsumerStatefulWidget {
  const KycQueueScreen({super.key});

  @override
  ConsumerState<KycQueueScreen> createState() => _KycQueueScreenState();
}

class _KycQueueScreenState extends ConsumerState<KycQueueScreen> {
  int _selectedTab = 0; // 0: Pending, 1: Approved, 2: Rejected
  final List<String> _tabs = ['Pending', 'Approved', 'Rejected'];

  void _showRejectSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reject Application',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason for rejection...',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirm Rejection',
                        style: TextStyle(color: Colors.white)),
                  ),
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
        title: const Text('KYC Queue',
            style: TextStyle(color: AppColors.textPrimary)),
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
                    labelStyle: TextStyle(
                        color: _selectedTab == index
                            ? Colors.white
                            : AppColors.textPrimary),
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
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildKycCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            const CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person, color: AppColors.inactive)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usman Tariq',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Electrician • Lahore',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('Pending',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 10)),
            )
          ],
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Documents Submitted',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDocThumbnail('CNIC Front'),
              const SizedBox(width: 8),
              _buildDocThumbnail('CNIC Back'),
              const SizedBox(width: 8),
              _buildDocThumbnail('Selfie'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showRejectSheet,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error)),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success),
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('Request More Info',
                style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  Widget _buildDocThumbnail(String label) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 80,
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.image, color: AppColors.inactive),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
