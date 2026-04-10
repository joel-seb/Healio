import 'package:flutter/material.dart';
import '../widgets/page_header.dart';
import 'profile.dart';
import 'user_data.dart';
import 'bmi_calculator.dart';
import 'heart_rate.dart';
import 'blood_pressure_screen.dart';
import 'blood_sugar_screen.dart';
import 'body_temperature_screen.dart';
import 'spo2_screen.dart';

class VitalsAnalysisScreen extends StatefulWidget {
  final UserData userData;

  const VitalsAnalysisScreen({super.key, required this.userData});

  @override
  State<VitalsAnalysisScreen> createState() => _VitalsAnalysisScreenState();
}

class _VitalsAnalysisScreenState extends State<VitalsAnalysisScreen> {
  late UserData currentUserData;

  @override
  void initState() {
    super.initState();
    currentUserData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Standardized Header
          const PageHeader(
            title: 'Vitals Analysis',
            subtitle: 'Check your health vitals',
            icon: Icons.monitor_heart,
          ),

          // Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    
                    // BMI Checker
                    StandardCard(
                      icon: Icons.monitor_weight_outlined,
                      title: 'BMI Checker',
                      subtitle: 'Calculate your body mass index',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BMICalculatorScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Heart Rate
                    StandardCard(
                      icon: Icons.favorite_outline,
                      title: 'Heart Rate',
                      subtitle: 'Monitor your heart rate',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HeartRateScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Blood Sugar
                    StandardCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Blood Sugar',
                      subtitle: 'Track your glucose levels',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BloodSugarScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Body Temperature
                    StandardCard(
                      icon: Icons.thermostat_outlined,
                      title: 'Body Temperature',
                      subtitle: 'Record your temperature',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BodyTemperatureScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Blood Pressure
                    StandardCard(
                      icon: Icons.favorite_border,
                      title: 'Blood Pressure',
                      subtitle: 'Monitor your BP levels',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BloodPressureScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // SpO2
                    StandardCard(
                      icon: Icons.air_outlined,
                      title: 'SpO₂',
                      subtitle: 'Check oxygen saturation',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpO2Screen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Disclaimer
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20B2AA).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF20B2AA).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF20B2AA),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This app does not replace professional medical advice. Always consult your healthcare provider.',
                              style: TextStyle(
                                color: const Color(0xFF5A6C7D),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
