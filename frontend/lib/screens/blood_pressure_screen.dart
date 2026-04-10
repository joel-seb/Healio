import 'package:flutter/material.dart';
import '../services/vitals_service.dart';
import '../widgets/page_header.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  String _result = '';
  String _resultDescription = '';
  String _recommendation = '';
  Color _resultColor = Colors.transparent;
  Color _darkResultColor = Colors.transparent;
  bool _showResult = false;

  void _checkBloodPressure() {
    if (_systolicController.text.isEmpty || _diastolicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both values')),
      );
      return;
    }

    int systolic = int.tryParse(_systolicController.text) ?? 0;
    int diastolic = int.tryParse(_diastolicController.text) ?? 0;

    setState(() {
      _showResult = true;

      if (systolic < 120 && diastolic < 80) {
        _result = 'Normal';
        _resultDescription = 'Your blood pressure is in the healthy range.';
        _recommendation = 'Keep up your healthy habits!';
        _resultColor = Color(0xFFD4EDDA);
        _darkResultColor = const Color(0xFF0C2010);
      } else if (systolic < 130 && diastolic < 80) {
        _result = 'Elevated';
        _resultDescription = 'Your blood pressure is slightly elevated.';
        _recommendation = 'Consider lifestyle changes to prevent hypertension.';
        _resultColor = Color(0xFFFFF3CD);
        _darkResultColor = const Color(0xFF2D2010);
      } else if (systolic < 140 || diastolic < 90) {
        _result = 'Stage 1 Hypertension';
        _resultDescription = 'Your blood pressure is elevated.';
        _recommendation = 'Consult with your doctor about lifestyle changes.';
        _resultColor = Color(0xFFFFE5CC);
        _darkResultColor = const Color(0xFF2D1500);
      } else if (systolic < 180 && diastolic < 120) {
        _result = 'Stage 2 Hypertension';
        _resultDescription = 'Your blood pressure is significantly elevated.';
        _recommendation = 'See a doctor as soon as possible.';
        _resultColor = Color(0xFFF8D7DA);
        _darkResultColor = const Color(0xFF200C0C);
      } else {
        _result = 'Hypertensive Crisis';
        _resultDescription = 'Your blood pressure is dangerously high.';
        _recommendation = 'Seek immediate medical attention!';
        _resultColor = Color(0xFFFF0000).withOpacity(0.2);
      }
    });
    saveVitalsToBackend(systolic: int.tryParse(_systolicController.text), diastolic: int.tryParse(_diastolicController.text));
    showVitalsSaved(context);
  }

  void _checkAnother() {
    setState(() {
      _systolicController.clear();
      _diastolicController.clear();
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
            title: 'Blood Pressure',
            subtitle: 'Monitor your BP levels',
            icon: Icons.favorite_border,
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
                  Icons.favorite,
                  size: 60,
                  color: Color(0xFF20B2AA),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Enter your blood pressure reading',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Systolic (mmHg)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _systolicController,
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
                  'Diastolic (mmHg)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _diastolicController,
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
                  onPressed: _checkBloodPressure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF20B2AA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Check Blood Pressure',
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
                                  : _result.contains('Elevated') ||
                                          _result.contains('Stage 1')
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
                                      : _result.contains('Elevated') ||
                                              _result.contains('Stage 1')
                                          ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                          : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _result,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _result.contains('Normal')
                                        ? Theme.of(context).brightness == Brightness.dark ? Color(0xFF81C784) : Color(0xFF155724)
                                        : _result.contains('Elevated') ||
                                                _result.contains('Stage 1')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F),
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
                                    : _result.contains('Elevated') ||
                                            _result.contains('Stage 1')
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
                                        : _result.contains('Elevated') ||
                                                _result.contains('Stage 1')
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
                                            : _result.contains('Elevated') ||
                                                    _result.contains('Stage 1')
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
                                        : _result.contains('Elevated') ||
                                                _result.contains('Stage 1')
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
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }
}
