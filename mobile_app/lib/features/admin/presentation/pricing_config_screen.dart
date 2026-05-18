import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_project_name/core/constants/app_colors.dart';

class PricingConfigScreen extends ConsumerStatefulWidget {
  const PricingConfigScreen({super.key});

  @override
  ConsumerState<PricingConfigScreen> createState() => _PricingConfigScreenState();
}

class _PricingConfigScreenState extends ConsumerState<PricingConfigScreen> {
  double _platformFee = 10.0;
  double _surgeMult = 1.5;
  final TextEditingController _distanceFeeCtrl = TextEditingController(text: '15');
  final TextEditingController _urgencyFeeCtrl = TextEditingController(text: '200');

  @override
  void dispose() {
    _distanceFeeCtrl.dispose();
    _urgencyFeeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simulated Live Quote
    double base = 500;
    double dist = 5 * double.parse(_distanceFeeCtrl.text.isEmpty ? '0' : _distanceFeeCtrl.text); // 5km
    double urgency = double.parse(_urgencyFeeCtrl.text.isEmpty ? '0' : _urgencyFeeCtrl.text);
    double surge = 100 * _surgeMult; // Arbitrary surge base calculation
    double total = base + dist + urgency + surge;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pricing Engine', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.amber, size: 16),
                      SizedBox(width: 8),
                      Text('Live Quote Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewRow('Base (Plumbing)', 'Rs $base'),
                  _buildPreviewRow('Distance (5km)', 'Rs $dist'),
                  _buildPreviewRow('Urgency (ASAP)', 'Rs $urgency'),
                  _buildPreviewRow('Surge (High Demand)', 'Rs $surge'),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total to Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('Rs ${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sliders & Inputs
            const Text('Global Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            _buildSliderRow('Platform Fee', '$_platformFee%', _platformFee, 0, 30, (val) => setState(() => _platformFee = val)),
            _buildSliderRow('Max Surge Multiplier', '${_surgeMult.toStringAsFixed(1)}x', _surgeMult, 1.0, 3.0, (val) => setState(() => _surgeMult = val)),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInput('Distance Fee / km', _distanceFeeCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildInput('Urgency Premium', _urgencyFeeCtrl)),
              ],
            ),
            const SizedBox(height: 32),

            // Loyalty Table
            const Text('Loyalty Discount Tiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildLoyaltyRow('Silver (5+ Bookings)', '5%'),
                  const Divider(height: 0),
                  _buildLoyaltyRow('Gold (15+ Bookings)', '10%'),
                  const Divider(height: 0),
                  _buildLoyaltyRow('Platinum (30+ Bookings)', '15%'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, String valueLabel, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(valueLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      onChanged: (val) => setState((){}), // Trigger rebuild for live quote
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      ),
    );
  }

  Widget _buildLoyaltyRow(String tier, String discount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tier),
          Text(discount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
