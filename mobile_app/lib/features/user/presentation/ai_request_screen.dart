import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

class AiRequestScreen extends ConsumerStatefulWidget {
  const AiRequestScreen({super.key});

  @override
  ConsumerState<AiRequestScreen> createState() => _AiRequestScreenState();
}

class _AiRequestScreenState extends ConsumerState<AiRequestScreen> {
  final _textController = TextEditingController();
  int _selectedLangIndex = 0;
  final List<String> _languages = ['EN', 'UR', 'Roman UR'];
  double _confidence = 0.0;
  List<String> _chips = [];
  bool _isAnalyzing = false;
  String? _clarificationPrompt;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _simulateAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        final text = _textController.text.toLowerCase();
        if (text.contains('leak') || text.contains('plumber')) {
          _confidence = 0.95;
          _chips = ['Plumbing', 'ASAP', 'Repair'];
          _clarificationPrompt = null;
        } else if (text.length > 5) {
          _confidence = 0.60;
          _chips = ['Unknown Service'];
          _clarificationPrompt = "Could you please specify what needs fixing?";
        } else {
          _confidence = 0.0;
          _chips = [];
          _clarificationPrompt = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Describe your problem', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Tabs
            Row(
              children: List.generate(_languages.length, (index) {
                final isSelected = _selectedLangIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: Text(_languages[index]),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedLangIndex = index);
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Text Input
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'e.g. My kitchen sink is leaking continuously and I need someone to fix it ASAP.',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (_) => _simulateAnalysis(),
              ),
            ),
            const SizedBox(height: 16),

            // Mic Button
            Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: Implement voice to text
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: AppColors.primary, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // AI Processing Results
            if (_isAnalyzing)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (_confidence > 0) ...[
              const Text('AI Understanding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _confidence,
                      backgroundColor: AppColors.surface,
                      color: _confidence > 0.75 ? AppColors.success : AppColors.error,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(_confidence * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _chips.map((chip) => Chip(
                  label: Text(chip, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                )).toList(),
              ),
              if (_clarificationPrompt != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_clarificationPrompt!, style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
              ],
            ],
            const Spacer(),

            // Find Providers Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confidence > 0.75 ? () {
                  Navigator.pushNamed(context, AppRoutes.userRanking);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Find Best Providers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
