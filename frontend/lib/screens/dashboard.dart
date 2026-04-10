import 'package:flutter/material.dart';
import '../theme/animated_theme_toggle.dart';
import '../main.dart';
import 'vitals_analysis.dart';
import 'profile.dart';
import 'user_data.dart';
import 'nearbyservices.dart';
import 'bmi_calculator.dart';
import 'heart_rate.dart';
import 'medication_manager_screen.dart';
import 'emergency_tutorial_screen.dart';
import 'disease_prediction_chat.dart';
import 'notifications_screen.dart';
import '../services/notifications_manager.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final UserData userData;

  const DashboardScreen({super.key, required this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 1; // Dashboard is selected by default

  // Derived live from the NotificationsManager singleton — never hardcoded
  int get _unreadNotifications => NotificationsManager().count;

  bool _vitalsLoading = false;

  Future<void> _loadLatestVitals() async {
    if (widget.userData.backendId == null || widget.userData.token == null) return;
    setState(() => _vitalsLoading = true);
    try {
      final api = ApiService()..setToken(widget.userData.token!);
      final vitals = await api.getLatestVitals(widget.userData.backendId!);
      if (mounted) {
        setState(() {
          widget.userData.heartRate = vitals['heart_rate'] as int?;
          widget.userData.systolic = vitals['systolic'] as int?;
          widget.userData.diastolic = vitals['diastolic'] as int?;
          widget.userData.bloodSugar = (vitals['blood_sugar'] as num?)?.toDouble();
          widget.userData.postMealSugar = (vitals['post_meal_sugar'] as num?)?.toDouble();
          widget.userData.bodyTemp = (vitals['body_temp'] as num?)?.toDouble();
          widget.userData.spo2 = vitals['spo2'] as int?;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _vitalsLoading = false);
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    NotificationsManager().addListener(_onNotificationsChanged);
    _loadLatestVitals();
  }

  @override
  void dispose() {
    NotificationsManager().removeListener(_onNotificationsChanged);
    super.dispose();
  }

  // Get the widget for the current tab
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        // Notifications with custom back navigation to go to dashboard tab
        return NotificationsScreen(
          onBack: () {
            setState(() {
              _currentIndex = 1; // Go back to dashboard tab
            });
          },
        );
      case 1:
        return _buildDashboardContent();
      case 2:
        return ProfileScreen(userData: widget.userData);
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'HEALIO',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // Theme toggle button
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(
              themeController: ThemeControllerProvider.of(context),
              lightModeIconColor: Colors.white,
              darkModeIconColor: Colors.white,
            ),
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: const Color(0xFF9CA8B4),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _unreadNotifications > 0
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotifications > 9
                                  ? '9+'
                                  : _unreadNotifications.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.notifications_outlined),
              activeIcon: _unreadNotifications > 0
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotifications > 9
                                  ? '9+'
                                  : _unreadNotifications.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.notifications),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Build the dashboard content widget
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section - blended with background
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.userData.name}',
                  style: (Theme.of(context).appBarTheme.titleTextStyle ?? const TextStyle()).copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          
          // Comprehensive Vitals Card - Compact 2x2 Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.04),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Row 1: Heart Rate & Blood Pressure
                    Row(
                      children: [
                        Expanded(
                          child: _buildVitalStat(
                            icon: Icons.favorite,
                            label: 'Heart Rate',
                            value: widget.userData.heartRate?.toString() ?? '--',
                            unit: 'bpm',
                            iconColor: const Color(0xFFE57373),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFFE8ECF0),
                        ),
                        Expanded(
                          child: _buildVitalStat(
                            icon: Icons.add_circle_outline,
                            label: 'Blood Pressure',
                            value: (widget.userData.systolic != null && widget.userData.diastolic != null)
                                ? '${widget.userData.systolic}/${widget.userData.diastolic}'
                                : '--/--',
                            unit: '',
                            iconColor: const Color(0xFF4FC3F7),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: Color(0xFFE8ECF0)),
                    ),
                    // Row 2: Blood Sugar & Body Temperature
                    Row(
                      children: [
                        Expanded(
                          child: _buildVitalStat(
                            icon: Icons.water_drop_outlined,
                            label: 'Blood Sugar',
                            value: (widget.userData.bloodSugar != null && widget.userData.postMealSugar != null)
                                ? '${widget.userData.bloodSugar!.toStringAsFixed(0)}/${widget.userData.postMealSugar!.toStringAsFixed(0)}'
                                : widget.userData.bloodSugar?.toStringAsFixed(0) ?? '--',
                            unit: 'mg/dL',
                            iconColor: const Color(0xFF20B2AA),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFFE8ECF0),
                        ),
                        Expanded(
                          child: _buildVitalStat(
                            icon: Icons.thermostat_outlined,
                            label: 'Body Temp',
                            value: widget.userData.bodyTemp?.toStringAsFixed(1) ?? '--',
                            unit: '°C',
                            iconColor: const Color(0xFFFFB74D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // Health Services Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(context: context, 
                    icon: Icons.chat_bubble_outline,
                    title: 'Health Assistant',
                    subtitle: 'Chat with AI about symptoms',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiseasePredictionChat(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildServiceCard(context: context, 
                    icon: Icons.location_on_outlined,
                    title: 'Nearby Medical Services',
                    subtitle: 'Hospitals & clinics near you',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NearbyServicesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildServiceCard(context: context, 
                    icon: Icons.emergency_outlined,
                    title: 'Emergency Tutorial',
                    subtitle: 'Life-saving procedures',
                    iconColor: const Color(0xFFE57373),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyTutorialScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Health Tracking Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Tracking',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(context: context, 
                    icon: Icons.monitor_heart_outlined,
                    title: 'Vitals Analysis',
                    subtitle: 'BP, Sugar, BMI & more',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VitalsAnalysisScreen(userData: widget.userData),
                        ),
                      ).then((_) => _loadLatestVitals());
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildServiceCard(context: context, 
                    icon: Icons.medication_outlined,
                    title: 'Medication Manager',
                    subtitle: 'Reminders & prescriptions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicationManagerScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildVitalStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF20B2AA)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF20B2AA),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }
}
