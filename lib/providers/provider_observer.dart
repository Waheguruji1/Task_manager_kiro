import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/error_handler.dart';

/// App Provider Observer
/// 
/// Observes provider state changes for debugging and logging purposes
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    super.didAddProvider(provider, value, container);
    
    // Log provider addition in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('Provider added: ${provider.name ?? provider.runtimeType}');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    super.didDisposeProvider(provider, container);
    
    // Log provider disposal in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('Provider disposed: ${provider.name ?? provider.runtimeType}');
    }
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    super.didUpdateProvider(provider, previousValue, newValue, container);
    
    // Log provider updates in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('Provider updated: ${provider.name ?? provider.runtimeType}');
      print('  Previous: $previousValue');
      print('  New: $newValue');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    super.providerDidFail(provider, error, stackTrace, container);
    
    // Log provider errors
    ErrorHandler.logError(
      error,
      stackTrace: stackTrace,
      context: 'Provider failed: ${provider.name ?? provider.runtimeType}',
      type: ErrorType.unknown,
    );
  }
}