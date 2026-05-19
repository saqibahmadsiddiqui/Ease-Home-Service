import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/preferences_helper.dart';
import '../../../../core/services/api_client.dart';
import '../../../../main.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initRouting();
  }

  void _initRouting() async {
    // Wait exactly 3 seconds for a clean and beautiful splash transition
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final firstTime = await PreferencesHelper.isFirstTime();
    if (!mounted) return;
    if (firstTime) {
      context.go(AppRoutes.onboarding);
      return;
    }

    final storedStateName = await PreferencesHelper.getAuthState();
    final token = await PreferencesHelper.getAuthToken();
    if (!mounted) return;

    if (token != null) {
      ref.read(authTokenProvider.notifier).state = token;
    }

    if (storedStateName == 'authenticatedUser') {
      ref.read(authStateProvider.notifier).state = AuthState.authenticatedUser;
      context.go(AppRoutes.userHome);
    } else if (storedStateName == 'authenticatedProviderApproved') {
      ref.read(authStateProvider.notifier).state = AuthState.authenticatedProviderApproved;
      context.go(AppRoutes.providerHome);
    } else if (storedStateName == 'authenticatedAdmin') {
      ref.read(authStateProvider.notifier).state = AuthState.authenticatedAdmin;
      context.go(AppRoutes.adminDashboard);
    } else {
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
      context.go(AppRoutes.roleSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: AppTextStyles.h1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
