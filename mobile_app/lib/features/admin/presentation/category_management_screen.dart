import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'providers': 45, 'bookings': 1250, 'baseRate': 500, 'active': true},
    {'name': 'Electrical', 'icon': Icons.electrical_services, 'providers': 38, 'bookings': 890, 'baseRate': 400, 'active': true},
    {'name': 'AC Repair', 'icon': Icons.ac_unit, 'providers': 22, 'bookings': 2100, 'baseRate': 800, 'active': false},
  ];

  void _showAddEditSheet({Map<String, dynamic>? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category == null ? 'Add Category' : 'Edit Category', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                    child: Icon(category?['icon'] ?? Icons.add_photo_alternate, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: TextField(decoration: InputDecoration(labelText: 'Name (English)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Name (Urdu)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Base Rate (Rs)', border: OutlineInputBorder()), keyboardType: TextInputType.number, controller: TextEditingController(text: category?['baseRate']?.toString() ?? ''))),
                  const SizedBox(width: 16),
                  const Expanded(child: TextField(decoration: InputDecoration(labelText: 'Complexity Mult.', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Category', style: TextStyle(color: Colors.white)),
                ),
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
        title: const Text('Categories', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(cat['icon'] as IconData, color: AppColors.primary),
              ),
              title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Providers: ${cat['providers']} • Bookings: ${cat['bookings']}\nBase Rate: Rs ${cat['baseRate']}', style: TextStyle(fontSize: 12, height: 1.4)),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: cat['active'] as bool,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => cat['active'] = val);
                    },
                  ),
                ],
              ),
              onTap: () => _showAddEditSheet(category: cat),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddEditSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
