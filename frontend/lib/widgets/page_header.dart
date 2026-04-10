import 'package:flutter/material.dart';

/// Standardized page header component for consistent design across the app
/// 
/// Features:
/// - White background with dark text (Healio style)
/// - Optional icon badge on the left
/// - Screen title and subtitle
/// - Back button
/// - Consistent spacing and typography
class PageHeader extends StatelessWidget {
  /// The main title displayed prominently
  final String title;
  
  /// Optional subtitle displayed below the title
  final String? subtitle;
  
  /// Optional icon to display in a circle badge
  final IconData? icon;
  
  /// Custom callback for back button (defaults to Navigator.pop)
  final VoidCallback? onBack;
  
  /// Height of the header (defaults to auto-calculated based on content)
  final double? height;
  
  /// Optional list of action widgets to display on the right side
  final List<Widget>? actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onBack,
    this.height,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title row
              Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color, size: 24),
                    onPressed: onBack ?? () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Icon badge (if provided)
                  if (icon != null) ...[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF20B2AA).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF20B2AA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.displaySmall?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Actions (if provided)
                  if (actions != null) ...actions!,
                ],
              ),
              
              // Subtitle (if provided)
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: icon != null ? 80 : 40),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Standardized card widget for list items
/// 
/// Features:
/// - White background with subtle shadow
/// - Rounded corners (16px)
/// - Icon circle on the left
/// - Title and subtitle text
/// - Arrow icon on the right
/// - Material ripple effect on tap
class StandardCard extends StatelessWidget {
  /// Icon to display in the circle
  final IconData icon;
  
  /// Main title text
  final String title;
  
  /// Optional subtitle text
  final String? subtitle;
  
  /// Callback when card is tapped
  final VoidCallback onTap;
  
  /// Optional custom icon color (defaults to teal)
  final Color? iconColor;
  
  /// Optional custom background color for icon circle
  final Color? iconBackgroundColor;

  const StandardCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFF20B2AA);
    final effectiveIconBgColor = iconBackgroundColor ?? effectiveIconColor;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor.withOpacity(
                      iconBackgroundColor != null ? 1.0 : 0.1
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconBackgroundColor != null 
                      ? Colors.white 
                      : effectiveIconColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
