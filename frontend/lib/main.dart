import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'theme/theme_controller.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'screens/medication_manager_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

// Global navigator key for notification tap navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Pending notification tap — fires after login if app was not ready
bool _pendingMedicationNavigation = false;

void navigateToMedicationsWhenReady() {
  _pendingMedicationNavigation = true;
  _tryNavigateToMedications();
}

void _tryNavigateToMedications() {
  final navState = navigatorKey.currentState;
  if (navState == null) {
    // Not ready yet — retry after delay
    Future.delayed(const Duration(milliseconds: 300), _tryNavigateToMedications);
    return;
  }
  if (!_pendingMedicationNavigation) return;
  // Check if we're past the splash/login screen
  final AuthService auth = AuthService();
  if (!auth.isLoggedIn) {
    // Not logged in yet — retry after delay
    Future.delayed(const Duration(milliseconds: 500), _tryNavigateToMedications);
    return;
  }
  _pendingMedicationNavigation = false;
  navState.push(
    MaterialPageRoute(builder: (_) => const MedicationManagerScreen()),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  if (Platform.isAndroid) {
    await _requestBatteryOptimizationExemption();
  }
  runApp(const HealioApp());
}

Future<void> _requestBatteryOptimizationExemption() async {
  const platform = MethodChannel('android_intent');
  try {
    await platform.invokeMethod('requestIgnoreBatteryOptimizations');
  } catch (_) {}
}

class HealioApp extends StatefulWidget {
  const HealioApp({super.key});
  @override
  State<HealioApp> createState() => _HealioAppState();
}

class _HealioAppState extends State<HealioApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
    // Handle notification tap when app is already running
    NotificationService().setOnNotificationTap((payload) {
      navigateToMedicationsWhenReady();
    });
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HEALIO',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 450),
          themeAnimationCurve: Curves.easeInOutCubic,
          navigatorKey: navigatorKey,
          home: SplashScreen(themeController: _themeController),
          builder: (context, child) {
            return ThemeControllerProvider(
              controller: _themeController,
              child: child!,
            );
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final ThemeController themeController;
  const SplashScreen({super.key, required this.themeController});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    // Navigate to the real app after 2.5 seconds
    Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => _AppShell(
              themeController: widget.themeController,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20B2AA),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                // App name
                const Text(
                  'HEALIO',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your personal health companion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Wrapper that rebuilds the router-based app after splash
class _AppShell extends StatelessWidget {
  final ThemeController themeController;
  const _AppShell({required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
    );
  }
}

class ThemeControllerProvider extends InheritedWidget {
  final ThemeController controller;
  const ThemeControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });
  static ThemeController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null, 'No ThemeControllerProvider found in context');
    return provider!.controller;
  }
  @override
  bool updateShouldNotify(ThemeControllerProvider oldWidget) =>
      controller != oldWidget.controller;
}
