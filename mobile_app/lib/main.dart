

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

// Auth Screens
import 'package:ease_home_service/features/auth/presentation/splash_screen.dart';
import 'package:ease_home_service/features/auth/presentation/onboarding_screen.dart';
import 'package:ease_home_service/features/auth/presentation/role_selection_screen.dart';
import 'package:ease_home_service/features/auth/presentation/sign_in_screen.dart';
import 'package:ease_home_service/features/auth/presentation/user_registration_screen.dart';
import 'package:ease_home_service/features/auth/presentation/otp_screen.dart';

// User Screens
import 'package:ease_home_service/features/user/presentation/home_dashboard_screen.dart';
import 'package:ease_home_service/features/user/presentation/profile_setup_screen.dart';
import 'package:ease_home_service/features/user/presentation/ai_request_screen.dart';
import 'package:ease_home_service/features/user/presentation/provider_map_screen.dart';
import 'package:ease_home_service/features/user/presentation/provider_profile_screen.dart';
import 'package:ease_home_service/features/user/presentation/price_quote_screen.dart';
import 'package:ease_home_service/features/user/presentation/booking_tracker_screen.dart';
import 'package:ease_home_service/features/user/presentation/live_chat_screen.dart';
import 'package:ease_home_service/features/user/presentation/service_completion_screen.dart';
import 'package:ease_home_service/features/user/presentation/dispute_filing_screen.dart';
import 'package:ease_home_service/features/user/presentation/booking_history_screen.dart';
import 'package:ease_home_service/features/user/presentation/receipt_detail_screen.dart';
import 'package:ease_home_service/features/user/presentation/notifications_screen.dart';
import 'package:ease_home_service/features/user/presentation/saved_providers_screen.dart';
import 'package:ease_home_service/features/user/presentation/no_provider_screen.dart';
import 'package:ease_home_service/features/user/presentation/user_settings_screen.dart';

// Provider Screens
import 'package:ease_home_service/features/service_provider/presentation/provider_home_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/job_request_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/active_job_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/job_completion_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/earnings_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/performance_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/demand_forecast_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/availability_calendar_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/dispute_response_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/job_history_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/provider_settings_screen.dart';
import 'package:ease_home_service/features/service_provider/presentation/provider_pending_screen.dart';

// Admin Screens
import 'package:ease_home_service/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:ease_home_service/features/admin/presentation/kyc_queue_screen.dart';
import 'package:ease_home_service/features/admin/presentation/dispute_center_screen.dart';
import 'package:ease_home_service/features/admin/presentation/user_management_screen.dart';
import 'package:ease_home_service/features/admin/presentation/provider_management_screen.dart';
import 'package:ease_home_service/features/admin/presentation/category_management_screen.dart';
import 'package:ease_home_service/features/admin/presentation/pricing_config_screen.dart';
import 'package:ease_home_service/features/admin/presentation/antigravity_logs_screen.dart';
import 'package:ease_home_service/features/admin/presentation/analytics_screen.dart';
import 'package:ease_home_service/features/admin/presentation/blacklist_screen.dart';
import 'package:ease_home_service/features/admin/presentation/admin_settings_screen.dart';

// ── Auth State ────────────────────────────────────────────────────────────────
enum AuthState {
  initial,
  unauthenticated,
  authenticatedUser,
  authenticatedProviderApproved,
  authenticatedProviderPending,
  authenticatedAdmin,
}

final authStateProvider =
    StateProvider<AuthState>((ref) => AuthState.initial);

// ── Entry Point ───────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncomment after running FlutterFire CLI:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseMessaging.instance.requestPermission();

  runApp(const ProviderScope(child: EaseHomeServiceApp()));
}

// ── Root App ──────────────────────────────────────────────────────────────────
class EaseHomeServiceApp extends ConsumerWidget {
  const EaseHomeServiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Routes that don't require authentication
    const authRoutes = {
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.roleSelect,      // ← fixed: was roleSelection
      AppRoutes.signIn,
      AppRoutes.registerUser,    // ← fixed: was register
      AppRoutes.verifyOtp,       // ← fixed: was otpVerify
    };

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isAuthRoute = authRoutes.contains(state.uri.path);

        if (authState == AuthState.unauthenticated && !isAuthRoute) {
          return AppRoutes.signIn;
        }
        if (authState == AuthState.authenticatedUser && isAuthRoute) {
          return AppRoutes.userHome;
        }
        if (authState == AuthState.authenticatedProviderApproved && isAuthRoute) {
          return AppRoutes.providerHome;
        }
        if (authState == AuthState.authenticatedProviderPending && isAuthRoute) {
          return AppRoutes.providerPending;
        }
        if (authState == AuthState.authenticatedAdmin && isAuthRoute) {
          return AppRoutes.adminDashboard;
        }
        return null;
      },
      routes: [
        // ── Auth / Initial ──────────────────────────────────────────────────
        GoRoute(path: AppRoutes.splash,
            builder: (c, s) => const SplashScreen()),
        GoRoute(path: AppRoutes.onboarding,
            builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.roleSelect,        // ← fixed
            builder: (c, s) => const RoleSelectionScreen()),
        GoRoute(path: AppRoutes.signIn,
            builder: (c, s) => const SignInScreen()),
        GoRoute(path: AppRoutes.registerUser,      // ← fixed
            builder: (c, s) => const UserRegistrationScreen()),
        GoRoute(path: AppRoutes.verifyOtp,         // ← fixed
            builder: (c, s) => const OtpScreen(phoneNumber: '',)),

        // ── User ────────────────────────────────────────────────────────────
        GoRoute(path: AppRoutes.userProfileSetup,
            builder: (c, s) => const ProfileSetupScreen()),
        GoRoute(path: AppRoutes.userHome,
            builder: (c, s) => const HomeDashboardScreen()),
        GoRoute(path: AppRoutes.userAiRequest,
            builder: (c, s) => const AiRequestScreen()),
        GoRoute(path: AppRoutes.userMap,
            builder: (c, s) => const ProviderMapScreen()),
        GoRoute(path: AppRoutes.userProvider,      // ← fixed: was userProviderProfile
            builder: (c, s) => ProviderProfileScreen(
                providerId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userQuote,         // ← fixed: was userCheckout
            builder: (c, s) => const PriceQuoteScreen()),
        GoRoute(path: AppRoutes.userTracker,       // ← fixed: was userBookingTrack
            builder: (c, s) => BookingTrackerScreen(
                bookingId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userChat,
            builder: (c, s) => LiveChatScreen(
                bookingId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userComplete,
            builder: (c, s) => ServiceCompletionScreen(
                bookingId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userDispute,
            builder: (c, s) => DisputeFilingScreen(
                bookingId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userBookings,
            builder: (c, s) => const BookingHistoryScreen()),
        GoRoute(path: AppRoutes.userReceipt,
            builder: (c, s) => ReceiptDetailScreen(
                bookingId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userNotifications,
            builder: (c, s) => const NotificationsScreen()),
        GoRoute(path: AppRoutes.userSaved,         // ← fixed: was userSavedProviders
            builder: (c, s) => const SavedProvidersScreen()),
        GoRoute(path: AppRoutes.userNoProvider,
            builder: (c, s) => const NoProviderScreen()),
        GoRoute(path: AppRoutes.userSettings,
            builder: (c, s) => const UserSettingsScreen()),

        // ── Service Provider ────────────────────────────────────────────────
        GoRoute(path: AppRoutes.providerHome,
            builder: (c, s) => const ProviderHomeScreen()),
        GoRoute(path: AppRoutes.providerJob,
            builder: (c, s) => JobRequestScreen(
                jobId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerActive,
            builder: (c, s) => ActiveJobScreen(
                jobId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerComplete,
            builder: (c, s) => JobCompletionScreen(
                jobId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerEarnings,
            builder: (c, s) => const EarningsScreen()),
        GoRoute(path: AppRoutes.providerPerformance,
            builder: (c, s) => const PerformanceScreen()),
        GoRoute(path: AppRoutes.providerDemand,
            builder: (c, s) => const DemandForecastScreen()),
        GoRoute(path: AppRoutes.providerCalendar,
            builder: (c, s) => const AvailabilityCalendarScreen()),
        GoRoute(path: AppRoutes.providerDispute,
            builder: (c, s) => DisputeResponseScreen(
                disputeId: s.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerJobHistory,
            builder: (c, s) => const JobHistoryScreen()),
        GoRoute(path: AppRoutes.providerSettings,
            builder: (c, s) => const ProviderSettingsScreen()),
        GoRoute(path: AppRoutes.providerPending,
            builder: (c, s) => const ProviderPendingScreen()),

        // ── Admin ───────────────────────────────────────────────────────────
        GoRoute(path: AppRoutes.adminDashboard,
            builder: (c, s) => const AdminDashboardScreen()),
        GoRoute(path: AppRoutes.adminKyc,
            builder: (c, s) => const KycQueueScreen()),
        GoRoute(path: AppRoutes.adminDisputes,
            builder: (c, s) => const DisputeCenterScreen()),
        GoRoute(path: AppRoutes.adminUsers,
            builder: (c, s) => const UserManagementScreen()),
        GoRoute(path: AppRoutes.adminProviders,
            builder: (c, s) => const ProviderManagementScreen()),
        GoRoute(path: AppRoutes.adminCategories,
            builder: (c, s) => const CategoryManagementScreen()),
        GoRoute(path: AppRoutes.adminPricing,
            builder: (c, s) => const PricingConfigScreen()),
        GoRoute(path: AppRoutes.adminLogs,
            builder: (c, s) => const AntigravityLogsScreen()),
        GoRoute(path: AppRoutes.adminAnalytics,
            builder: (c, s) => const AnalyticsScreen()),
        GoRoute(path: AppRoutes.adminBlacklist,
            builder: (c, s) => const BlacklistScreen()),
        GoRoute(path: AppRoutes.adminSettings,
            builder: (c, s) => const AdminSettingsScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Ease Home Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
