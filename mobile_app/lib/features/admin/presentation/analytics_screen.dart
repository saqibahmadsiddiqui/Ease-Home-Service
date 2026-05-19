import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedPeriod = 0;
  final List<String> _tabs = ['Today', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Tabs
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
                      selected: _selectedPeriod == index,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: _selectedPeriod == index ? Colors.white : AppColors.textPrimary),
                      onSelected: (val) {
                        if (val) setState(() => _selectedPeriod = index);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Cards Scroll
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMetricCard('Gross Revenue', 'Rs 250k', '+12%'),
                  _buildMetricCard('Platform Fees', 'Rs 25k', '+12%'),
                  _buildMetricCard('Total Bookings', '1,450', '+5%'),
                  _buildMetricCard('Active Providers', '124', '+2%'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Revenue Chart
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Revenue Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: Icon(Icons.show_chart, size: 60, color: AppColors.inactive)),
            ),
            const SizedBox(height: 32),

            // Top Providers Leaderboard
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Top Providers (By Earnings)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildLeaderboardRow(1, 'Ali Khan', 'Rs 45k'),
                  const Divider(height: 0),
                  _buildLeaderboardRow(2, 'Usman Tariq', 'Rs 38k'),
                  const Divider(height: 0),
                  _buildLeaderboardRow(3, 'Sarah Ahmed', 'Rs 35k'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.success, size: 14),
              const SizedBox(width: 4),
              Text(trend, style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, String value) {
    Color medalColor = rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey[400]! : Colors.brown[300]!);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: medalColor.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text(rank.toString(), style: TextStyle(color: medalColor, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
