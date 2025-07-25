import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// App Icon Widget
/// 
/// A reusable widget that displays the app icon with consistent styling.
/// Can be used in different sizes throughout the app.
class AppIcon extends StatelessWidget {
  /// The size of the icon
  final double size;
  
  /// Whether to show the background container
  final bool showBackground;
  
  /// Custom background color (optional)
  final Color? backgroundColor;
  
  /// Custom icon color (optional)
  final Color? iconColor;

  const AppIcon({
    super.key,
    this.size = 80,
    this.showBackground = true,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.purplePrimary;
    final foregroundColor = iconColor ?? AppTheme.primaryText;
    
    if (!showBackground) {
      return Icon(
        Icons.task_alt_rounded,
        size: size,
        color: foregroundColor,
      );
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.25), // 25% of size for rounded corners
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        Icons.task_alt_rounded,
        size: size * 0.5, // Icon is 50% of container size
        color: foregroundColor,
      ),
    );
  }
}

/// App Logo Widget
/// 
/// A complete app logo with icon and text, used in welcome screen and splash.
class AppLogo extends StatelessWidget {
  /// The size of the icon
  final double iconSize;
  
  /// The app name text
  final String appName;
  
  /// Text style for the app name
  final TextStyle? textStyle;
  
  /// Spacing between icon and text
  final double spacing;
  
  /// Layout direction (vertical or horizontal)
  final Axis direction;

  const AppLogo({
    super.key,
    this.iconSize = 80,
    required this.appName,
    this.textStyle,
    this.spacing = 16,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = AppTheme.headingLarge.copyWith(
      fontSize: iconSize * 0.3, // Text size relative to icon
      fontWeight: FontWeight.w600,
    );
    
    final children = [
      AppIcon(size: iconSize),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      Text(
        appName,
        style: textStyle ?? defaultTextStyle,
        textAlign: TextAlign.center,
      ),
    ];
    
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }
  }
}

/// Animated App Icon
/// 
/// An app icon with subtle animation effects for loading states.
class AnimatedAppIcon extends StatefulWidget {
  /// The size of the icon
  final double size;
  
  /// Whether the animation is active
  final bool isAnimating;
  
  /// Animation duration
  final Duration duration;

  const AnimatedAppIcon({
    super.key,
    this.size = 80,
    this.isAnimating = true,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedAppIcon> createState() => _AnimatedAppIconState();
}

class _AnimatedAppIconState extends State<AnimatedAppIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: AppIcon(size: widget.size),
          ),
        );
      },
    );
  }
}