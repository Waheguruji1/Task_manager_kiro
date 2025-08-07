import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A widget that displays text with truncation and tap-to-expand functionality
/// 
/// This widget automatically truncates text that exceeds the specified maximum
/// length and provides a tap gesture to expand/collapse the full text.
class TruncatedText extends StatefulWidget {
  /// The text to display
  final String text;
  
  /// Maximum number of characters to show when truncated
  final int maxLength;
  
  /// Text style to apply
  final TextStyle? style;
  
  /// Maximum number of lines to show when truncated
  final int maxLines;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Whether to show expand/collapse indicators
  final bool showIndicators;
  
  /// Color for expand/collapse indicators
  final Color? indicatorColor;

  const TruncatedText({
    super.key,
    required this.text,
    this.maxLength = 100,
    this.style,
    this.maxLines = 2,
    this.textAlign = TextAlign.start,
    this.showIndicators = true,
    this.indicatorColor,
  });

  @override
  State<TruncatedText> createState() => _TruncatedTextState();
}

class _TruncatedTextState extends State<TruncatedText>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Check if the text needs truncation
  bool get _needsTruncation {
    return widget.text.length > widget.maxLength;
  }

  /// Get the display text based on expansion state
  String get _displayText {
    if (!_needsTruncation || _isExpanded) {
      return widget.text;
    }
    return '${widget.text.substring(0, widget.maxLength)}...';
  }

  /// Toggle the expansion state
  void _toggleExpansion() {
    if (!_needsTruncation) return;
    
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Build the expand/collapse indicator
  Widget? _buildIndicator() {
    if (!widget.showIndicators || !_needsTruncation) return null;
    
    final indicatorColor = widget.indicatorColor ?? 
        widget.style?.color?.withValues(alpha: 0.7) ?? 
        AppTheme.secondaryText;
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: indicatorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: indicatorColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: (widget.style ?? AppTheme.bodyMedium).copyWith(
                    color: indicatorColor,
                    fontSize: (widget.style?.fontSize ?? 14) - 2,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: indicatorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsTruncation) {
      // If no truncation is needed, just show the text normally
      return Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }

    return GestureDetector(
      onTap: _toggleExpansion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Text(
              _displayText,
              style: widget.style,
              textAlign: widget.textAlign,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
          if (_buildIndicator() != null) ...[
            const SizedBox(height: 4),
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}

/// A simpler version of TruncatedText for single-line text with character-based truncation
class SimpleTruncatedText extends StatelessWidget {
  /// The text to display
  final String text;
  
  /// Maximum number of characters to show
  final int maxLength;
  
  /// Text style to apply
  final TextStyle? style;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Whether the text can be tapped to show full text in a tooltip
  final bool showTooltipOnTap;

  const SimpleTruncatedText({
    super.key,
    required this.text,
    this.maxLength = 50,
    this.style,
    this.textAlign = TextAlign.start,
    this.showTooltipOnTap = true,
  });

  /// Get the display text
  String get _displayText {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Check if truncation is needed
  bool get _isTruncated => text.length > maxLength;

  @override
  Widget build(BuildContext context) {
    final displayText = _displayText;
    
    if (!_isTruncated || !showTooltipOnTap) {
      return Text(
        displayText,
        style: style,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Tooltip(
      message: text,
      preferBelow: false,
      decoration: BoxDecoration(
        color: AppTheme.greyDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderWhite.withValues(alpha: 0.2)),
      ),
      textStyle: AppTheme.bodyMedium.copyWith(
        color: AppTheme.primaryText,
      ),
      child: Text(
        displayText,
        style: style,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}