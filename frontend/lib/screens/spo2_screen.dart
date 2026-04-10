import 'package:flutter/material.dart';
import '../services/vitals_service.dart';

class SpO2Screen extends StatefulWidget {
  const SpO2Screen({super.key});

  @override
  State<SpO2Screen> createState() => _SpO2ScreenState();
}

class _SpO2ScreenState extends State<SpO2Screen> {
  final TextEditingController _spo2Controller = TextEditingController();
  String _result = '';
  String _resultDescription = '';
  String _recommendation = '';
  Color _resultColor = Colors.transparent;
  Color _darkResultColor = Colors.transparent;
  bool _showResult = false;

  void _checkSpO2() {
    if (_spo2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter SpO2 value')),
      );
      return;
    }

    int spo2 = int.tryParse(_spo2Controller.text) ?? 0;

    if (spo2 < 0 || spo2 > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid SpO2 value (0-100)')),
      );
      return;
    }

    setState(() {
      _showResult = true;

      if (spo2 >= 95) {
        _result = 'Normal';
        _resultDescription = 'Your oxygen saturation is in the healthy range.';
        _recommendation = 'No concerns. Keep up your healthy habits.';
        _resultColor = Color(0xFFD4EDDA);
        _darkResultColor = const Color(0xFF0C2010);
      } else if (spo2 >= 90) {
        _result = 'Low Oxygen';
        _resultDescription = 'Your oxygen saturation is slightly below normal.';
        _recommendation = 'Monitor your breathing. See a doctor if symptoms develop.';
        _resultColor = Color(0xFFFFF3CD);
        _darkResultColor = const Color(0xFF2D2010);
      } else if (spo2 >= 85) {
        _result = 'Very Low Oxygen';
        _resultDescription = 'Your oxygen saturation is significantly low.';
        _recommendation = 'Seek medical attention soon. This may require oxygen therapy.';
        _resultColor = Color(0xFFFFE5CC);
        _darkResultColor = const Color(0xFF2D1500);
      } else {
        _result = 'Critical';
        _resultDescription = 'Your oxygen saturation is critically low.';
        _recommendation = 'Seek immediate medical attention! Call emergency services.';
        _resultColor = Color(0xFFF8D7DA);
        _darkResultColor = const Color(0xFF200C0C);
      }
    });
    saveVitalsToBackend(spo2: int.tryParse(_spo2Controller.text));
    showVitalsSaved(context);
  }

  void _checkAnother() {
    setState(() {
      _spo2Controller.clear();
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom header with air icon
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Back button
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color, size: 24),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: 16),
                        // Air icon badge
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF20B2AA).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.air_outlined,
                            color: Color(0xFF20B2AA),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        // Title with proper SpO₂ formatting
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Theme.of(context).textTheme.displaySmall?.color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              children: const [
                                TextSpan(text: 'SpO'),
                                TextSpan(
                                  text: '₂',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFeatures: [FontFeature.subscripts()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: 80),
                      child: Text(
                        'Check oxygen saturation',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 4),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Color(0xFF20B2AA).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.air_outlined,
                        size: 64,
                        color: Color(0xFF20B2AA),
                      ),
                    ),
                    SizedBox(height: 24),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8BA9A5),
                        ),
                        children: [
                          TextSpan(text: 'Enter your SpO'),
                          TextSpan(
                            text: '₂',
                            style: TextStyle(
                              fontSize: 12,
                              fontFeatures: [FontFeature.subscripts()],
                            ),
                          ),
                          TextSpan(text: ' reading'),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                          children: const [
                            TextSpan(text: 'SpO'),
                            TextSpan(
                              text: '₂',
                              style: TextStyle(
                                fontSize: 12,
                                fontFeatures: [FontFeature.subscripts()],
                              ),
                            ),
                            TextSpan(text: ' (%)'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _spo2Controller,
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
                        onPressed: _checkSpO2,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF20B2AA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            children: const [
                              TextSpan(text: 'Check SpO'),
                              TextSpan(
                                text: '₂',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFeatures: [FontFeature.subscripts()],
                                ),
                              ),
                            ],
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
                                  : _result.contains('Low Oxygen')
                                      ? Color(0xFFFFAA00)
                                      : _result.contains('Very Low')
                                          ? Color(0xFFFF8800)
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
                                      : _result.contains('Low Oxygen')
                                          ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                          : _result.contains('Very Low')
                                              ? Color(0xFFFF8800)
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
                                        : _result.contains('Low Oxygen')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : _result.contains('Very Low')
                                                ? Color(0xFFAA4400)
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
                                    : _result.contains('Low Oxygen')
                                        ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                        : _result.contains('Very Low')
                                            ? Color(0xFFAA4400)
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
                                        : _result.contains('Low Oxygen')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : _result.contains('Very Low')
                                                ? Color(0xFFFF8800)
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
                                            : _result.contains('Low Oxygen')
                                                ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                                : _result.contains('Very Low')
                                                    ? Color(0xFFAA4400)
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
                                        : _result.contains('Low Oxygen')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : _result.contains('Very Low')
                                                ? Color(0xFFFF8800)
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
    _spo2Controller.dispose();
    super.dispose();
  }
}
