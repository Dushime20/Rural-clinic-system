import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/location_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/diagnosis/presentation/pages/diagnosis_page.dart';
import 'features/diagnosis/presentation/pages/diagnosis_result_page.dart';
import 'features/diagnosis/presentation/pages/diagnosis_history_page.dart';
import 'features/diagnosis/presentation/pages/home_page.dart';
import 'features/patient/presentation/pages/patient_list_page.dart';
import 'features/patient/presentation/pages/patient_detail_page.dart';
import 'features/patient/presentation/pages/add_patient_page.dart';
import 'features/patient/presentation/pages/edit_patient_page.dart';
import 'features/patient/presentation/pages/patient_medical_history_page.dart';
import 'features/pharmacy/presentation/pages/pharmacies_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/pages/help_support_page.dart';
import 'features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'features/sync/presentation/pages/sync_status_page.dart';
import 'features/sync/presentation/pages/offline_mode_page.dart';
import 'shared/widgets/splash_screen.dart';
import 'shared/widgets/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize location service early to request permission
  // This ensures location is available when diagnosis runs
  LocationService().initialize().catchError((e) {
    debugPrint('Location service initialization failed: $e');
  });

  runApp(const ProviderScope(child: HealthCompanionApp()));
}

class HealthCompanionApp extends ConsumerWidget {
  const HealthCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,

      // Localization configuration
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        // Kinyarwanda (rw) is not included in GlobalMaterialLocalizations or
        // GlobalCupertinoLocalizations. The fallback delegates below proxy rw
        // to en so Material/Cupertino widgets always find their localizations.
        const _FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        const _FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('rw'), // Kinyarwanda
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fallback delegates for locales not covered by GlobalMaterialLocalizations
// or GlobalCupertinoLocalizations (e.g. Kinyarwanda / rw).
// They accept every locale and proxy unsupported ones to English so that
// Material and Cupertino widgets always find their required localizations.
// ---------------------------------------------------------------------------

class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // accept all locales

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // If the locale is directly supported, use it; otherwise fall back to en.
    final effective =
        GlobalMaterialLocalizations.delegate.isSupported(locale)
            ? locale
            : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // accept all locales

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final effective =
        GlobalCupertinoLocalizations.delegate.isSupported(locale)
            ? locale
            : const Locale('en');
    return GlobalCupertinoLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}

// ---------------------------------------------------------------------------

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return ResetPasswordPage(token: token);
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) {
        final isFirstTime = state.uri.queryParameters['firstTime'] == 'true';
        return ChangePasswordPage(isFirstTime: isFirstTime);
      },
    ),
    GoRoute(
      path: '/home',
      builder:
          (context, state) =>
              const MainNavigationWrapper(currentIndex: 0, child: HomePage()),
    ),
    GoRoute(
      path: '/diagnosis',
      builder:
          (context, state) => const MainNavigationWrapper(
            currentIndex: 1,
            child: DiagnosisPage(),
          ),
    ),
    GoRoute(
      path: '/patients',
      builder:
          (context, state) => const MainNavigationWrapper(
            currentIndex: 2,
            child: PatientListPage(),
          ),
    ),
    GoRoute(
      path: '/pharmacies',
      builder:
          (context, state) => const MainNavigationWrapper(
            currentIndex: 3,
            child: PharmaciesPage(),
          ),
    ),
    GoRoute(
      path: '/patient/add',
      builder: (context, state) => const AddPatientPage(),
    ),
    GoRoute(
      path: '/patient/:id/edit',
      builder: (context, state) {
        final patientId = state.pathParameters['id']!;
        final patientData = state.extra as Map<String, dynamic>?;
        return EditPatientPage(patientId: patientId, patientData: patientData);
      },
    ),
    GoRoute(
      path: '/patient/:id',
      builder: (context, state) {
        final patientId = state.pathParameters['id']!;
        return MainNavigationWrapper(
          currentIndex: 2,
          child: PatientDetailPage(patientId: patientId),
        );
      },
    ),
    GoRoute(
      path: '/analytics',
      builder:
          (context, state) => const MainNavigationWrapper(
            currentIndex: 3,
            child: AnalyticsDashboardPage(),
          ),
    ),
    GoRoute(
      path: '/sync',
      builder:
          (context, state) => const MainNavigationWrapper(
            currentIndex: 3,
            child: SyncStatusPage(),
          ),
    ),
    GoRoute(
      path: '/settings',
      builder:
          (context, state) => const MainNavigationWrapper(
            currentIndex: 4,
            child: SettingsPage(),
          ),
    ),
    GoRoute(
      path: '/diagnosis/result',
      builder: (context, state) {
        final diagnosisData = state.extra as Map<String, dynamic>;
        return DiagnosisResultPage(diagnosisData: diagnosisData);
      },
    ),
    GoRoute(
      path: '/diagnosis/history',
      builder: (context, state) => const DiagnosisHistoryPage(),
    ),
    GoRoute(
      path: '/patient/:id/history',
      builder: (context, state) {
        final patientId = state.pathParameters['id']!;
        return PatientMedicalHistoryPage(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpSupportPage(),
    ),
    GoRoute(
      path: '/offline',
      builder: (context, state) => const OfflineModePage(),
    ),
  ],
);
