import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/page_header.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen>
    with TickerProviderStateMixin {
  // Weight values
  double _weight = 70.0;
  double _weightDecimal = 0.0;
  bool _isWeightInDecimalMode = false;

  // Height values
  double _height = 175.0;
  double _heightDecimal = 0.0;
  bool _isHeightInDecimalMode = false;

  double? _bmiResult;
  String _bmiCategory = '';
  String _bmiDescription = '';
  String _bmiAdvice = '';
  Color _resultColor = Color(0xFF9CA8B4);
  IconData _resultIcon = Icons.info_outline;
  bool _showResult = false;
  String _highlightCategory = ''; // Track which category to highlight

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late AnimationController _resultCircleController;
  late AnimationController _weightSliderTransformController;
  late AnimationController _heightSliderTransformController;
  late AnimationController _categoryHighlightController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _circleAnimation;
  late Animation<double> _weightTransformAnimation;
  late Animation<double> _heightTransformAnimation;
  late Animation<double> _categoryHighlightAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Result circle animation
    _resultCircleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _circleAnimation = CurvedAnimation(
      parent: _resultCircleController,
      curve: Curves.elasticOut,
    );

    // Weight slider transform animation
    _weightSliderTransformController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _weightTransformAnimation = CurvedAnimation(
      parent: _weightSliderTransformController,
      curve: Curves.easeInOut,
    );

    // Height slider transform animation
    _heightSliderTransformController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heightTransformAnimation = CurvedAnimation(
      parent: _heightSliderTransformController,
      curve: Curves.easeInOut,
    );

    // Category highlight animation
    _categoryHighlightController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _categoryHighlightAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _categoryHighlightController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    _resultCircleController.dispose();
    _weightSliderTransformController.dispose();
    _heightSliderTransformController.dispose();
    _categoryHighlightController.dispose();
    super.dispose();
  }

  double get totalWeight => _weight + _weightDecimal;
  double get totalHeight => _height + _heightDecimal;

  double _calculateCurrentBMI() {
    if (totalWeight <= 0 || totalHeight <= 0) return 0;
    final heightInMeters = totalHeight / 100;
    return totalWeight / (heightInMeters * heightInMeters);
  }

  void _categorizeBMI(double bmi) {
    if (bmi < 16) {
      _bmiCategory = 'Severely Underweight';
      _bmiDescription = 'Your BMI indicates severe underweight, which may signal nutritional deficiency.';
      _bmiAdvice = 'Seek medical help for a nutrition plan.';
      _resultColor = Color(0xFFFFCDD2);
      _resultIcon = Icons.error_outline;
    } else if (bmi < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiDescription = 'Your BMI is below the healthy range. Consider consulting a nutritionist.';
      _bmiAdvice = 'Increase calorie intake with nutrient-rich foods.';
      _resultColor = Color(0xFFFFF9C4);
      _resultIcon = Icons.warning_outlined;
    } else if (bmi < 25) {
      _bmiCategory = 'Normal';
      _bmiDescription = 'Your BMI is within the healthy range.';
      _bmiAdvice = 'Maintain your current healthy lifestyle.';
      _resultColor = Color(0xFFC8E6C9);
      _resultIcon = Icons.check_circle_outline;
    } else if (bmi < 30) {
      _bmiCategory = 'Overweight';
      _bmiDescription = 'Your BMI is above the healthy range.';
      _bmiAdvice = 'Monitor your diet and increase physical activity.';
      _resultColor = Color(0xFFFFE0B2);
      _resultIcon = Icons.info_outline;
    } else {
      _bmiCategory = 'Obese';
      _bmiDescription = 'Your BMI indicates obesity, increasing risk for chronic conditions.';
      _bmiAdvice = 'Consult a healthcare provider for a weight management plan.';
      _resultColor = Color(0xFFFFCDD2);
      _resultIcon = Icons.error_outline;
    }
  }

  void _calculateBMI() async {
    _buttonController.forward().then((_) => _buttonController.reverse());

    final bmi = _calculateCurrentBMI();
    
    setState(() {
      _bmiResult = bmi;
      _categorizeBMI(bmi);
      _highlightCategory = _bmiCategory;
    });

    // Highlight the matching category
    _categoryHighlightController.forward();
    
    // Wait for highlight, then show result
    await Future.delayed(const Duration(milliseconds: 600));
    
    setState(() {
      _showResult = true;
    });

    _categoryHighlightController.reverse();
  }

  void _resetCalculator() {
    setState(() {
      _weight = 70.0;
      _weightDecimal = 0.0;
      _height = 175.0;
      _heightDecimal = 0.0;
      _isWeightInDecimalMode = false;
      _isHeightInDecimalMode = false;
      _bmiResult = null;
      _showResult = false;
      _highlightCategory = '';
    });
    _weightSliderTransformController.reverse();
    _heightSliderTransformController.reverse();
    _categoryHighlightController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const PageHeader(
            title: 'BMI Calculator',
            subtitle: 'Calculate your body mass index',
            icon: Icons.calculate_outlined,
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                // Weight Slider Section
                _buildSliderSection(
                  title: 'Weight',
                  unit: 'kg',
                  wholeValue: _weight,
                  decimalValue: _weightDecimal,
                  isInDecimalMode: _isWeightInDecimalMode,
                  minWhole: 30.0,
                  maxWhole: 200.0,
                  onWholeChanged: (value) {
                    setState(() => _weight = value);
                  },
                  onDecimalChanged: (value) {
                    setState(() => _weightDecimal = value);
                  },
                  onSwitchToDecimalMode: () {
                    setState(() => _isWeightInDecimalMode = true);
                    _weightSliderTransformController.forward();
                  },
                  transformAnimation: _weightTransformAnimation,
                  icon: Icons.monitor_weight_outlined,
                ),
                SizedBox(height: 16),

                // Height Slider Section
                _buildSliderSection(
                  title: 'Height',
                  unit: 'cm',
                  wholeValue: _height,
                  decimalValue: _heightDecimal,
                  isInDecimalMode: _isHeightInDecimalMode,
                  minWhole: 100.0,
                  maxWhole: 250.0,
                  onWholeChanged: (value) {
                    setState(() => _height = value);
                  },
                  onDecimalChanged: (value) {
                    setState(() => _heightDecimal = value);
                  },
                  onSwitchToDecimalMode: () {
                    setState(() => _isHeightInDecimalMode = true);
                    _heightSliderTransformController.forward();
                  },
                  transformAnimation: _heightTransformAnimation,
                  icon: Icons.height,
                ),
                SizedBox(height: 20),

                // Calculate Button with Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF20B2AA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF20B2AA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _calculateBMI,
                      child: Text(
                        'Calculate BMI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // BMI Reference Chart or Result (sophisticated transition)
                SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    // Determine which way the transition is going
                    final isResult = child.key == const ValueKey('result_display');
                    
                    if (isResult) {
                      // Result coming in: zoom + fade from matching category
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, -0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: child,
                          ),
                        ),
                      );
                    } else {
                      // Reference chart: just fade in/out
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    }
                  },
                  child: _showResult && _bmiResult != null
                      ? _buildAnimatedResult()
                      : _buildBMIReferenceChart(),
                ),
                SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIReferenceChart() {
    return Container(
      key: const ValueKey('reference_chart'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF20B2AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Color(0xFF20B2AA),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'BMI Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // BMI Range Cards
          _buildBMIRangeCard(
            'Underweight',
            '< 18.5',
            Color(0xFFFFF9C4),
            Color(0xFFF57F17),
            Icons.arrow_downward,
            isHighlighted: _highlightCategory == 'Underweight',
          ),
          SizedBox(height: 8),
          _buildBMIRangeCard(
            'Normal',
            '18.5 - 24.9',
            Color(0xFFC8E6C9),
            Color(0xFF2E7D32),
            Icons.check_circle_outline,
            isHighlighted: _highlightCategory == 'Normal',
          ),
          SizedBox(height: 8),
          _buildBMIRangeCard(
            'Overweight',
            '25.0 - 29.9',
            Color(0xFFFFE0B2),
            Color(0xFFE65100),
            Icons.trending_up,
            isHighlighted: _highlightCategory == 'Overweight',
          ),
          SizedBox(height: 8),
          _buildBMIRangeCard(
            'Obese',
            '≥ 30.0',
            Color(0xFFFFCDD2),
            Color(0xFFC62828),
            Icons.warning_outlined,
            isHighlighted: _highlightCategory == 'Obese',
          ),
          SizedBox(height: 4), // Extra padding to match result height
        ],
      ),
    );
  }

  Widget _buildBMIRangeCard(
    String category,
    String range,
    Color bgColor,
    Color textColor,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return AnimatedBuilder(
      animation: _categoryHighlightAnimation,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scale = isHighlighted ? _categoryHighlightAnimation.value : 1.0;
        final opacity = isHighlighted ? (isDark ? 0.25 : 1.0) : (isDark ? 0.1 : 0.3);
        final borderColor = isDark ? textColor.withOpacity(isHighlighted ? 0.8 : 0.4) : bgColor;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isHighlighted ? 2 : 1,
              ),
              boxShadow: isHighlighted ? [
                BoxShadow(
                  color: textColor.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  range,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderSection({
    required String title,
    required String unit,
    required double wholeValue,
    required double decimalValue,
    required bool isInDecimalMode,
    required double minWhole,
    required double maxWhole,
    required Function(double) onWholeChanged,
    required Function(double) onDecimalChanged,
    required VoidCallback onSwitchToDecimalMode,
    required Animation<double> transformAnimation,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF20B2AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF20B2AA),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Value Display
          Center(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  height: 1,
                ),
                children: [
                  TextSpan(text: wholeValue.toInt().toString()),
                  TextSpan(
                    text: '.${(decimalValue * 10).round()}',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF20B2AA),
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Single Transforming Slider
          AnimatedBuilder(
            animation: transformAnimation,
            builder: (context, child) {
              // Interpolate colors based on mode
              final activeColor = Color.lerp(
                Color(0xFF20B2AA),
                Color(0xFF20B2AA).withOpacity(0.8),
                transformAnimation.value,
              )!;
              
              final inactiveColor = Color.lerp(
                Color(0xFF20B2AA).withOpacity(0.2),
                Color(0xFF20B2AA).withOpacity(0.15),
                transformAnimation.value,
              )!;
              
              // Interpolate thumb size
              final thumbRadius = 14.0 - (5.0 * transformAnimation.value);
              final trackHeight = 6.0 - (3.0 * transformAnimation.value);
              
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * transformAnimation.value,
                  vertical: 8 * transformAnimation.value,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.transparent,
                    Color(0xFF20B2AA).withOpacity(0.08),
                    transformAnimation.value,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: trackHeight,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: thumbRadius,
                      elevation: 3 - (1.5 * transformAnimation.value),
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 24 - (6 * transformAnimation.value),
                    ),
                    activeTrackColor: activeColor,
                    inactiveTrackColor: inactiveColor,
                    thumbColor: isInDecimalMode 
                      ? Color(0xFF20B2AA)
                      : Colors.white,
                    overlayColor: Color(0xFF20B2AA).withOpacity(0.2),
                    trackShape: const RoundedRectSliderTrackShape(),
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Slider(
                    value: isInDecimalMode ? decimalValue * 10 : wholeValue,
                    min: isInDecimalMode ? 0.0 : minWhole,
                    max: isInDecimalMode ? 9.0 : maxWhole,
                    divisions: isInDecimalMode ? 9 : null,
                    label: isInDecimalMode ? '${(decimalValue * 10).round()}' : null,
                    onChanged: (value) {
                      if (isInDecimalMode) {
                        onDecimalChanged(value / 10);
                      } else {
                        onWholeChanged(value);
                      }
                    },
                    onChangeEnd: (value) {
                      if (!isInDecimalMode) {
                        onSwitchToDecimalMode();
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedResult() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getAccentColor(_resultColor);
    // In dark mode, use a deep tinted background based on accent color instead of pastel
    final gradientStart = isDark
        ? accentColor.withOpacity(0.25)
        : _resultColor.withOpacity(0.8);
    final gradientEnd = isDark
        ? accentColor.withOpacity(0.15)
        : _resultColor;
    final circleColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white.withOpacity(0.9);
    final adviceBoxColor = isDark
        ? const Color(0xFF1E293B)
        : (Theme.of(context).cardTheme.color ?? Colors.white);
    
    return Container(
      key: const ValueKey('result_display'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: accentColor.withOpacity(0.4), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.2 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
          children: [
            // Compact BMI Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _bmiResult!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Icon(_resultIcon, color: accentColor, size: 18),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bmiCategory,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bmiDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withOpacity(0.75)
                              : accentColor.withOpacity(0.85),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Advice Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: adviceBoxColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: accentColor,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _bmiAdvice,
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Reset Button
            TextButton(
              onPressed: _resetCalculator,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                backgroundColor: Colors.white.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Calculate Again',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
  }

  Color _getAccentColor(Color backgroundColor) {
    if (backgroundColor == Color(0xFFC8E6C9)) {
      return Color(0xFF2E7D32); // Green for normal
    } else if (backgroundColor == Color(0xFFFFE0B2)) {
      return Color(0xFFE65100); // Orange for overweight
    } else if (backgroundColor == Color(0xFFFFF9C4)) {
      return Color(0xFFF57F17); // Yellow for underweight
    } else {
      return Color(0xFFC62828); // Red for obese/severely underweight
    }
  }
}
