import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
  }

  void _onGetStarted() {
    Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text('Skip', style: AppTextStyles.body1.copyWith(color: AppColors.primary)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    icon: Icons.search,
                    title: 'Find Services',
                    description: 'Easily find home services in your area.',
                  ),
                  _buildSlide(
                    icon: Icons.calendar_today,
                    title: 'Book Instantly',
                    description: 'Schedule a booking in just a few taps.',
                  ),
                  _buildSlide(
                    icon: Icons.star,
                    title: 'Top Providers',
                    description: 'Get service from top-rated professionals.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage == 2)
                    CustomButton(
                      text: 'Get Started',
                      onPressed: _onGetStarted,
                    )
                  else
                    const SizedBox(height: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppColors.primary),
          const SizedBox(height: 40),
          Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(description, style: AppTextStyles.body1, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
