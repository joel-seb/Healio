import 'package:go_router/go_router.dart';
import '../screens/login.dart';
import '../screens/dashboard.dart';
import '../screens/user_data.dart';
import '../screens/medication_manager_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/disease_prediction_chat.dart';
import '../screens/emergency_tutorial_screen.dart';
import '../screens/vitals_analysis.dart';
import '../screens/bmi_calculator.dart';
import '../screens/heart_rate.dart';
import '../screens/blood_pressure_screen.dart';
import '../screens/blood_sugar_screen.dart';
import '../screens/body_temperature_screen.dart';
import '../screens/spo2_screen.dart';
import '../screens/nearbyservices.dart';
import '../screens/profile.dart';
import '../screens/edit_profile.dart';

/// Route path constants — use these everywhere instead of raw strings.
class AppRoutes {
  AppRoutes._();
  static const login         = '/';
  static const dashboard     = '/dashboard';
  static const medications   = '/medications';
  static const notifications = '/notifications';
  static const diseaseChat   = '/disease-check';
  static const emergency     = '/emergency';
  static const vitals        = '/vitals';
  static const bmi           = '/bmi';
  static const heartRate     = '/heart-rate';
  static const bloodPressure = '/blood-pressure';
  static const bloodSugar    = '/blood-sugar';
  static const bodyTemp      = '/body-temperature';
  static const spo2          = '/spo2';
  static const nearby        = '/nearby-services';
  static const profile       = '/profile';
  static const editProfile   = '/edit-profile';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => Login(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) {
        final userData = state.extra as UserData? ?? UserData();
        return DashboardScreen(userData: userData);
      },
    ),
    GoRoute(
      path: AppRoutes.medications,
      builder: (context, state) => const MedicationManagerScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => NotificationsScreen(
        onBack: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.diseaseChat,
      builder: (context, state) => const DiseasePredictionChat(),
    ),
    GoRoute(
      path: AppRoutes.emergency,
      builder: (context, state) => const EmergencyTutorialScreen(),
    ),
    GoRoute(
      path: AppRoutes.vitals,
      builder: (context, state) {
        final userData = state.extra as UserData? ?? UserData();
        return VitalsAnalysisScreen(userData: userData);
      },
    ),
    GoRoute(
      path: AppRoutes.bmi,
      builder: (context, state) => const BMICalculatorScreen(),
    ),
    GoRoute(
      path: AppRoutes.heartRate,
      builder: (context, state) => const HeartRateScreen(),
    ),
    GoRoute(
      path: AppRoutes.bloodPressure,
      builder: (context, state) => const BloodPressureScreen(),
    ),
    GoRoute(
      path: AppRoutes.bloodSugar,
      builder: (context, state) => const BloodSugarScreen(),
    ),
    GoRoute(
      path: AppRoutes.bodyTemp,
      builder: (context, state) => const BodyTemperatureScreen(),
    ),
    GoRoute(
      path: AppRoutes.spo2,
      builder: (context, state) => const SpO2Screen(),
    ),
    GoRoute(
      path: AppRoutes.nearby,
      builder: (context, state) => const NearbyServicesScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        final userData = state.extra as UserData? ?? UserData();
        return ProfileScreen(userData: userData);
      },
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) {
        final userData = state.extra as UserData? ?? UserData();
        return EditProfileScreen(userData: userData);
      },
    ),
  ],
);
