import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class BlacklistScreen extends ConsumerStatefulWidget {
  const BlacklistScreen({super.key});

  @override
  ConsumerState<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends ConsumerState<BlacklistScreen> {
  void _showRemoveConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Remove from Blacklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter your Admin PIN to confirm this action.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '****',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Blacklist Management', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {}, // Add flow
          )
        ],
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Text('14', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.error)),
                        Text('Banned Providers', style: TextStyle(fontSize: 12, color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Text('42', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.error)),
                        Text('Banned Users', style: TextStyle(fontSize: 12, color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildBlacklistCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlacklistCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: const Border(left: BorderSide(color: AppColors.error, width: 6)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_off, color: AppColors.error),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usman Ali', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Provider • Plumber', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showRemoveConfirmation,
                  child: const Text('Remove', style: TextStyle(color: AppColors.primary)),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            const Text('Trigger Reason:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Multiple extreme quality complaints and AI-detected aggressive chat behavior.', style: TextStyle(color: AppColors.error, fontSize: 12)),
            const SizedBox(height: 8),
            Text('Banned on: May 01, 2026 by Admin System', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
