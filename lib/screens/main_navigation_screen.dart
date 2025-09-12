import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../providers/providers.dart';

import 'home_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'achievements_screen.dart';

/// Wrapper widget to preserve screen state
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  
  const _KeepAliveWrapper({required this.child});
  
  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Main Navigation Screen with iOS-style bottom tab bar
/// 
/// Provides navigation between Home, Stats, and Settings screens
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const _KeepAliveWrapper(child: HomeScreen()),
    const _KeepAliveWrapper(child: StatsScreen()),
    const _KeepAliveWrapper(child: AchievementsScreen()),
    const _KeepAliveWrapper(child: SettingsScreen()),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Semantics(
        label: 'Home tab',
        hint: 'Navigate to home screen',
        child: const Icon(CupertinoIcons.home),
      ),
      activeIcon: Semantics(
        label: 'Home tab active',
        child: const Icon(CupertinoIcons.house_fill),
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Semantics(
        label: 'Statistics tab',
        hint: 'Navigate to statistics screen',
        child: const Icon(CupertinoIcons.chart_bar),
      ),
      activeIcon: Semantics(
        label: 'Statistics tab active',
        child: const Icon(CupertinoIcons.chart_bar_fill),
      ),
      label: 'Stats',
    ),
    BottomNavigationBarItem(
      icon: Semantics(
        label: 'Achievements tab',
        hint: 'Navigate to achievements screen',
        child: const Icon(CupertinoIcons.star),
      ),
      activeIcon: Semantics(
        label: 'Achievements tab active',
        child: const Icon(CupertinoIcons.star_fill),
      ),
      label: 'Achievements',
    ),
    BottomNavigationBarItem(
      icon: Semantics(
        label: 'Settings tab',
        hint: 'Navigate to settings screen',
        child: const Icon(CupertinoIcons.settings),
      ),
      activeIcon: Semantics(
        label: 'Settings tab active',
        child: const Icon(CupertinoIcons.settings_solid),
      ),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle tab selection
  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // Trigger auto-refresh based on selected screen
    _triggerAutoRefresh(index);
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Handle page change from swipe
  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // Trigger auto-refresh based on selected screen
    _triggerAutoRefresh(index);
  }

  /// Trigger auto-refresh for stats and achievements screens
  void _triggerAutoRefresh(int screenIndex) {
    final navigationNotifier = ref.read(screenNavigationNotifierProvider.notifier);
    
    switch (screenIndex) {
      case 0: // Home
        navigationNotifier.navigateToScreen('home');
        break;
      case 1: // Stats
        navigationNotifier.navigateToStats();
        break;
      case 2: // Achievements
        navigationNotifier.navigateToAchievements();
        break;
      case 3: // Settings
        navigationNotifier.navigateToScreen('settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundDark,
          border: Border(
            top: BorderSide(
              color: AppTheme.greyLight.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.greyPrimary,
              unselectedItemColor: AppTheme.secondaryText.withValues(alpha: 0.6),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              iconSize: 22,
              items: _navItems,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SourGummy',
                height: 1.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'SourGummy',
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}