import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../utils/error_handler.dart';

/// User State
/// 
/// Represents the current user authentication state
class UserState {
  final String? userName;
  final bool isAuthenticated;
  final bool isFirstLaunch;
  final bool isLoading;
  final String? error;

  const UserState({
    this.userName,
    this.isAuthenticated = false,
    this.isFirstLaunch = true,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    String? userName,
    bool? isAuthenticated,
    bool? isFirstLaunch,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// User State Notifier
/// 
/// Manages user authentication state and provides methods for user operations
class UserStateNotifier extends StateNotifier<UserState> {
  final PreferencesService _preferencesService;

  UserStateNotifier(this._preferencesService) : super(const UserState()) {
    loadUserData();
  }

  /// Load user data from preferences
  Future<void> loadUserData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final userName = await _preferencesService.getUserName();
      final isFirstLaunch = await _preferencesService.isFirstLaunch();
      final hasUserName = await _preferencesService.hasUserName();
      
      state = state.copyWith(
        userName: userName,
        isAuthenticated: hasUserName,
        isFirstLaunch: isFirstLaunch,
        isLoading: false,
      );
    } catch (e) {
      ErrorHandler.logError(e, context: 'Load user data', type: ErrorType.preferences);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user data: ${e.toString()}',
      );
    }
  }

  /// Save user name and complete onboarding
  Future<bool> saveUserName(String name) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _preferencesService.saveUserName(name);
      
      if (success) {
        await _preferencesService.setFirstLaunchComplete();
        
        state = state.copyWith(
          userName: name,
          isAuthenticated: true,
          isFirstLaunch: false,
          isLoading: false,
        );
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to save user name');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Save user name', type: ErrorType.preferences);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save user name: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear user data (logout)
  Future<bool> clearUserData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _preferencesService.clearUserData();
      
      if (success) {
        state = const UserState(
          userName: null,
          isAuthenticated: false,
          isFirstLaunch: true,
          isLoading: false,
        );
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to clear user data');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Clear user data', type: ErrorType.preferences);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear user data: ${e.toString()}',
      );
      return false;
    }
  }

  /// Mark first launch as complete
  Future<bool> setFirstLaunchComplete() async {
    try {
      final success = await _preferencesService.setFirstLaunchComplete();
      
      if (success) {
        state = state.copyWith(isFirstLaunch: false);
        return true;
      }
      
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Set first launch complete', type: ErrorType.preferences);
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}