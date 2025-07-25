import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_icon.dart';
import '../services/preferences_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/validation.dart';
import '../utils/responsive.dart';

/// Welcome Screen Widget
/// 
/// This screen handles user onboarding by collecting the user's name
/// and providing a personalized experience. It follows the theme specifications
/// with a logo container, custom text field, and navigation button.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late PreferencesService _preferencesService;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialize the preferences service
  Future<void> _initializeServices() async {
    try {
      _preferencesService = await PreferencesService.getInstance();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      ErrorHandler.logError(e, context: 'Welcome screen initialization', type: ErrorType.preferences);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          AppStrings.errorPreferences,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _initializeServices,
          ),
        );
      }
      // Allow them to continue even if preferences fail
      setState(() {
        _isInitialized = true;
      });
    }
  }

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

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final success = await _preferencesService.saveUserName(name);
      
      if (success) {
        // Mark first launch as complete
        await _preferencesService.setFirstLaunchComplete();
        
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, 'Welcome, $name!');
          _navigateToHome();
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, AppStrings.errorSavingUserName);
        }
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Navigate to home screen
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  /// Build the logo container with app name
  Widget _buildLogoContainer() {
    final responsiveSpacing = ResponsiveUtils.getSpacing(context, AppTheme.spacingL);
    final iconSize = ResponsiveUtils.isSmallScreen(context) ? 80.0 : 100.0;
    
    return Container(
      padding: EdgeInsets.all(responsiveSpacing),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: AppLogo(
        appName: AppConstants.appName,
        iconSize: iconSize,
        spacing: ResponsiveUtils.getSpacing(context, AppTheme.spacingM),
        textStyle: AppTheme.headingLarge.copyWith(
          fontSize: AppTheme.headingLarge.fontSize! * 
            ResponsiveUtils.getFontSizeMultiplier(context),
        ),
      ),
    );
  }

  /// Build the name input field
  Widget _buildNameInput() {
    return Form(
      key: _formKey,
      child: CustomTextField(
        controller: _nameController,
        hintText: AppStrings.nameInputHint,
        labelText: AppStrings.nameInputLabel,
        validator: _validateName,
        keyboardType: TextInputType.name,
        autofocus: true,
        enabled: !_isLoading,
        onChanged: (value) {
          // Clear validation errors as user types
          if (_formKey.currentState != null) {
            _formKey.currentState!.validate();
          }
        },
      ),
    );
  }

  /// Build the navigation button with forward arrow
  Widget _buildNavigationButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.recommendedTouchTargetSize,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveNameAndNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.purplePrimary,
          foregroundColor: AppTheme.primaryText,
          elevation: AppTheme.buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryText),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.getStartedButton,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing services
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purplePrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Spacer to push content towards center
              const Spacer(flex: 1),
              
              // Logo Container
              _buildLogoContainer(),
              
              const SizedBox(height: AppTheme.sectionSpacing),
              
              // Welcome Text
              Text(
                AppStrings.welcomeSubtitle,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Name Input Field
              _buildNameInput(),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Navigation Button
              _buildNavigationButton(),
              
              // Spacer to balance the layout
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}