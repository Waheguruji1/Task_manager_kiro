import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

/// Error Boundary Widget
/// 
/// A widget that catches and handles errors in its child widget tree.
/// Provides a fallback UI when errors occur and allows for error recovery.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.errorMessage,
    this.onRetry,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Reset error state when widget is recreated
    _hasError = false;
    _error = null;
  }

  /// Handle errors that occur in the child widget tree
  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _hasError = true;
      _error = error;
    });

    // Log the error
    ErrorHandler.logError(
      error,
      stackTrace: stackTrace,
      context: 'Error Boundary',
      type: ErrorType.unknown,
    );

    // Call custom error handler if provided
    widget.onError?.call(error, stackTrace);
  }

  /// Retry by resetting the error state
  void _retry() {
    setState(() {
      _hasError = false;
      _error = null;
    });
    
    widget.onRetry?.call();
  }

  /// Build the error fallback UI
  Widget _buildErrorFallback() {
    if (widget.fallback != null) {
      return widget.fallback!;
    }

    String errorMessage = widget.errorMessage ?? AppStrings.errorGeneral;
    
    // Try to extract a more specific error message
    if (_error is AppException) {
      errorMessage = (_error as AppException).message;
    } else if (_error is FlutterError) {
      errorMessage = 'A display error occurred. Please try again.';
    }

    return ErrorDisplayWidget(
      message: errorMessage,
      onRetry: widget.onRetry != null ? _retry : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorFallback();
    }

    // Use a custom error widget builder for this boundary
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stackTrace) {
          _handleError(error, stackTrace);
          return _buildErrorFallback();
        }
      },
    );
  }
}

/// A specialized error boundary for form validation errors
class FormErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(String error)? onValidationError;

  const FormErrorBoundary({
    super.key,
    required this.child,
    this.onValidationError,
  });

  @override
  State<FormErrorBoundary> createState() => _FormErrorBoundaryState();
}

class _FormErrorBoundaryState extends State<FormErrorBoundary> {
  String? _validationError;

  /// Handle validation errors
  void _handleValidationError(String error) {
    setState(() {
      _validationError = error;
    });
    
    widget.onValidationError?.call(error);
    
    // Clear error after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _validationError = null;
        });
      }
    });
  }

  /// Show validation error (can be called from parent widgets)
  void showValidationError(String error) {
    _handleValidationError(error);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.child,
        if (_validationError != null) ...[
          const SizedBox(height: AppTheme.spacingS),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A widget that provides safe async operation handling
class SafeAsyncBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final T? initialData;

  const SafeAsyncBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.initialData,
  });

  @override
  State<SafeAsyncBuilder<T>> createState() => _SafeAsyncBuilderState<T>();
}

class _SafeAsyncBuilderState<T> extends State<SafeAsyncBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }

  @override
  void didUpdateWidget(SafeAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.future != oldWidget.future) {
      _future = widget.future;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      initialData: widget.initialData,
      builder: (context, snapshot) {
        try {
          if (snapshot.hasError) {
            ErrorHandler.logError(
              snapshot.error!,
              stackTrace: snapshot.stackTrace,
              context: 'SafeAsyncBuilder',
              type: ErrorType.unknown,
            );

            if (widget.errorBuilder != null) {
              return widget.errorBuilder!(context, snapshot.error!);
            }

            String errorMessage = AppStrings.errorGeneral;
            if (snapshot.error is AppException) {
              errorMessage = (snapshot.error as AppException).message;
            }

            return ErrorDisplayWidget(
              message: errorMessage,
              onRetry: () {
                setState(() {
                  _future = widget.future;
                });
              },
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            if (widget.loadingBuilder != null) {
              return widget.loadingBuilder!(context);
            }
            return const LoadingWidget();
          }

          if (snapshot.hasData) {
            return widget.builder(context, snapshot.data as T);
          }

          return const LoadingWidget();
        } catch (e, stackTrace) {
          ErrorHandler.logError(
            e,
            stackTrace: stackTrace,
            context: 'SafeAsyncBuilder build',
            type: ErrorType.unknown,
          );

          return ErrorDisplayWidget(
            message: AppStrings.errorGeneral,
            onRetry: () {
              setState(() {
                _future = widget.future;
              });
            },
          );
        }
      },
    );
  }
}