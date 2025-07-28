import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Custom Text Field Widget
/// 
/// A themed text input field with boxy design, rounded corners, and white border.
/// Follows the app's theme specifications with consistent styling.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      autofocus: autofocus,
      focusNode: focusNode,
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surfaceGrey,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        
        // Boxy design with rounded corners and white border (2px width)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppTheme.borderWhite,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppTheme.disabledText,
            width: 2.0,
          ),
        ),
        
        // Text styling
        hintStyle: const TextStyle(
          color: AppTheme.disabledText,
          fontFamily: AppTheme.primaryFontFamily,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: AppTheme.secondaryText,
          fontFamily: AppTheme.primaryFontFamily,
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppTheme.primaryText,
          fontFamily: AppTheme.primaryFontFamily,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontFamily: AppTheme.primaryFontFamily,
          fontSize: 12,
        ),
      ),
    );
  }
}