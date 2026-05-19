import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // likely bottom nav tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Insights Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Antigravity Insights', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your on-time rate is excellent. To boost your score to 90+, consider improving your response time to job requests (currently avg 15 mins).',
                    style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overall Score
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          value: 0.87,
                          strokeWidth: 10,
                          backgroundColor: AppColors.surface,
                          color: AppColors.primary,
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('87', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('/ 100', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Top 15% of Providers', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Breakdown
            const Text('Factor Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFactorBar('Customer Rating (4.9)', 0.98),
            _buildFactorBar('Job Completion Rate', 0.95),
            _buildFactorBar('On-Time Arrival', 0.90),
            _buildFactorBar('Response Rate', 0.75, color: Colors.amber), // Highlights area for improvement
            const SizedBox(height: 32),

            // Trend Placeholder
            const Text('Rating Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(Icons.show_chart, size: 60, color: AppColors.inactive),
              ), // In a real app use a line chart package
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorBar(String label, double value, {Color color = AppColors.primary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              color: color,
            ),
          )
        ],
      ),
    );
  }
}
