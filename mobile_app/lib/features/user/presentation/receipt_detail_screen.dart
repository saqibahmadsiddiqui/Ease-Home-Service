import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String bookingId;
  const ReceiptDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('E-Receipt', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Physical Receipt Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                ],
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Header
                  const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  const Text('Payment Successful!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('May 15, 2026 at 3:45 PM', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 24),
                  const Divider(), // In a real app use a dashed divider package or custom painter
                  const SizedBox(height: 24),

                  // Info
                  _buildInfoRow('Transaction ID', '#TXN-$bookingId'),
                  _buildInfoRow('Service', 'Plumbing Repair'),
                  _buildInfoRow('Provider', 'Ali Khan'),
                  _buildInfoRow('Payment Method', 'Credit Card (**** 1234)'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Breakdown
                  _buildPriceRow('Base Rate', 'Rs 500'),
                  _buildPriceRow('Complexity', 'Rs 100'),
                  _buildPriceRow('Distance Fee', 'Rs 50'),
                  _buildPriceRow('Urgency', 'Rs 200'),
                  _buildPriceRow('Surge', 'Rs 150'),
                  _buildPriceRow('Discount', '- Rs 100', isDiscount: true),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Rs 900', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Rating Shown
                  const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 24)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Book Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(amount, style: TextStyle(fontWeight: FontWeight.w500, color: isDiscount ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
