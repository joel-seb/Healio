import 'package:flutter/material.dart';
import '../services/vitals_service.dart';
import '../widgets/page_header.dart';

class BloodSugarScreen extends StatefulWidget {
  const BloodSugarScreen({super.key});

  @override
  State<BloodSugarScreen> createState() => _BloodSugarScreenState();
}

class _BloodSugarScreenState extends State<BloodSugarScreen> {
  final TextEditingController _fastingController = TextEditingController();
  final TextEditingController _postMealController = TextEditingController();
  String _result = '';
  String _resultDescription = '';
  String _recommendation = '';
  Color _resultColor = Colors.transparent;
  Color _darkResultColor = Colors.transparent;
  bool _showResult = false;

  void _checkBloodSugar() {
    if (_fastingController.text.isEmpty || _postMealController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both values')),
      );
      return;
    }

    int fasting = int.tryParse(_fastingController.text) ?? 0;
    int postMeal = int.tryParse(_postMealController.text) ?? 0;

    setState(() {
      _showResult = true;

      // Check fasting and post-meal levels
      if (fasting < 100 && postMeal < 140) {
        _result = 'Normal';
        _resultDescription = 'Your blood sugar levels are in the healthy range.';
        _recommendation = 'No concerns. Keep up your healthy habits.';
        _resultColor = Color(0xFFD4EDDA);
        _darkResultColor = const Color(0xFF0C2010);
      } else if ((fasting >= 100 && fasting < 126) || (postMeal >= 140 && postMeal < 200)) {
        _result = 'Prediabetic Range';
        _resultDescription = 'Your levels are above normal but not yet diabetic.';
        _recommendation = 'Monitor closely. Adopt a healthier diet and exercise routine.';
        _resultColor = Color(0xFFFFF3CD);
        _darkResultColor = const Color(0xFF2D2010);
      } else {
        _result = 'Diabetic Range';
        _resultDescription = 'Your blood sugar levels indicate diabetes.';
        _recommendation = 'Consult a doctor immediately for proper diagnosis and treatment.';
        _resultColor = Color(0xFFF8D7DA);
        _darkResultColor = const Color(0xFF200C0C);
      }
    });
    saveVitalsToBackend(
      bloodSugar: double.tryParse(_fastingController.text),
      postMealSugar: double.tryParse(_postMealController.text),
    );
    showVitalsSaved(context);
  }

  void _checkAnother() {
    setState(() {
      _fastingController.clear();
      _postMealController.clear();
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const PageHeader(
            title: 'Blood Sugar',
            subtitle: 'Track your glucose levels',
            icon: Icons.water_drop_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Color(0xFF20B2AA).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.opacity,
                        size: 60,
                        color: Color(0xFF20B2AA),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Enter your blood sugar levels',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8BA9A5),
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Fasting (mg/dL)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _fastingController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2D3748)
                                  : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Post-meal (mg/dL)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _postMealController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2D3748)
                                  : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _checkBloodSugar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF20B2AA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Check Blood Sugar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).cardTheme.color ?? Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    if (_showResult)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? _darkResultColor : _resultColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(
                              color: _result.contains('Normal')
                                  ? Color(0xFF20B2AA)
                                  : _result.contains('Prediabetic')
                                      ? Color(0xFFFFAA00)
                                      : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _result.contains('Normal')
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _result.contains('Normal')
                                      ? Color(0xFF20B2AA)
                                      : _result.contains('Prediabetic')
                                          ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                          : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _result,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _result.contains('Normal')
                                          ? Theme.of(context).brightness == Brightness.dark ? Color(0xFF81C784) : Color(0xFF155724)
                                          : _result.contains('Prediabetic')
                                              ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                              : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              _resultDescription,
                              style: TextStyle(
                                fontSize: 15,
                                color: _result.contains('Normal')
                                    ? Theme.of(context).brightness == Brightness.dark ? Color(0xFF81C784) : Color(0xFF155724)
                                    : _result.contains('Prediabetic')
                                        ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                        : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.3)
                                  : Theme.of(context).cardTheme.color?.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_forward,
                                    color: _result.contains('Normal')
                                        ? Color(0xFF20B2AA)
                                        : _result.contains('Prediabetic')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _recommendation,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _result.contains('Normal')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFF81C784) : Color(0xFF155724)
                                            : _result.contains('Prediabetic')
                                                ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                                : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: TextButton(
                                onPressed: _checkAnother,
                                child: Text(
                                  'Check Another',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _result.contains('Normal')
                                        ? Color(0xFF20B2AA)
                                        : _result.contains('Prediabetic')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fastingController.dispose();
    _postMealController.dispose();
    super.dispose();
  }
}
