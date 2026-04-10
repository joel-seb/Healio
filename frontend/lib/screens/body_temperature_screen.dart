import 'package:flutter/material.dart';
import '../services/vitals_service.dart';
import '../widgets/page_header.dart';

class BodyTemperatureScreen extends StatefulWidget {
  const BodyTemperatureScreen({super.key});

  @override
  State<BodyTemperatureScreen> createState() => _BodyTemperatureScreenState();
}

class _BodyTemperatureScreenState extends State<BodyTemperatureScreen> {
  final TextEditingController _temperatureController = TextEditingController();
  bool _isFahrenheit = true; // Default to Fahrenheit
  String _result = '';
  String _resultDescription = '';
  String _recommendation = '';
  Color _resultColor = Colors.transparent;
  Color _darkResultColor = Colors.transparent;
  bool _showResult = false;

  void _checkTemperature() {
    if (_temperatureController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter temperature value')),
      );
      return;
    }

    double temperature = double.tryParse(_temperatureController.text) ?? 0;
    
    // Convert to Fahrenheit if needed for comparison
    double tempInF = _isFahrenheit ? temperature : (temperature * 9 / 5) + 32;

    setState(() {
      _showResult = true;

      if (tempInF < 95) {
        _result = 'Hypothermia';
        _resultDescription = 'Your temperature is dangerously low.';
        _recommendation = 'Seek immediate medical attention!';
        _resultColor = Color(0xFFD1ECF1);
        _darkResultColor = const Color(0xFF0C1A2D);
      } else if (tempInF < 97.5) {
        _result = 'Below Normal';
        _resultDescription = 'Your temperature is slightly low.';
        _recommendation = 'Monitor and warm up. See a doctor if it persists.';
        _resultColor = Color(0xFFD1ECF1);
        _darkResultColor = const Color(0xFF0C1A2D);
      } else if (tempInF <= 99.5) {
        _result = 'Normal';
        _resultDescription = 'Your temperature is in the healthy range.';
        _recommendation = 'No concerns. Your temperature is normal.';
        _resultColor = Color(0xFFD4EDDA);
        _darkResultColor = const Color(0xFF0C2010);
      } else if (tempInF <= 100.4) {
        _result = 'Mild Fever';
        _resultDescription = 'You have a mild fever.';
        _recommendation = 'Rest and stay hydrated. Monitor your temperature.';
        _resultColor = Color(0xFFFFF3CD);
        _darkResultColor = const Color(0xFF2D2010);
      } else if (tempInF <= 103) {
        _result = 'Fever';
        _resultDescription = 'You have a moderate fever.';
        _recommendation = 'Take fever-reducing medication and rest. See a doctor if it persists.';
        _resultColor = Color(0xFFFFF3CD);
        _darkResultColor = const Color(0xFF2D2010);
      } else {
        _result = 'High Fever';
        _resultDescription = 'Your temperature is very high.';
        _recommendation = 'Seek medical attention immediately!';
        _resultColor = Color(0xFFF8D7DA);
        _darkResultColor = const Color(0xFF200C0C);
      }
    });
    // Store in °C always
    final tempC = _isFahrenheit
        ? ((double.tryParse(_temperatureController.text) ?? 0) - 32) * 5 / 9
        : double.tryParse(_temperatureController.text);
    saveVitalsToBackend(bodyTemp: tempC);
    showVitalsSaved(context);
  }

  void _checkAnother() {
    setState(() {
      _showResult = false;
      _temperatureController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const PageHeader(
            title: 'Body Temperature',
            subtitle: 'Record your temperature',
            icon: Icons.thermostat_outlined,
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
                        Icons.thermostat,
                        size: 60,
                        color: Color(0xFF20B2AA),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Enter your body temperature',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8BA9A5),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Temperature unit toggle
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color(0xFF20B2AA),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFahrenheit = false;
                                  _showResult = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isFahrenheit
                                      ? Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF2D3748)
                                          : Colors.white
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(23),
                                    bottomLeft: Radius.circular(23),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: !_isFahrenheit
                                        ? const Color(0xFF20B2AA)
                                        : const Color(0xFF8BA9A5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFahrenheit = true;
                                  _showResult = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isFahrenheit
                                      ? Color(0xFF20B2AA)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(23),
                                    bottomRight: Radius.circular(23),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '°F',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _isFahrenheit
                                        ? Colors.white
                                        : Color(0xFF8BA9A5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Temperature (${_isFahrenheit ? '°F' : '°C'})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _temperatureController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        onPressed: _checkTemperature,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF20B2AA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Check Temperature',
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
                                  : _result.contains('Mild') || _result.contains('Fever')
                                      ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                      : _result.contains('High') || _result.contains('Hypothermia')
                                          ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                          : Color(0xFF17A2B8),
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
                                      : _result.contains('Mild') || _result.contains('Fever')
                                          ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                          : _result.contains('High') || _result.contains('Hypothermia')
                                              ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                              : Color(0xFF17A2B8),
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
                                        : _result.contains('Mild') || _result.contains('Fever')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : _result.contains('High') || _result.contains('Hypothermia')
                                                ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                                : Theme.of(context).brightness == Brightness.dark ? Color(0xFF64B5F6) : Color(0xFF0C5460),
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
                                    : _result.contains('Mild') || _result.contains('Fever')
                                        ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                        : _result.contains('High') || _result.contains('Hypothermia')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                            : Theme.of(context).brightness == Brightness.dark ? Color(0xFF64B5F6) : Color(0xFF0C5460),
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
                                        : _result.contains('Mild') || _result.contains('Fever')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : _result.contains('High') || _result.contains('Hypothermia')
                                                ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                                : Color(0xFF17A2B8),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _recommendation,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _result.contains('Normal')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFF81C784) : Color(0xFF155724)
                                            : _result.contains('Mild') || _result.contains('Fever')
                                                ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                                : _result.contains('High') || _result.contains('Hypothermia')
                                                    ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                                    : Theme.of(context).brightness == Brightness.dark ? Color(0xFF64B5F6) : Color(0xFF0C5460),
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
                                        : _result.contains('Mild') || _result.contains('Fever')
                                            ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFCC80) : Color(0xFFAA6F00)
                                            : _result.contains('High') || _result.contains('Hypothermia')
                                                ? Theme.of(context).brightness == Brightness.dark ? Color(0xFFEF9A9A) : Color(0xFFD32F2F)
                                                : Color(0xFF17A2B8),
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
    _temperatureController.dispose();
    super.dispose();
  }
}
