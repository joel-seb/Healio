import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_controller.dart';

/// Animated theme toggle button with smooth icon morphing
/// Sun → Moon transition with rotation and scale effects
class AnimatedThemeToggle extends StatefulWidget {
  final ThemeController themeController;
  final Color? lightModeIconColor;
  final Color? darkModeIconColor;
  
  const AnimatedThemeToggle({
    super.key,
    required this.themeController,
    this.lightModeIconColor,
    this.darkModeIconColor,
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Scale animation: 1.0 → 0.8 → 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // Rotation animation: 0° → 180°
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 0.5 turns = 180 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleToggle() async {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate
    await _animationController.forward();
    
    // Toggle theme
    await widget.themeController.toggleTheme();
    
    // Reset animation
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeController,
      builder: (context, child) {
        final isDark = widget.themeController.isDark;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: const Color(0xFF20B2AA).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleToggle,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            key: ValueKey(isDark),
                            color: isDark
                                ? (widget.darkModeIconColor ?? const Color(0xFF90CAF9)) // Soft blue-grey
                                : (widget.lightModeIconColor ?? const Color(0xFF20B2AA)), // App teal color or custom
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simple theme toggle button for AppBar
class ThemeToggleButton extends StatelessWidget {
  final ThemeController themeController;
  final Color? lightModeIconColor;
  final Color? darkModeIconColor;
  
  const ThemeToggleButton({
    super.key,
    required this.themeController,
    this.lightModeIconColor,
    this.darkModeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedThemeToggle(
      themeController: themeController,
      lightModeIconColor: lightModeIconColor,
      darkModeIconColor: darkModeIconColor,
    );
  }
}
