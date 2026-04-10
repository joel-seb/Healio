import 'package:flutter/material.dart';
import '../models/emergency_tutorial.dart';
import '../widgets/page_header.dart';
import 'emergency_detail_screen.dart';

class EmergencyTutorialScreen extends StatefulWidget {
  const EmergencyTutorialScreen({super.key});

  @override
  State<EmergencyTutorialScreen> createState() => _EmergencyTutorialScreenState();
}

class _EmergencyTutorialScreenState extends State<EmergencyTutorialScreen> {
  List<EmergencyTutorial> emergencies = EmergencyData.getEmergencies();

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'cancel_presentation':
        return Icons.cancel_presentation;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'pets':
        return Icons.pets;
      case 'healing':
        return Icons.healing;
      case 'bolt':
        return Icons.bolt;
      case 'psychology':
        return Icons.psychology;
      case 'waves':
        return Icons.waves;
      default:
        return Icons.emergency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Standardized Header
          const PageHeader(
            title: 'Emergency Tutorial',
            subtitle: 'Step-by-step emergency guides',
            icon: Icons.emergency,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),

                    // Warning Banner
                    Builder(builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2010) : const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFB74D), width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Color(0xFFFF6F00), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '⚡ In a Real Emergency',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6F00)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'CALL 112 FIRST! These guides help until professional help arrives.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFFFFCC80) : const Color(0xFFAA6F00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Reassuring Message
                    Builder(builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF102010) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4), width: 1) : null,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You\'re doing the right thing. Follow these steps calmly.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Section Title
                    Text(
                      'Emergency Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Emergency Category Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: emergencies.length,
                      itemBuilder: (context, index) {
                        final emergency = emergencies[index];
                        return _buildEmergencyCard(emergency);
                      },
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(EmergencyTutorial emergency) {
    final color = Color(int.parse(emergency.color));
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyDetailScreen(emergency: emergency),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Icon(
                _getIconData(emergency.icon),
                size: 40,
                color: color,
              ),
            ),
            SizedBox(height: 16),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                emergency.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: 8),
            
            // Urgency Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: emergency.urgencyLevel == 'Critical'
                    ? Color(0xFFD32F2F)
                    : emergency.urgencyLevel == 'High'
                        ? Color(0xFFFF6F00)
                        : Color(0xFFFFB74D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                emergency.urgencyLevel.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 8),
            
            // Offline Badge
            if (emergency.offlineAvailable)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.offline_bolt,
                    size: 14,
                    color: Color(0xFF7B8794),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Offline',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B8794),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
