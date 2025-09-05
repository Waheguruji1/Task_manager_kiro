import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Shimmer Loading Widget
/// 
/// Provides a shimmer effect for loading states to improve user experience
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });
  
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    if (widget.isLoading) {
      _animationController.repeat();
    }
  }
  
  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    
    final baseColor = widget.baseColor ?? AppTheme.surfaceGrey;
    final highlightColor = widget.highlightColor ?? AppTheme.greyLight.withValues(alpha: 0.3);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer Task Item
/// 
/// A shimmer placeholder for task items during loading
class ShimmerTaskItem extends StatelessWidget {
  const ShimmerTaskItem({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          // Checkbox placeholder
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingM),
          
          // Task content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingXS),
                
                // Description placeholder
                Container(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingM),
          
          // Action buttons placeholder
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                ),
              ),
              
              const SizedBox(width: AppTheme.spacingS),
              
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer Task Container
/// 
/// A shimmer placeholder for task containers during loading
class ShimmerTaskContainer extends StatelessWidget {
  const ShimmerTaskContainer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppTheme.spacingS,
        right: AppTheme.spacingS,
        bottom: AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header placeholder
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.containerBorderRadius),
                topRight: Radius.circular(AppTheme.containerBorderRadius),
              ),
            ),
          ),
          
          // Task items placeholder
          ...List.generate(3, (index) => const ShimmerTaskItem()),
        ],
      ),
    );
  }
}