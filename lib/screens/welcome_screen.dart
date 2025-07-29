import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_icon.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/validation.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';

/// Welcome Screen Widget
///
/// This screen handles user onboarding by collecting the user's name
/// and providing a personalized experience. It follows the theme specifications
/// with a logo container, custom text field, and navigation button.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Validate the entered name
  String? _validateName(String? value) {
    return ValidationUtils.validateUserName(value);
  }

  /// Save the username and navigate to home screen
  Future<void> _saveNameAndNavigate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final name = _nameController.text.trim();
      
      // Get the user state notifier from Riverpod
      final userStateNotifier = await ref.read(asyncUserStateNotifierProvider.future);
      final success = await userStateNotifier.saveUserName(name);

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Welcome, $name!');
        _navigateToMain();
      } else if (mounted) {
        ErrorHandler.showErrorSnackBar(context, AppStrings.errorSavingUserName);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = AppStrings.errorSavingUserName;
        if (e is AppException) {
          errorMessage = e.message;
        }
        ErrorHandler.showErrorSnackBar(
          context,
          errorMessage,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _saveNameAndNavigate,
          ),
        );
      }
    }
  }

  /// Navigate to main screen
  void _navigateToMain() {
    Navigator.of(context).pushReplacementNamed('/main');
  }

  /// Build the logo and title without container
  Widget _buildLogoAndTitle() {
    final iconSize = ResponsiveUtils.isSmallScreen(context) ? 100.0 : 120.0;
    final fontMultiplier = ResponsiveUtils.getFontSizeMultiplier(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Icon without container
        AppIcon(
          size: iconSize,
          showBackground: true,
        ),

        SizedBox(
            height: ResponsiveUtils.getSpacing(context, AppTheme.spacingL)),

        // App Title
        Text(
          AppConstants.appName,
          style: AppTheme.headingLarge.copyWith(
            fontSize: 32 * fontMultiplier,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build the name input field
  Widget _buildNameInput() {
    return Form(
      key: _formKey,
      child: CustomTextField(
        controller: _nameController,
        hintText: "your sweet name",
        validator: _validateName,
        keyboardType: TextInputType.name,
        autofocus: true,
        enabled: true,
        onChanged: (value) {
          // Clear validation errors as user types
          if (_formKey.currentState != null) {
            _formKey.currentState!.validate();
          }
        },
      ),
    );
  }

  /// Build the navigation button with white background and black text
  Widget _buildNavigationButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.recommendedTouchTargetSize,
      child: ElevatedButton(
        onPressed: _saveNameAndNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: AppTheme.buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.getStartedButton,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            const Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch user state async provider for initialization
    final userStateAsync = ref.watch(asyncUserStateNotifierProvider);
    
    return userStateAsync.when(
      data: (userStateNotifier) => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top spacing for elegant layout
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                  // Logo and Title (without container)
                  _buildLogoAndTitle(),

                  // Large spacing for elegant look
                  const SizedBox(height: AppTheme.sectionSpacing * 2),

                  // Name Input Field
                  _buildNameInput(),

                  // Large spacing before button
                  const SizedBox(height: AppTheme.sectionSpacing),

                  // Navigation Button
                  _buildNavigationButton(),

                  // Bottom spacing to ensure scrollability
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Failed to initialize services',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(asyncUserStateNotifierProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greyPrimary,
                  foregroundColor: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
