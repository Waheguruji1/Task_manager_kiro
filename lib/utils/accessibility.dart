import 'package:flutter/material.dart';

/// Accessibility Utilities
/// 
/// Helper methods and widgets to improve app accessibility
/// and prevent Firebase Test Lab accessibility crashes
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Wrap widget with proper semantics for accessibility
  static Widget wrapWithSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool? isButton,
    bool? isHeader,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton ?? false,
      header: isHeader ?? false,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible button wrapper
  static Widget accessibleButton({
    required Widget child,
    required String label,
    required VoidCallback onPressed,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint ?? 'Double tap to activate',
      button: true,
      onTap: onPressed,
      child: child,
    );
  }

  /// Create accessible text wrapper
  static Widget accessibleText({
    required String text,
    required TextStyle style,
    String? semanticLabel,
    bool isHeader = false,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeader,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  /// Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// Exclude widget from accessibility tree
  static Widget excludeFromSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }

  /// Merge semantics for complex widgets
  static Widget mergeSemantics({
    required Widget child,
    String? label,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        child: child,
      ),
    );
  }
}