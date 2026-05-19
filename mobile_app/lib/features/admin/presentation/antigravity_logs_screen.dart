import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class AntigravityLogsScreen extends ConsumerStatefulWidget {
  const AntigravityLogsScreen({super.key});

  @override
  ConsumerState<AntigravityLogsScreen> createState() => _AntigravityLogsScreenState();
}

class _AntigravityLogsScreenState extends ConsumerState<AntigravityLogsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['ALL', 'INTENT', 'MATCHING', 'PRICING', 'DISPUTE'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Antigravity AI Logs', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Session ID or Trace ID...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),

          // Filters
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
                    label: Text(_tabs[index], style: const TextStyle(fontSize: 11)),
                    selected: _selectedTab == index,
                    selectedColor: const Color(0xFF1A1A1A), // Dark for AI
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
                return _buildLogCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(int index) {
    bool isError = index == 2; // Mock an error
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isError ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                index % 2 == 0 ? 'MATCHING' : 'INTENT',
                style: TextStyle(color: isError ? AppColors.error : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Text('Trace ID: a7f89${index}b...', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            if (isError)
               const Icon(Icons.error, color: AppColors.error, size: 16)
            else
               const Icon(Icons.check_circle, color: AppColors.success, size: 16)
          ],
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Conf: 92% • Latency: 1240ms • Cost: \$0.0002', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
            child: const Text(
              '{\n  "input": "Need a plumber ASAP for kitchen sink",\n  "output": {\n    "service": "Plumbing",\n    "urgency": "High"\n  }\n}',
              style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }
}
