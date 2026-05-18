import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ease_home_service/core/constants/app_colors.dart';
import 'package:ease_home_service/core/constants/app_routes.dart';

// Import screens (adjust paths based on your actual structure)
import 'package:ease_home_service/features/auth/presentation/splash_screen.dart';
import 'package:ease_home_service/features/auth/presentation/onboarding_screen.dart';
import 'package:ease_home_service/features/auth/presentation/role_selection_screen.dart';
import 'package:ease_home_service/features/auth/presentation/sign_in_screen.dart';
import 'package:ease_home_service/features/auth/presentation/registration_screen.dart';
import 'package:ease_home_service/features/auth/presentation/otp_verification_screen.dart';

// User Screens
import 'package:ease_home_service/features/user/presentation/home_dashboard_screen.dart';
import 'package:ease_home_service/features/user/presentation/profile_setup_screen.dart';
import 'package:ease_home_service/features/user/presentation/ai_request_screen.dart';
import 'package:ease_home_service/features/user/presentation/provider_map_screen.dart';
import 'package:ease_home_service/features/user/presentation/provider_profile_screen.dart';
import 'package:ease_home_service/features/user/presentation/checkout_screen.dart';
import 'package:ease_home_service/features/user/presentation/booking_tracking_screen.dart';
import 'package:ease_home_service/features/user/presentation/chat_screen.dart';
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

// Mock Auth Provider for Routing Logic (Replace with actual auth_provider)
final authStateProvider = StateProvider<AuthState>((ref) => AuthState.initial);

enum AuthState { initial, unauthenticated, authenticatedUser, authenticatedProviderApproved, authenticatedProviderPending, authenticatedAdmin }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Uncomment when firebase_options.dart is generated via FlutterFire CLI
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Request FCM Permission
  // await FirebaseMessaging.instance.requestPermission();

  // runApp(
  //   const ProviderScope(
  //     child: EaseHomeServiceApp(),
  //   ),
  // );
  runApp(const ProviderScope(child: MyApp()));
}

class EaseHomeServiceApp extends ConsumerWidget {
  const EaseHomeServiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isAuthRoute = state.uri.path == AppRoutes.signIn || 
                            state.uri.path == AppRoutes.register || 
                            state.uri.path == AppRoutes.otpVerify ||
                            state.uri.path == AppRoutes.roleSelection ||
                            state.uri.path == AppRoutes.onboarding ||
                            state.uri.path == AppRoutes.splash;

        // Route Guards
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
        // Auth / Initial Routes
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.roleSelection, builder: (context, state) => const RoleSelectionScreen()),
        GoRoute(path: AppRoutes.signIn, builder: (context, state) => const SignInScreen()),
        GoRoute(path: AppRoutes.register, builder: (context, state) => const RegistrationScreen()),
        GoRoute(path: AppRoutes.otpVerify, builder: (context, state) => const OtpVerificationScreen()),

        // User Routes
        GoRoute(path: AppRoutes.userProfileSetup, builder: (context, state) => const ProfileSetupScreen()),
        GoRoute(path: AppRoutes.userHome, builder: (context, state) => const HomeDashboardScreen()),
        GoRoute(path: AppRoutes.userAiRequest, builder: (context, state) => const AiRequestScreen()),
        GoRoute(path: AppRoutes.userMap, builder: (context, state) => const ProviderMapScreen()),
        GoRoute(path: AppRoutes.userProviderProfile, builder: (context, state) => ProviderProfileScreen(providerId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userCheckout, builder: (context, state) => CheckoutScreen(providerId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userBookingTrack, builder: (context, state) => BookingTrackingScreen(bookingId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userChat, builder: (context, state) => ChatScreen(bookingId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userComplete, builder: (context, state) => ServiceCompletionScreen(bookingId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userDispute, builder: (context, state) => DisputeFilingScreen(bookingId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userBookings, builder: (context, state) => const BookingHistoryScreen()),
        GoRoute(path: AppRoutes.userReceipt, builder: (context, state) => ReceiptDetailScreen(bookingId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.userNotifications, builder: (context, state) => const NotificationsScreen()),
        GoRoute(path: AppRoutes.userSavedProviders, builder: (context, state) => const SavedProvidersScreen()),
        GoRoute(path: AppRoutes.userNoProvider, builder: (context, state) => const NoProviderScreen()),
        GoRoute(path: AppRoutes.userSettings, builder: (context, state) => const UserSettingsScreen()),

        // Provider Routes
        GoRoute(path: AppRoutes.providerHome, builder: (context, state) => const ProviderHomeScreen()),
        GoRoute(path: AppRoutes.providerJob, builder: (context, state) => JobRequestScreen(jobId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerActive, builder: (context, state) => ActiveJobScreen(jobId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerComplete, builder: (context, state) => JobCompletionScreen(jobId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerEarnings, builder: (context, state) => const EarningsScreen()),
        GoRoute(path: AppRoutes.providerPerformance, builder: (context, state) => const PerformanceScreen()),
        GoRoute(path: AppRoutes.providerDemand, builder: (context, state) => const DemandForecastScreen()),
        GoRoute(path: AppRoutes.providerCalendar, builder: (context, state) => const AvailabilityCalendarScreen()),
        GoRoute(path: AppRoutes.providerDispute, builder: (context, state) => DisputeResponseScreen(disputeId: state.pathParameters['id'] ?? '')),
        GoRoute(path: AppRoutes.providerJobHistory, builder: (context, state) => const JobHistoryScreen()),
        GoRoute(path: AppRoutes.providerSettings, builder: (context, state) => const ProviderSettingsScreen()),
        GoRoute(path: AppRoutes.providerPending, builder: (context, state) => const ProviderPendingScreen()),

        // Admin Routes
        GoRoute(path: AppRoutes.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: AppRoutes.adminKyc, builder: (context, state) => const KycQueueScreen()),
        GoRoute(path: AppRoutes.adminDisputes, builder: (context, state) => const DisputeCenterScreen()),
        GoRoute(path: AppRoutes.adminUsers, builder: (context, state) => const UserManagementScreen()),
        GoRoute(path: AppRoutes.adminProviders, builder: (context, state) => const ProviderManagementScreen()),
        GoRoute(path: AppRoutes.adminCategories, builder: (context, state) => const CategoryManagementScreen()),
        GoRoute(path: AppRoutes.adminPricing, builder: (context, state) => const PricingConfigScreen()),
        GoRoute(path: AppRoutes.adminLogs, builder: (context, state) => const AntigravityLogsScreen()),
        GoRoute(path: AppRoutes.adminAnalytics, builder: (context, state) => const AnalyticsScreen()),
        GoRoute(path: AppRoutes.adminBlacklist, builder: (context, state) => const BlacklistScreen()),
        GoRoute(path: AppRoutes.adminSettings, builder: (context, state) => const AdminSettingsScreen()),
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
