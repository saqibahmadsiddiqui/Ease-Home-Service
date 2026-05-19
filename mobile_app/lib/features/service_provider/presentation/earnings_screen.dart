import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  int _selectedPeriod = 0; // 0: Today, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // likely bottom nav tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Tabs
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Today'),
                  _buildTab(1, 'Week'),
                  _buildTab(2, 'Month'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards
            Row(
              children: [
                Expanded(child: _buildStatCard('Gross', 'Rs 5k', AppColors.textPrimary, false)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Fee (10%)', 'Rs 500', AppColors.error, false)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Net Earned', 'Rs 4.5k', AppColors.success, true)),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Platform fee is automatically deducted (10%)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ),
            const SizedBox(height: 32),

            // Chart Placeholder
            const Text('Earnings Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(0.3, 'M'),
                  _buildBar(0.6, 'T'),
                  _buildBar(0.8, 'W'),
                  _buildBar(0.5, 'T'),
                  _buildBar(0.9, 'F', isToday: true),
                  _buildBar(0.2, 'S'),
                  _buildBar(0.0, 'S'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Payout History
            const Text('Recent Payouts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPayoutRow('May 15, 2026', 'Bank Transfer (****1234)', 'Rs 12,500'),
            _buildPayoutRow('May 08, 2026', 'Bank Transfer (****1234)', 'Rs 9,200'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    bool isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, Color amountColor, bool isHighlight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighlight ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor)),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, String label, {bool isToday = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 150 * heightFactor,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : AppColors.primary.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isToday ? AppColors.primary : AppColors.textSecondary, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildPayoutRow(String date, String method, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(method, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16)),
        ],
      ),
    );
  }
}
