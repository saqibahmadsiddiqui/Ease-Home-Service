import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';


class ProviderMapScreen extends ConsumerStatefulWidget {
  const ProviderMapScreen({super.key});

  @override
  ConsumerState<ProviderMapScreen> createState() => _ProviderMapScreenState();
}

class _ProviderMapScreenState extends ConsumerState<ProviderMapScreen> {
  final List<String> _filters = [
    'Top Rated',
    'Nearest',
    'Available Now',
    'Under Rs 2000'
  ];
  int _selectedFilter = 0;
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nearby Providers',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Simulated Google Map Background
          if (_showMap)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE0E0E0), // Map gray background
              child: Stack(
                children: [
                  // Mock Map Pins
                  Positioned(
                    top: 200,
                    left: 100,
                    child: _buildMapPin('4.8'),
                  ),
                  Positioned(
                    top: 350,
                    right: 80,
                    child: _buildMapPin('4.9'),
                  ),
                  Positioned(
                    top: 280,
                    left: 200,
                    child: _buildMapPin('4.5'),
                  ),
                ],
              ),
            )
          else
            // List View
            SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
                itemCount: 5,
                itemBuilder: (context, index) => _buildProviderCard(),
              ),
            ),

          // Top Filters
          SafeArea(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = index);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Sliding Bottom Panel (simulated as positioned container for Map view)
          if (_showMap)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 3,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            child: _buildProviderCard(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _showMap = !_showMap);
        },
        backgroundColor: AppColors.primary,
        child: Icon(_showMap ? Icons.list : Icons.map, color: Colors.white),
      ),
      floatingActionButtonLocation: _showMap
          ? FloatingActionButtonLocation.endTop
          : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMapPin(String rating) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text(rating,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Icon(Icons.location_on, color: AppColors.primary, size: 36),
      ],
    );
  }

  Widget _buildProviderCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.inactive),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ali Khan',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Expert Plumber',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(' 4.9 (120 reviews)',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('2.5 km',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to provider profile (using dummy ID)
                    // Navigator.pushNamed(context, AppRoutes.userProvider.replaceAll(':id', '123'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(60, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
