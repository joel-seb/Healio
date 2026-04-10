import 'package:flutter/material.dart';
import '../widgets/page_header.dart';
import '../services/vitals_service.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  final TextEditingController _heartRateController = TextEditingController();
  
  int? _heartRateResult;
  String _heartRateCategory = '';
  String _heartRateDescription = '';
  String _heartRateAdvice = '';
  Color _resultColor = Color(0xFF9CA8B4);
  Color _darkResultColor = const Color(0xFF1E293B);
  IconData _resultIcon = Icons.info_outline;

  @override
  void dispose() {
    _heartRateController.dispose();
    super.dispose();
  }

  void _checkHeartRate() {
    final heartRate = int.tryParse(_heartRateController.text);

    if (heartRate == null || heartRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid heart rate value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (heartRate > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Heart rate seems too high. Please check the value.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _heartRateResult = heartRate;
      _categorizeHeartRate(heartRate);
    });
    // Persist to backend
    saveVitalsToBackend(heartRate: heartRate);
    showVitalsSaved(context);
  }

  void _categorizeHeartRate(int heartRate) {
    if (heartRate < 40) {
      _heartRateCategory = 'Bradycardia (Too Low)';
      _heartRateDescription = 'Your resting heart rate is significantly below normal range.';
      _heartRateAdvice = 'Consult a healthcare provider to rule out underlying conditions.';
      _resultColor = Color(0xFFFFCDD2);
      _darkResultColor = const Color(0xFF200C0C);
      _resultIcon = Icons.error_outline;
    } else if (heartRate < 60) {
      _heartRateCategory = 'Athletic/Low';
      _heartRateDescription = 'Your heart rate is lower than average, which is common in athletic individuals.';
      _heartRateAdvice = 'This is generally healthy, especially if you exercise regularly.';
      _resultColor = Color(0xFFB3E5FC);
      _darkResultColor = const Color(0xFF0C1A2D);
      _resultIcon = Icons.info_outline;
    } else if (heartRate <= 100) {
      _heartRateCategory = 'Normal';
      _heartRateDescription = 'Your resting heart rate is within the healthy range.';
      _heartRateAdvice = 'Great! Continue with regular physical activity.';
      _resultColor = Color(0xFFC8E6C9);
      _darkResultColor = const Color(0xFF0C2010);
      _resultIcon = Icons.check_circle_outline;
    } else if (heartRate <= 120) {
      _heartRateCategory = 'Elevated';
      _heartRateDescription = 'Your resting heart rate is slightly above the normal range.';
      _heartRateAdvice = 'Consider stress management and regular exercise to lower it.';
      _resultColor = Color(0xFFFFE0B2);
      _darkResultColor = const Color(0xFF2D1A00);
      _resultIcon = Icons.warning_outlined;
    } else {
      _heartRateCategory = 'Tachycardia (Too High)';
      _heartRateDescription = 'Your resting heart rate is significantly above normal range.';
      _heartRateAdvice = 'Consult a healthcare provider as soon as possible.';
      _resultColor = Color(0xFFFFCDD2);
      _darkResultColor = const Color(0xFF200C0C);
      _resultIcon = Icons.error_outline;
    }
  }

  void _resetChecker() {
    setState(() {
      _heartRateController.clear();
      _heartRateResult = null;
      _heartRateCategory = '';
      _heartRateDescription = '';
      _heartRateAdvice = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const PageHeader(
            title: 'Heart Rate',
            subtitle: 'Monitor your heart rate',
            icon: Icons.favorite_outline,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(height: 4),
                    // Icon Circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFF20B2AA).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 50,
                        color: Color(0xFF20B2AA),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Description Text
                    Text(
                      'Enter your resting heart rate',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 32),

                    // Heart Rate Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Heart Rate (bpm)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
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
                          child: TextField(
                            controller: _heartRateController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '72',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA8B4),
                                fontSize: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2D3748)
                                  : Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Info Box
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF20B2AA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF20B2AA).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF20B2AA),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Normal resting heart rate for adults: 60-100 bpm',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Check Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF20B2AA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _checkHeartRate,
                        child: Text(
                          'Check Heart Rate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).cardTheme.color ?? Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Result Section
                    if (_heartRateResult != null) ...[
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? _darkResultColor : _resultColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            left: BorderSide(
                              color: _getAccentColor(_resultColor),
                              width: 6,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heart Rate Value and Category
                            Row(
                              children: [
                                Icon(
                                  _resultIcon,
                                  color: _getAccentColor(_resultColor),
                                  size: 28,
                                ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _heartRateCategory,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _getAccentColor(_resultColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Description
                                  Text(
                                    _heartRateDescription,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _getAccentColor(_resultColor).withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 16),

                                  // Advice Box
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black.withOpacity(0.3)
                                          : Theme.of(context).cardTheme.color?.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_forward,
                                          color: _getAccentColor(_resultColor),
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _heartRateAdvice,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _getAccentColor(_resultColor),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Check Another Button
                              Center(
                                child: TextButton(
                                  onPressed: _resetChecker,
                                  child: Text(
                                    'Check Another',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _getAccentColor(_resultColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccentColor(Color backgroundColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (backgroundColor == Color(0xFFC8E6C9)) {
      return isDark ? Color(0xFF81C784) : Color(0xFF2E7D32);
    } else if (backgroundColor == Color(0xFFB3E5FC)) {
      return isDark ? Color(0xFF64B5F6) : Color(0xFF0277BD);
    } else if (backgroundColor == Color(0xFFFFE0B2)) {
      return isDark ? Color(0xFFFFB74D) : Color(0xFFE65100);
    } else {
      return isDark ? Color(0xFFEF9A9A) : Color(0xFFC62828);
    }
  }
}
