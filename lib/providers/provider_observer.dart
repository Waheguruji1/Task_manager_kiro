import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/error_handler.dart';

/// Enhanced App Provider Observer
/// 
/// Observes provider state changes for debugging, logging, and performance monitoring
/// Enhanced with detailed tracking and memory management insights
class AppProviderObserver extends ProviderObserver {
  // Tracking for debugging and performance analysis
  final Map<String, DateTime> _providerCreationTimes = {};
  final Map<String, int> _providerUpdateCounts = {};
  final Map<String, DateTime> _lastUpdateTimes = {};
  final Set<String> _activeProviders = {};
  
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    super.didAddProvider(provider, value, container);
    
    final providerName = provider.name ?? provider.runtimeType.toString();
    _providerCreationTimes[providerName] = DateTime.now();
    _activeProviders.add(providerName);
    
    // Enhanced logging in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _logProviderActivity('ADDED', providerName, {
        'value_type': value?.runtimeType.toString() ?? 'null',
        'is_auto_dispose': provider.toString().contains('autoDispose'),
        'active_providers_count': _activeProviders.length,
      });
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    super.didDisposeProvider(provider, container);
    
    final providerName = provider.name ?? provider.runtimeType.toString();
    final creationTime = _providerCreationTimes[providerName];
    final updateCount = _providerUpdateCounts[providerName] ?? 0;
    
    _activeProviders.remove(providerName);
    
    // Enhanced logging in debug mode with lifecycle information
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      final lifespan = creationTime != null 
          ? DateTime.now().difference(creationTime).inMilliseconds 
          : null;
      
      _logProviderActivity('DISPOSED', providerName, {
        'lifespan_ms': lifespan,
        'update_count': updateCount,
        'active_providers_count': _activeProviders.length,
      });
    }
    
    // Clean up tracking data
    _providerCreationTimes.remove(providerName);
    _providerUpdateCounts.remove(providerName);
    _lastUpdateTimes.remove(providerName);
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    super.didUpdateProvider(provider, previousValue, newValue, container);
    
    final providerName = provider.name ?? provider.runtimeType.toString();
    _providerUpdateCounts[providerName] = (_providerUpdateCounts[providerName] ?? 0) + 1;
    _lastUpdateTimes[providerName] = DateTime.now();
    
    // Enhanced logging in debug mode with change details
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _logProviderActivity('UPDATED', providerName, {
        'previous_type': previousValue?.runtimeType.toString() ?? 'null',
        'new_type': newValue?.runtimeType.toString() ?? 'null',
        'update_count': _providerUpdateCounts[providerName],
        'values_equal': _valuesEqual(previousValue, newValue),
      });
      
      // Log detailed value changes for specific provider types
      if (_shouldLogDetailedValues(providerName)) {
        _logDetailedValueChange(providerName, previousValue, newValue);
      }
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
    
    final providerName = provider.name ?? provider.runtimeType.toString();
    
    // Enhanced error logging with provider context
    ErrorHandler.logError(
      error,
      stackTrace: stackTrace,
      context: 'Provider failed: $providerName',
      type: ErrorType.unknown,
    );
    
    // Additional debug logging
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _logProviderActivity('FAILED', providerName, {
        'error_type': error.runtimeType.toString(),
        'error_message': error.toString(),
        'update_count': _providerUpdateCounts[providerName] ?? 0,
      });
    }
  }
  
  /// Get provider performance statistics for debugging
  Map<String, dynamic> getProviderStats() {
    final now = DateTime.now();
    
    return {
      'active_providers': _activeProviders.toList(),
      'active_count': _activeProviders.length,
      'total_updates': _providerUpdateCounts.values.fold(0, (a, b) => a + b),
      'provider_update_counts': Map<String, int>.from(_providerUpdateCounts),
      'provider_lifespans': Map<String, int>.fromEntries(
        _providerCreationTimes.entries
            .where((e) => _activeProviders.contains(e.key))
            .map((e) => MapEntry(e.key, now.difference(e.value).inMilliseconds)),
      ),
      'last_update_times': Map<String, String>.fromEntries(
        _lastUpdateTimes.entries.map(
          (e) => MapEntry(e.key, e.value.toIso8601String()),
        ),
      ),
    };
  }
  
  /// Reset provider statistics (useful for debugging)
  void resetStats() {
    _providerUpdateCounts.clear();
    _lastUpdateTimes.clear();
    // Keep creation times and active providers for ongoing tracking
  }
  
  /// Check if values are equal for change detection
  bool _valuesEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    
    // For lists, check length equality as a quick comparison
    if (a is List && b is List) {
      return a.length == b.length;
    }
    
    // For maps, check key count equality
    if (a is Map && b is Map) {
      return a.length == b.length;
    }
    
    return a == b;
  }
  
  /// Determine if detailed value logging should be enabled for a provider
  bool _shouldLogDetailedValues(String providerName) {
    // Enable detailed logging for key providers
    return providerName.contains('task') || 
           providerName.contains('achievement') || 
           providerName.contains('stats') ||
           providerName.contains('navigation');
  }
  
  /// Log detailed value changes for debugging
  void _logDetailedValueChange(String providerName, Object? previousValue, Object? newValue) {
    final details = <String, dynamic>{};
    
    if (previousValue is List && newValue is List) {
      details['previous_length'] = previousValue.length;
      details['new_length'] = newValue.length;
      details['length_changed'] = previousValue.length != newValue.length;
    }
    
    if (previousValue is Map && newValue is Map) {
      details['previous_keys'] = previousValue.keys.length;
      details['new_keys'] = newValue.keys.length;
      details['keys_changed'] = previousValue.keys.length != newValue.keys.length;
    }
    
    if (details.isNotEmpty) {
      _logProviderActivity('VALUE_DETAIL', providerName, details);
    }
  }
  
  /// Enhanced logging with structured information
  void _logProviderActivity(String action, String providerName, Map<String, dynamic> details) {
    final detailsStr = details.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
    
    // Use ErrorHandler for consistent logging instead of print
    ErrorHandler.logInfo(
      '[$action] $providerName ($detailsStr) at ${DateTime.now().toIso8601String()}',
      context: 'Provider Observer',
    );
  }
}