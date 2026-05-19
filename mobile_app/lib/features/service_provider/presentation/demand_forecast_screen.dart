import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class DemandForecastScreen extends ConsumerWidget {
  const DemandForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Demand Forecast', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), // Dark elegant background
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Text('Powered by Antigravity AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Heatmap Note
            const Text('Area Demand Heatmap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Darker orange indicates higher expected job volume based on historical data and current trends.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),

            // Heatmap Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                gradient: LinearGradient(
                  colors: [AppColors.surface, AppColors.primary.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
              child: const Center(child: Text('Heatmap Grid Placeholder (Mon-Sun x Hours)', style: TextStyle(color: AppColors.textSecondary))),
            ),
            const SizedBox(height: 32),

            // Peak Hours
            const Text('Upcoming Peak Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPeakPill('Today, 5 PM - 8 PM', true),
                _buildPeakPill('Tomorrow, 9 AM - 11 AM', false),
                _buildPeakPill('Saturday, All Day', true),
              ],
            ),
            const SizedBox(height: 32),

            // Recommended Slots
            const Text('Recommended Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRecommendationCard('Open Evening Slots', 'High demand for plumbing tonight.', '+ Rs 3,000 potential'),
            _buildRecommendationCard('Work this Weekend', 'Surge pricing expected on Saturday.', '+ Rs 8,000 potential'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakPill(String text, bool isHighSurge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isHighSurge ? AppColors.error.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighSurge ? AppColors.error.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighSurge) const Icon(Icons.local_fire_department, color: AppColors.error, size: 14),
          if (isHighSurge) const SizedBox(width: 4),
          Text(text, style: TextStyle(color: isHighSurge ? AppColors.error : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String desc, String potential) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Text(potential, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
